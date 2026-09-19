<?php
/**
 * Riyo Mobile App JSON API (students/parents).
 * Endpoints (all return JSON):
 *   /riyo_api/setup                -> create token table (idempotent)
 *   /riyo_api/login                -> POST username,password -> {token, student}
 *   /riyo_api/profile   ?token=... -> student profile + class/section
 *   /riyo_api/attendance?token=... -> attendance list (month optional)
 *   /riyo_api/fees       ?token=... -> fee summary (expected/paid/balance)
 *   /riyo_api/notices    ?token=... -> school notices
 *   /riyo_api/dashboard  ?token=... -> quick summary
 *   /riyo_api/changepassword       -> POST current_password,new_password,confirm_password
 * Auth: bearer-style token stored in riyo_api_tokens (user_id, expires_at).
 * Rate Limiting: IP-based for login, token-based for authenticated endpoints.
 */
class Riyo_api extends CI_Controller
{
    private $SECRET = 'riyo_app_2025'; // app<->server shared secret (change in production)
    private $TOKEN_TTL = 86400;        // 24h
    
    // Rate limiting configuration
    private $LOGIN_RATE_LIMIT = 5;     // 5 requests
    private $LOGIN_WINDOW = 60;        // per 60 seconds
    private $API_RATE_LIMIT = 60;      // 60 requests
    private $API_WINDOW = 60;          // per 60 seconds

    public function __construct()
    {
        parent::__construct();
        $this->load->database();
        $this->load->library('enc_lib');
        $this->setup_tables();
    }

    private function setup_tables()
    {
        // Token table
        if (!$this->db->table_exists('riyo_api_tokens')) {
            $this->db->query("CREATE TABLE riyo_api_tokens (
                id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
                user_id INT NOT NULL,
                api_token VARCHAR(80) NOT NULL,
                expires_at DATETIME NOT NULL,
                created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                KEY (api_token)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");
        }

        // Rate limit table for login (IP-based)
        if (!$this->db->table_exists('riyo_api_rate_limits')) {
            $this->db->query("CREATE TABLE riyo_api_rate_limits (
                id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
                identifier VARCHAR(100) NOT NULL,  // IP address or user_id
                endpoint VARCHAR(50) NOT NULL,     // 'login', 'api', 'changepassword'
                request_count INT NOT NULL DEFAULT 1,
                window_start TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                UNIQUE KEY unique_limit (identifier, endpoint),
                KEY (window_start)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");
        }
    }

    private function json($data, $code = 200)
    {
        $this->output
            ->set_status_header($code)
            ->set_content_type('application/json')
            ->set_output(json_encode($data, JSON_UNESCAPED_UNICODE));
    }

    private function get_client_ip()
    {
        // Check for forwarded IP (behind proxy/load balancer)
        $ip = $this->input->server('HTTP_X_FORWARDED_FOR');
        if ($ip) {
            $ips = explode(',', $ip);
            return trim($ips[0]);
        }
        return $this->input->ip_address();
    }

    /**
     * Check and increment rate limit
     * @param string $identifier IP address or user_id
     * @param string $endpoint 'login' | 'api' | 'changepassword'
     * @param int $max_requests Maximum requests allowed
     * @param int $window_seconds Time window in seconds
     * @return array|null Returns error array if rate limited, null if OK
     */
    private function check_rate_limit($identifier, $endpoint, $max_requests, $window_seconds)
    {
        $now = time();
        $window_start = date('Y-m-d H:i:s', $now - $window_seconds);

        // Clean old entries
        $this->db->where('window_start <', $window_start);
        $this->db->delete('riyo_api_rate_limits');

        // Check current count
        $row = $this->db->get_where('riyo_api_rate_limits', array(
            'identifier' => $identifier,
            'endpoint' => $endpoint
        ))->row();

        if ($row) {
            if ($row->request_count >= $max_requests) {
                $retry_after = $window_seconds - ($now - strtotime($row->window_start));
                return array(
                    'status' => 'error',
                    'message' => 'Too many requests. Please try again later.',
                    'retry_after' => max(1, $retry_after)
                );
            }
            // Increment
            $this->db->where('identifier', $identifier);
            $this->db->where('endpoint', $endpoint);
            $this->db->set('request_count', 'request_count + 1', FALSE);
            $this->db->update('riyo_api_rate_limits');
        } else {
            // Insert new
            $this->db->insert('riyo_api_rate_limits', array(
                'identifier' => $identifier,
                'endpoint' => $endpoint,
                'request_count' => 1,
                'window_start' => date('Y-m-d H:i:s', $now)
            ));
        }
        return null;
    }

    private function auth()
    {
        $token = $this->input->get_post('token') ?: $this->input->get_request_header('Authorization', TRUE);
        $token = preg_replace('/^Bearer\s+/i', '', (string)$token);
        if (!$token) return false;
        $row = $this->db->get_where('riyo_api_tokens', array('api_token' => $token))->row();
        if (!$row) return false;
        if (strtotime($row->expires_at) < time()) { 
            $this->db->delete('riyo_api_tokens', array('id' => $row->id)); 
            return false; 
        }
        return (int)$row->user_id;
    }

    private function student_by_user($user_id)
    {
        // users.user_id references students.id for role=parent/student
        return $this->db->get_where('students', array('id' => $user_id))->row();
    }

    public function setup()
    {
        $this->json(array('ok' => true, 'table' => $this->db->table_exists('riyo_api_tokens')));
    }

    public function login()
    {
        // Rate limiting: 5 requests per minute per IP
        $ip = $this->get_client_ip();
        $rate_limit_error = $this->check_rate_limit($ip, 'login', $this->LOGIN_RATE_LIMIT, $this->LOGIN_WINDOW);
        if ($rate_limit_error) {
            return $this->json($rate_limit_error, 429);
        }

        $username = $this->input->post('username');
        $password = $this->input->post('password');
        if (!$username || !$password) { 
            return $this->json(array('status' => 'error', 'message' => 'username and password required'), 400); 
        }

        $this->db->where('username', $username);
        $user = $this->db->get('users')->row();
        if (!$user) { 
            return $this->json(array('status' => 'error', 'message' => 'Invalid credentials'), 401); 
        }
        if ($user->role != 'student' && $user->role != 'parent') {
            return $this->json(array('status' => 'error', 'message' => 'This app is for students/parents only'), 403);
        }
        // SmartSchool stores users.password in plaintext (verified against User_model::checkLogin).
        if ($user->password !== $password) {
            return $this->json(array('status' => 'error', 'message' => 'Invalid credentials'), 401);
        }

        $student = $this->student_by_user($user->user_id);
        if (!$student) { 
            return $this->json(array('status' => 'error', 'message' => 'No student linked to this account'), 404); 
        }

        // issue token
        $this->db->delete('riyo_api_tokens', array('user_id' => $user->user_id));
        $token = bin2hex(random_bytes(32));
        $this->db->insert('riyo_api_tokens', array(
            'user_id' => $user->user_id,
            'api_token' => $token,
            'expires_at' => date('Y-m-d H:i:s', time() + $this->TOKEN_TTL),
        ));
        $this->json(array(
            'status' => 'success',
            'token' => $token,
            'expires_at' => date('Y-m-d H:i:s', time() + $this->TOKEN_TTL),
            'student' => $this->public_student($student),
        ));
    }

    private function public_student($s)
    {
        $ss = $this->db->get_where('student_session', array('student_id' => $s->id, 'is_active' => 'yes'))->row();
        $class = $section = '';
        if ($ss) {
            $c = $this->db->get_where('classes', array('id' => $ss->class_id))->row();
            $sec = $this->db->get_where('sections', array('id' => $ss->section_id))->row();
            $class = $c ? $c->class : '';
            $section = $sec ? $sec->section : '';
        }
        return array(
            'admission_no' => $s->admission_no,
            'firstname' => $s->firstname,
            'lastname' => $s->lastname,
            'gender' => $s->gender,
            'class' => $class,
            'section' => $section,
        );
    }

    private function rate_limit_authenticated($uid)
    {
        $rate_limit_error = $this->check_rate_limit((string)$uid, 'api', $this->API_RATE_LIMIT, $this->API_WINDOW);
        if ($rate_limit_error) {
            return $this->json($rate_limit_error, 429);
        }
        return null;
    }

    public function profile()
    {
        $uid = $this->auth();
        if (!$uid) return $this->json(array('status' => 'error', 'message' => 'unauthorized'), 401);
        
        // Rate limit: 60 requests per minute per user
        $rate_limit_error = $this->rate_limit_authenticated($uid);
        if ($rate_limit_error) return $rate_limit_error;

        $s = $this->student_by_user($uid);
        if (!$s) return $this->json(array('status' => 'error', 'message' => 'not found'), 404);
        $this->json(array('status' => 'success', 'student' => $this->public_student($s)));
    }

    public function attendance()
    {
        $uid = $this->auth();
        if (!$uid) return $this->json(array('status' => 'error', 'message' => 'unauthorized'), 401);
        
        $rate_limit_error = $this->rate_limit_authenticated($uid);
        if ($rate_limit_error) return $rate_limit_error;

        $s = $this->student_by_user($uid);
        if (!$s) return $this->json(array('status' => 'error', 'message' => 'not found'), 404);
        $ss = $this->db->get_where('student_session', array('student_id' => $s->id, 'is_active' => 'yes'))->row();
        if (!$ss) return $this->json(array('status' => 'success', 'attendance' => array()));
        $month = $this->input->get('month'); // YYYY-MM
        $this->db->select('sa.date, sa.remark, at.type as status');
        $this->db->from('student_attendences sa');
        $this->db->join('attendence_type at', 'at.id = sa.attendence_type_id', 'left');
        $this->db->where('sa.student_session_id', $ss->id);
        if ($month) $this->db->like('sa.date', $month, 'after');
        $this->db->order_by('sa.date', 'DESC');
        $rows = $this->db->get()->result_array();
        $this->json(array('status' => 'success', 'attendance' => $rows));
    }

    public function fees()
    {
        $uid = $this->auth();
        if (!$uid) return $this->json(array('status' => 'error', 'message' => 'unauthorized'), 401);
        
        $rate_limit_error = $this->rate_limit_authenticated($uid);
        if ($rate_limit_error) return $rate_limit_error;

        $s = $this->student_by_user($uid);
        if (!$s) return $this->json(array('status' => 'error', 'message' => 'not found'), 404);
        $ss = $this->db->get_where('student_session', array('student_id' => $s->id, 'is_active' => 'yes'))->row();
        if (!$ss) return $this->json(array('status' => 'success', 'fees' => array('expected' => 0, 'paid' => 0, 'balance' => 0)));
        // expected = sum of feemasters for class
        $this->db->select_sum('amount', 'expected');
        $this->db->where('class_id', $ss->class_id);
        $exp = $this->db->get('feemasters')->row();
        $expected = $exp ? (float)$exp->expected : 0;
        // paid = sum of student_fees deposits for this student session
        $this->db->select_sum('amount', 'paid');
        $this->db->where('student_session_id', $ss->id);
        $pay = $this->db->get('student_fees')->row();
        $paid = $pay ? (float)$pay->paid : 0;
        $this->json(array(
            'status' => 'success',
            'fees' => array(
                'expected' => $expected,
                'paid' => $paid,
                'balance' => max(0, $expected - $paid),
            ),
        ));
    }

    public function notices()
    {
        $uid = $this->auth();
        if (!$uid) return $this->json(array('status' => 'error', 'message' => 'unauthorized'), 401);
        
        $rate_limit_error = $this->rate_limit_authenticated($uid);
        if ($rate_limit_error) return $rate_limit_error;

        $this->db->select('title, message, publish_date, date');
        $this->db->from('send_notification');
        $this->db->where("visible_student IN ('Yes','yes','YES','1','true')", null, false);
        $this->db->order_by('publish_date', 'DESC');
        $this->db->limit(20);
        $rows = $this->db->get()->result_array();
        $out = array();
        foreach ($rows as $r) {
            $out[] = array(
                'title' => $r['title'],
                'message' => $r['message'],
                'date' => $r['publish_date'] ?: $r['date'],
            );
        }
        $this->json(array('status' => 'success', 'notices' => $out));
    }

    public function examresults()
    {
        $uid = $this->auth();
        if (!$uid) return $this->json(array('status' => 'error', 'message' => 'unauthorized'), 401);
        
        $rate_limit_error = $this->rate_limit_authenticated($uid);
        if ($rate_limit_error) return $rate_limit_error;

        $s = $this->student_by_user($uid);
        if (!$s) return $this->json(array('status' => 'error', 'message' => 'not found'), 404);

        // All student sessions (current AND old classes) so past exam results show too.
        $this->db->select('ss.id as ssid, ss.session_id, ses.session as session_name, c.class as class_name, sec.section as section_name');
        $this->db->from('student_session ss');
        $this->db->join('sessions ses', 'ses.id = ss.session_id', 'left');
        $this->db->join('classes c', 'c.id = ss.class_id', 'left');
        $this->db->join('sections sec', 'sec.id = ss.section_id', 'left');
        $this->db->where('ss.student_id', $s->id);
        $this->db->order_by('ss.session_id', 'DESC');
        $sessions = $this->db->get()->result_array();

        $out = array();
        foreach ($sessions as $sess) {
            $sid = $sess['ssid'];
            // published exam group exams linked to this student_session
            $this->db->select('egcbse.id as exam_student_id, egcbe.id as egcbe_id, eg.id as exam_group_id, eg.name as exam_group_name');
            $this->db->from('exam_group_class_batch_exam_students egcbse');
            $this->db->join('exam_group_class_batch_exams egcbe', 'egcbe.id = egcbse.exam_group_class_batch_exam_id');
            $this->db->join('exam_groups eg', 'eg.id = egcbe.exam_group_id');
            $this->db->where('egcbse.student_session_id', $sid);
            $this->db->where('egcbe.is_publish', 1);
            $exams = $this->db->get()->result_array();

            $groups = array();
            foreach ($exams as $e) {
                $this->db->select('egcbes.subject_id, s.name as subject, egcbes.max_marks, r.get_marks, r.attendence, r.note');
                $this->db->from('exam_group_class_batch_exam_subjects egcbes');
                $this->db->join('subjects s', 's.id = egcbes.subject_id', 'left');
                $this->db->join('exam_group_exam_results r', 'r.exam_group_class_batch_exam_subject_id = egcbes.id AND r.exam_group_class_batch_exam_student_id = ' . (int)$e['exam_student_id'], 'left');
                $this->db->where('egcbes.exam_group_class_batch_exams_id', $e['egcbe_id']);
                $subjects = $this->db->get()->result_array();

                $total_max = 0; $total_get = 0; $has_marks = false;
                foreach ($subjects as &$sub) {
                    $sub['max_marks'] = is_numeric($sub['max_marks']) ? (float)$sub['max_marks'] : null;
                    $sub['get_marks'] = is_numeric($sub['get_marks']) ? (float)$sub['get_marks'] : null;
                    if ($sub['max_marks'] !== null) $total_max += $sub['max_marks'];
                    if ($sub['get_marks'] !== null) { $total_get += $sub['get_marks']; $has_marks = true; }
                }
                $pct = ($has_marks && $total_max > 0) ? round($total_get / $total_max * 100, 1) : null;
                
                // Calculate rank for this student in this exam group
                $rank = 1;
                if ($pct !== null) {
                    // Get all students in this exam group (egcbe_id) with their total marks
                    $this->db->select('egcbse.id as exam_student_id');
                    $this->db->from('exam_group_class_batch_exam_students egcbse');
                    $this->db->where('egcbse.exam_group_class_batch_exams_id', $e['egcbe_id']);
                    $all_students = $this->db->get()->result_array();
                    
                    $student_percentages = array();
                    foreach ($all_students as $stud) {
                        // Calculate total marks for each student in this exam group
                        $this->db->select('egcbes.subject_id, egcbes.max_marks, r.get_marks');
                        $this->db->from('exam_group_class_batch_exam_subjects egcbes');
                        $this->db->join('exam_group_exam_results r', 'r.exam_group_class_batch_exam_subject_id = egcbes.id AND r.exam_group_class_batch_exam_student_id = ' . (int)$stud['exam_student_id'], 'left');
                        $this->db->where('egcbes.exam_group_class_batch_exams_id', $e['egcbe_id']);
                        $stud_subjects = $this->db->get()->result_array();
                        
                        $stud_total_max = 0; $stud_total_get = 0; $stud_has_marks = false;
                        foreach ($stud_subjects as &$ssub) {
                            $ssub['max_marks'] = is_numeric($ssub['max_marks']) ? (float)$ssub['max_marks'] : null;
                            $ssub['get_marks'] = is_numeric($ssub['get_marks']) ? (float)$ssub['get_marks'] : null;
                            if ($ssub['max_marks'] !== null) $stud_total_max += $ssub['max_marks'];
                            if ($ssub['get_marks'] !== null) { $stud_total_get += $ssub['get_marks']; $stud_has_marks = true; }
                        }
                        if ($stud_has_marks && $stud_total_max > 0) {
                            $stud_pct = round($stud_total_get / $stud_total_max * 100, 1);
                            $student_percentages[] = $stud_pct;
                        }
                    }
                    
                    // Sort descending and find rank
                    rsort($student_percentages);
                    foreach ($student_percentages as $i => $sp) {
                        if ($sp > $pct) $rank++;
                        else break;
                    }
                }
                
                $groups[] = array(
                    'exam_group' => $e['exam_group_name'],
                    'subjects' => $subjects,
                    'total_max' => $total_max,
                    'total_get' => $has_marks ? $total_get : null,
                    'percentage' => $pct === null ? null : (string)$pct, // clean "80.4"
                    'grade' => $pct === null ? null : $this->grade_for($pct),
                    'rank' => $rank,
                    'total_students' => count($student_percentages) ?? 0,
                );
            }

            if (!empty($groups)) {
                $out[] = array(
                    'session' => $sess['session_name'] ?: 'Session',
                    'class' => trim(($sess['class_name'] ?? '') . ' ' . ($sess['section_name'] ?? '')),
                    'exam_groups' => $groups,
                );
            }
        }
        $this->json(array('status' => 'success', 'sessions' => $out));
    }

    private function grade_for($pct)
    {
        if ($pct >= 90) return 'A+';
        if ($pct >= 80) return 'A';
        if ($pct >= 70) return 'B';
        if ($pct >= 60) return 'C';
        if ($pct >= 50) return 'D';
        return 'F';
    }

    public function dashboard()
    {
        $uid = $this->auth();
        if (!$uid) return $this->json(array('status' => 'error', 'message' => 'unauthorized'), 401);
        
        $rate_limit_error = $this->rate_limit_authenticated($uid);
        if ($rate_limit_error) return $rate_limit_error;

        $s = $this->student_by_user($uid);
        if (!$s) return $this->json(array('status' => 'error', 'message' => 'not found'), 404);
        $ss = $this->db->get_where('student_session', array('student_id' => $s->id, 'is_active' => 'yes'))->row();
        $att_count = 0;
        if ($ss) {
            $this->db->where('student_session_id', $ss->id);
            $att_count = $this->db->count_all_results('student_attendences');
        }
        $this->json(array(
            'status' => 'success',
            'student' => $this->public_student($s),
            'attendance_records' => $att_count,
        ));
    }

    public function changepassword()
    {
        $uid = $this->auth();
        if (!$uid) return $this->json(array('status' => 'error', 'message' => 'unauthorized'), 401);

        // Rate limit: 5 requests per minute for password change
        $rate_limit_error = $this->check_rate_limit((string)$uid, 'changepassword', 5, 60);
        if ($rate_limit_error) {
            return $this->json($rate_limit_error, 429);
        }

        $current = $this->input->post('current_password');
        $new = $this->input->post('new_password');
        $confirm = $this->input->post('confirm_password');

        if (!$current || !$new || !$confirm) {
            return $this->json(array('status' => 'error', 'message' => 'All fields required'), 400);
        }
        if ($new !== $confirm) {
            return $this->json(array('status' => 'error', 'message' => 'Passwords do not match'), 400);
        }
        if (strlen($new) < 6) {
            return $this->json(array('status' => 'error', 'message' => 'Password too short (min 6 chars)'), 400);
        }

        // Verify current password
        $user = $this->db->get_where('users', array('user_id' => $uid))->row();
        if (!$user || $user->password !== $current) {
            return $this->json(array('status' => 'error', 'message' => 'Current password incorrect'), 401);
        }

        // Update password (plaintext like existing login)
        $this->db->where('user_id', $uid);
        $this->db->update('users', array('password' => $new));

        // Invalidate all tokens for security
        $this->db->delete('riyo_api_tokens', array('user_id' => $uid));

        $this->json(array('status' => 'success', 'message' => 'Password changed successfully. Please log in again.'));
    }
}
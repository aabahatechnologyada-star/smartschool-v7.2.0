import 'demo_data.dart';

/// DemoService provides hardcoded sample data locally when running in demo mode.
class DemoService {
  static const String demoToken = 'mock-demo-token-TEST001';

  static Map<String, dynamic> login(String admissionNo, String password) {
    return {
      'status': 'success',
      'token': demoToken,
      'student': DemoData.student,
    };
  }

  static Map<String, dynamic> getProfile() => {
        'status': 'success',
        'student': DemoData.student,
      };

  static Map<String, dynamic> getNotices() => {
        'status': 'success',
        'notices': DemoData.notices,
      };

  static Map<String, dynamic> getExamResults() => {
        'status': 'success',
        'sessions': DemoData.examResults,
      };

  static Map<String, dynamic> getFees() => DemoData.fees;

  static Map<String, dynamic> getAttendance([String? month]) => DemoData.attendance;

  static Map<String, dynamic> getDashboard() => DemoData.dashboard;

  static Map<String, dynamic> getIncidents() => {
        'status': 'success',
        'incidents': DemoData.incidents,
      };
}

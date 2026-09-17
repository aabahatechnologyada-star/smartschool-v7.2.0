import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'dart:async';

/// Simple mock backend for riyo app testing
/// Run with: dart run test/mock_backend.dart
/// Then test against http://localhost:8080
void main() async {
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 8080);
  print('Mock backend running on http://localhost:8080');
  
  await for (HttpRequest request in server) {
    print('${request.method} ${request.uri.path}');
    
    // Handle CORS
    request.response.headers.add('Access-Control-Allow-Origin', '*');
    request.response.headers.add('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
    request.response.headers.add('Access-Control-Allow-Headers', 'Content-Type, Cookie');
    request.response.headers.add('Access-Control-Allow-Credentials', 'true');
    
    if (request.method == 'OPTIONS') {
      request.response.statusCode = 200;
      await request.response.close();
      continue;
    }
    
    String body = '';
    await for (var chunk in request) {
      body += utf8.decode(chunk);
    }
    
    switch (request.uri.path) {
      case '/riyo_api/login':
        await _handleLogin(request, body);
        break;
      case '/riyo_api/profile':
        await _handleProfile(request);
        break;
      case '/riyo_api/notices':
        await _handleNotices(request);
        break;
      case '/riyo_api/examresults':
        await _handleExamResults(request);
        break;
      case '/riyo_api/dashboard':
        await _handleDashboard(request);
      case '/riyo_api/attendance':
        await _handleAttendance(request);
        break;
      case '/riyo_api/fees':
        await _handleFees(request);
        break;
      case '/riyo_api/setup':
        await _handleSetup(request);
        break;
      default:
        request.response.statusCode = 404;
        request.response.write('Not Found');
        await request.response.close();
    }
  }
}

Future<void> _handleLogin(HttpRequest request, String body) async {
  final params = Uri.splitQueryString(body);
  final username = params['username'] ?? '';
  final password = params['password'] ?? '';
  
  // Simple validation - any non-empty credentials work
  if (username.isNotEmpty && password.isNotEmpty) {
    request.response.headers.contentType = ContentType.json;
    request.response.headers.add('Set-Cookie', 'PHPSESSID=mock-session-${DateTime.now().millisecondsSinceEpoch}; HttpOnly; Path=/');
    request.response.write(jsonEncode({
      'status': 'success',
      'token': 'mock-jwt-token-${username}-${DateTime.now().millisecondsSinceEpoch}',
      'student': {
        'firstname': 'John',
        'lastname': 'Doe',
        'admission_no': 'STU001',
        'class': '10',
        'section': 'A',
        'gender': 'Male',
      }
    }));
  } else {
    request.response.statusCode = 400;
    request.response.headers.contentType = ContentType.json;
    request.response.write(jsonEncode({
      'status': 'error',
      'message': 'Invalid credentials'
    }));
  }
  await request.response.close();
}

Future<void> _handleProfile(HttpRequest request) async {
  final token = _extractToken(request);
  if (token == null || !token.startsWith('mock-jwt-token-')) {
    _unauthorized(request);
    return;
  }
  
  request.response.headers.contentType = ContentType.json;
  request.response.write(jsonEncode({
    'status': 'success',
    'student': {
      'firstname': 'John',
      'lastname': 'Doe',
      'admission_no': 'STU001',
      'class': '10',
      'section': 'A',
      'gender': 'Male',
      'dob': '2010-05-15',
      'father_name': 'Robert Doe',
      'mother_name': 'Jane Doe',
      'phone': '+1234567890',
      'email': 'john.doe@example.com',
      'address': '123 School Lane, City',
    }
  }));
  await request.response.close();
}

Future<void> _handleNotices(HttpRequest request) async {
  _requireAuth(request, () {
    request.response.headers.contentType = ContentType.json;
    request.response.write(jsonEncode({
      'status': 'success',
      'notices': [
        {
          'title': 'Mid-term Exams Schedule',
          'message': 'Exams begin March 15. Check the timetable.',
          'date': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
        },
        {
          'title': 'PTA Meeting',
          'message': 'Parents-Teachers meeting on March 20 at 4 PM.',
          'date': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
        },
        {
          'title': 'Holiday Notice',
          'message': 'School closed March 25-29 for spring break.',
          'date': DateTime.now().subtract(const Duration(days: 10)).toIso8601String(),
        },
      ]
    }));
    request.response.close();
  });
}

Future<void> _handleExamResults(HttpRequest request) async {
  _requireAuth(request, () {
    request.response.headers.contentType = ContentType.json;
    request.response.write(jsonEncode({
      'status': 'success',
      'sessions': [
        {
          'session': '2023-2024',
          'class': '10-A',
          'exam_groups': [
            {
              'exam_group': 'Mid Term',
              'percentage': 87.5,
              'grade': 'A',
              'subjects': [
                {'subject': 'Mathematics', 'get_marks': 92, 'max_marks': 100},
                {'subject': 'Science', 'get_marks': 85, 'max_marks': 100},
                {'subject': 'English', 'get_marks': 88, 'max_marks': 100},
                {'subject': 'Social Studies', 'get_marks': 84, 'max_marks': 100},
              ],
            },
            {
              'exam_group': 'Quarterly',
              'percentage': 91.2,
              'grade': 'A+',
              'subjects': [
                {'subject': 'Mathematics', 'get_marks': 95, 'max_marks': 100},
                {'subject': 'Science', 'get_marks': 89, 'max_marks': 100},
              ],
            },
          ],
        },
      ]
    }));
    request.response.close();
  });
}

Future<void> _handleDashboard(HttpRequest request) async {
  _requireAuth(request, () {
    request.response.headers.contentType = ContentType.json;
    request.response.write(jsonEncode({
      'status': 'success',
      'attendance_percentage': 95.2,
      'fee_status': 'Paid',
      'next_exam': 'Final Exam - April 15',
      'pending_homework': 3,
      'recent_notices': 2,
    }));
    request.response.close();
  });
}

Future<void> _handleAttendance(HttpRequest request) async {
  _requireAuth(request, () {
    final month = request.uri.queryParameters['month'] ?? DateTime.now().toString().substring(0, 7);
    request.response.headers.contentType = ContentType.json;
    request.response.write(jsonEncode({
      'status': 'success',
      'month': month,
      'records': List.generate(30, (i) => {
        'date': DateTime(DateTime.now().year, DateTime.now().month, i + 1).toIso8601String().substring(0, 10),
        'status': ['P', 'P', 'P', 'A', 'L'][i % 5],
      }),
    }));
    request.response.close();
  });
}

Future<void> _handleFees(HttpRequest request) async {
  _requireAuth(request, () {
    request.response.headers.contentType = ContentType.json;
    request.response.write(jsonEncode({
      'status': 'success',
      'total_due': 0,
      'paid_amount': 45000,
      'transactions': [
        {'date': '2024-01-15', 'amount': 15000, 'description': 'Tuition - Jan', 'status': 'Paid'},
        {'date': '2024-02-15', 'amount': 15000, 'description': 'Tuition - Feb', 'status': 'Paid'},
        {'date': '2024-03-15', 'amount': 15000, 'description': 'Tuition - Mar', 'status': 'Paid'},
      ],
    }));
    request.response.close();
  });
}

Future<void> _handleSetup(HttpRequest request) async {
  request.response.headers.contentType = ContentType.json;
  request.response.write(jsonEncode({
    'status': 'success',
    'app_version': '7.2.0',
    'api_version': '1.0',
    'maintenance_mode': false,
    'force_update': false,
  }));
  request.response.close();
}

String? _extractToken(HttpRequest request) {
  final auth = request.headers.value('authorization');
  if (auth != null && auth.startsWith('Bearer ')) {
    return auth.substring(7);
  }
  // Also check query param
  return request.uri.queryParameters['token'];
}

void _requireAuth(HttpRequest request, VoidCallback handler) {
  final token = _extractToken(request);
  if (token == null || !token.startsWith('mock-jwt-token-')) {
    _unauthorized(request);
    return;
  }
  handler();
}

void _unauthorized(HttpRequest request) {
  request.response.statusCode = 401;
  request.response.headers.contentType = ContentType.json;
  request.response.write(jsonEncode({
    'status': 'error',
    'message': 'Unauthorized'
  }));
  request.response.close();
}
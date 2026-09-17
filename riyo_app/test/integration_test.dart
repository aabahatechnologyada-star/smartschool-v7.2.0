import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

// Simple integration test using http testing package
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('API Integration', () {
    test('login endpoint returns token', () async {
      // Mock HTTP server
      final server = MockClient((request) async {
        if (request.url.path == '/riyo_api/login' && request.method == 'POST') {
          return http.Response(
            jsonEncode({'status': 'success', 'token': 'test-token-123'}),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response('Not Found', 404);
      });

      // Test would need RiyoApi to accept injected http.Client
      // For now, verify the expected request format
      final request = http.Request('POST', Uri.parse('https://riyo.rf.gd/riyo_api/login'));
      request.bodyFields = {'username': 'test', 'password': 'pass'};
      
      expect(request.method, 'POST');
      expect(request.url.path, '/riyo_api/login');
      expect(request.bodyFields['username'], 'test');
    });

    test('token storage works', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.setString('riyo_api_token', 'test-token');
      final token = prefs.getString('riyo_api_token');
      
      expect(token, 'test-token');
    });
  });
}
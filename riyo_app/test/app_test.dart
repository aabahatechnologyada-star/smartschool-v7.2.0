import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SharedPreferences', () {
    test('token storage works', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.setString('riyo_api_token', 'test-token');
      final token = prefs.getString('riyo_api_token');
      
      expect(token, 'test-token');
      
      await prefs.remove('riyo_api_token');
      final removed = prefs.getString('riyo_api_token');
      expect(removed, isNull);
    });
  });

  group('Mock HTTP Client', () {
    test('login endpoint returns token', () async {
      final mockClient = MockClient((request) async {
        if (request.url.path == '/riyo_api/login' && request.method == 'POST') {
          return http.Response(
            jsonEncode({'status': 'success', 'token': 'test-token-123'}),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response('Not Found', 404);
      });

      final response = await mockClient.post(
        Uri.parse('http://localhost/riyo_api/login'),
        body: {'username': 'test', 'password': 'pass'},
      );

      expect(response.statusCode, 200);
      final body = jsonDecode(response.body);
      expect(body['status'], 'success');
      expect(body['token'], 'test-token-123');
    });

    test('handles network error', () async {
      final mockClient = MockClient((request) {
        throw Exception('Network error');
      });

      expect(
        () => mockClient.get(Uri.parse('http://localhost/riyo_api/profile')),
        throwsException,
      );
    });
  });

  group('Date formatting', () {
    test('formats recent dates correctly', () {
      final now = DateTime.now();
      final fiveMinutesAgo = now.subtract(const Duration(minutes: 5));
      final oneHourAgo = now.subtract(const Duration(hours: 1));
      final oneDayAgo = now.subtract(const Duration(days: 1));
      final oneWeekAgo = now.subtract(const Duration(days: 7));
      final tenDaysAgo = now.subtract(const Duration(days: 10));

      String formatDate(DateTime date) {
        final diff = now.difference(date);
        if (diff.inDays > 7) {
          return '${date.day}/${date.month}/${date.year}';
        } else if (diff.inDays > 0) {
          return '${diff.inDays}d';
        } else if (diff.inHours > 0) {
          return '${diff.inHours}h';
        } else {
          return '${diff.inMinutes}m';
        }
      }

      expect(formatDate(fiveMinutesAgo), '5m');
      expect(formatDate(oneHourAgo), '1h');
      expect(formatDate(oneDayAgo), '1d');
      expect(formatDate(oneWeekAgo), '7d');
      expect(formatDate(tenDaysAgo), contains('/'));
    });
  });

  group('API Error mapping', () {
    test('maps HTTP status to error codes', () {
      ApiError mapHttp(int s) {
        if (s == 401) return ApiError.unauthorized;
        if (s == 403) return ApiError.forbidden;
        if (s == 404) return ApiError.notFound;
        if (s == 400) return ApiError.badRequest;
        if (s >= 500) return ApiError.serverError;
        return ApiError.unknown;
      }

      expect(mapHttp(401), ApiError.unauthorized);
      expect(mapHttp(403), ApiError.forbidden);
      expect(mapHttp(404), ApiError.notFound);
      expect(mapHttp(400), ApiError.badRequest);
      expect(mapHttp(500), ApiError.serverError);
      expect(mapHttp(502), ApiError.serverError);
      expect(mapHttp(418), ApiError.unknown);
    });
  });
}

enum ApiError {
  noNetwork,
  timeout,
  unauthorized,
  forbidden,
  notFound,
  serverError,
  badRequest,
  invalidResponse,
  unknown,
}
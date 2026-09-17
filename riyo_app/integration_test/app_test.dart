import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:integration_test/integration_test.dart';
import 'package:riyo_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('End-to-End App Flow', () {
    testWidgets('Complete login and navigation flow', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Verify login screen is shown
      expect(find.text('Welcome back'), findsOneWidget);
      expect(find.text('Sign in to your student account'), findsOneWidget);

      // Enter credentials
      await tester.enterText(find.byType(TextField).first, 'student123');
      await tester.enterText(find.byType(TextField).last, 'password123');

      // Tap sign in
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Should be on Home tab (MainApp)
      expect(find.byType(app.MainApp), findsOneWidget);
      
      // Verify bottom navigation exists
      expect(find.byType(NavigationBar), findsOneWidget);
      
      // Check all 5 tabs are present
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Search'), findsOneWidget);
      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('Messages'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
    });

    testWidgets('Tab navigation works', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Login
      await tester.enterText(find.byType(TextField).first, 'student123');
      await tester.enterText(find.byType(TextField).last, 'password123');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Tap Search tab
      await tester.tap(find.text('Search').last);
      await tester.pumpAndSettle();
      expect(find.text('Search'), findsWidgets);

      // Tap Notifications tab
      await tester.tap(find.text('Notifications').last);
      await tester.pumpAndSettle();
      expect(find.text('Notifications'), findsWidgets);

      // Tap Messages tab
      await tester.tap(find.text('Messages').last);
      await tester.pumpAndSettle();
      expect(find.text('Messages'), findsWidgets);

      // Tap Profile tab
      await tester.tap(find.text('Profile').last);
      await tester.pumpAndSettle();
      expect(find.text('Profile'), findsWidgets);

      // Back to Home
      await tester.tap(find.text('Home').last);
      await tester.pumpAndSettle();
    });

    testWidgets('Pull to refresh on Home', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Login
      await tester.enterText(find.byType(TextField).first, 'student123');
      await tester.enterText(find.byType(TextField).last, 'password123');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Find the RefreshIndicator and pull
      final refreshIndicator = find.byType(RefreshIndicator);
      expect(refreshIndicator, findsOneWidget);

      // Drag down to refresh
      await tester.drag(refreshIndicator, const Offset(0, 200));
      await tester.pumpAndSettle(const Duration(seconds: 3));
    });
  });
}
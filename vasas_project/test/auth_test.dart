import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vasas_project/features/auth/pages/sign_up_page.dart';

void main() {
  group('Authentication Tests', () {
    testWidgets('SignupScreen should render form fields',
        (WidgetTester tester) async {
      // Build the SignupScreen widget
      await tester.pumpWidget(
        MaterialApp(
          home: SignupScreen(),
        ),
      );

      // Verify that the email and password fields are displayed
      expect(find.byType(TextFormField), findsAtLeast(2));

      // Check for signup button
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('SignupScreen should validate email format',
        (WidgetTester tester) async {
      // Build the SignupScreen widget
      await tester.pumpWidget(
        MaterialApp(
          home: SignupScreen(),
        ),
      );

      // Find email field and enter an invalid email
      final emailField = find.byType(TextFormField).first;
      await tester.enterText(emailField, 'invalid-email');

      // Tap the signup button to trigger validation
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Check for validation error message
      expect(find.text('Enter a valid email address'), findsOneWidget);
    });
  });
}

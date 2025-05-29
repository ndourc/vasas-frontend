import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vasas_project/features/chat/pages/chat_screen.dart';

void main() {
  group('Chatbot UI Tests', () {
    testWidgets('ChatbotPage should display UI elements',
        (WidgetTester tester) async {
      // Build the ChatbotPage widget
      await tester.pumpWidget(
        MaterialApp(
          home: ChatbotPage(),
        ),
      );

      // Verify that the message input field is displayed
      expect(find.byType(TextField), findsOneWidget);

      // Verify send button is present
      expect(find.byIcon(Icons.send), findsOneWidget);

      // Verify that the chat messages list view is present
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('Should be able to type a message',
        (WidgetTester tester) async {
      // Build the ChatbotPage widget
      await tester.pumpWidget(
        MaterialApp(
          home: ChatbotPage(),
        ),
      );

      // Find the input field and enter text
      final messageField = find.byType(TextField);
      await tester.enterText(messageField, 'Hello bot');

      // Verify the text was entered correctly
      expect(find.text('Hello bot'), findsOneWidget);
    });
  });
}

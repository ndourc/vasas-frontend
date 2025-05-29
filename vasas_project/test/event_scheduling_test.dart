// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';


// void main() {
//   group('Event Scheduling Tests', () {
//     testWidgets('EventForm should render form fields',
//         (WidgetTester tester) async {
//       // Build the EventForm widget
//       await tester.pumpWidget(
//         MaterialApp(
//           home: Scaffold(
//             body: EventForm(),
//           ),
//         ),
//       );

//       // Check for form fields
//       expect(find.byType(TextFormField),
//           findsAtLeast(3)); // Title, description, location
//       expect(find.byType(DropdownButtonFormField),
//           findsOneWidget); // Event type dropdown
//       expect(find.byType(ElevatedButton), findsOneWidget); // Submit button
//     });

//     testWidgets('EventForm should validate required fields',
//         (WidgetTester tester) async {
//       // Build the EventForm widget
//       await tester.pumpWidget(
//         MaterialApp(
//           home: Scaffold(
//             body: EventForm(),
//           ),
//         ),
//       );

//       // Try to submit the form without filling in required fields
//       await tester.tap(find.byType(ElevatedButton));
//       await tester.pump();

//       // Check for validation errors
//       expect(find.text('Title is required'), findsOneWidget);
//     });

//     testWidgets('EventForm should allow filling out the form',
//         (WidgetTester tester) async {
//       // Build the EventForm widget
//       await tester.pumpWidget(
//         MaterialApp(
//           home: Scaffold(
//             body: EventForm(),
//           ),
//         ),
//       );

//       // Fill in the title field
//       await tester.enterText(find.byType(TextFormField).first, 'Test Event');

//       // Verify the text was entered correctly
//       expect(find.text('Test Event'), findsOneWidget);
//     });
//   });
// }

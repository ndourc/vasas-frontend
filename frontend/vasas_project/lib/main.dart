import 'package:flutter/material.dart';
import 'package:vasas_project/features/auth/pages/sign_up_page.dart';
import 'package:vasas_project/features/auth/pages/forgot_password_page.dart';
import 'package:vasas_project/features/chat/pages/chat_screen.dart';
import 'package:vasas_project/features/planner_module/pages/plans.dart';
import 'package:vasas_project/features/chat/pages/start_chat_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'VASAS Test',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: SignupScreen());
  }
}

import 'package:flutter/material.dart';
import 'package:vasas_project/core/utils/build_button.dart';
import 'package:vasas_project/core/utils/build_textfield.dart';
import 'package:vasas_project/features/auth/pages/login_page.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  void _sendResetLink() async {
    setState(() {
      _isLoading = true;
    });

    // await AuthService.sendPasswordResetEmail(_emailController.text);

    setState(() {
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Password reset link sent")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(children: [
        Positioned(
          top: 0,
          left: 0,
          right: 70,
          child: Image.asset('assets/upper_blob.png', fit: BoxFit.cover),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 12,
          child: Image.asset('assets/lower_blob.png', fit: BoxFit.cover),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Forgot Password",
                  style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.green),
                ),
                const SizedBox(height: 30),
                CustomTextField(
                  controller: _emailController,
                  labelText: 'Email',
                ),
                const SizedBox(height: 40),
                _isLoading
                    ? const CircularProgressIndicator()
                    : CustomButton(
                        onPressed: _sendResetLink,
                        labelText: "Send",
                      ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginScreen()),
                    );
                  },
                  child: const Text(
                    "Back to Login",
                    style: TextStyle(color: Colors.green),
                  ),
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}

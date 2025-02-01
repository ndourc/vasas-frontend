import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.labelText,
  });

  @override
  Widget build(BuildContext context) {
    const SizedBox(height: 20);
    return TextField(
      controller: controller,
      obscureText: labelText == 'Password' || labelText == 'Confirm Password',
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: Colors.green),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: const BorderSide(color: Colors.black, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: const BorderSide(color: Colors.green, width: 2.0),
        ),
      ),
      style: const TextStyle(color: Colors.green),
    );
  }
}

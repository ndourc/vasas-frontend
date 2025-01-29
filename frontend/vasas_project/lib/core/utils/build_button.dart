import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String labelText;

  const CustomButton({
    super.key,
    required this.onPressed,
    required this.labelText,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.black, // Text color
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0), // Circular shape
          side: const BorderSide(
              color: Colors.purple, width: 2.0), // Border color and width
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
        child: Text(
          labelText,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

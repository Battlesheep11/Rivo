import 'package:flutter/material.dart';

class AppErrorText extends StatelessWidget {
  final String message;

  const AppErrorText({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Text(
        message,
        style: const TextStyle(
          color: Color(0xFFE53E3E),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

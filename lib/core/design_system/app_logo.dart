import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      'RIVO',
      style: const TextStyle(
        fontFamily: 'Pacifico',
        fontSize: 42,
        color: Color(0xFF2B6CB0),
        fontWeight: FontWeight.w400,
      ),
    );
  }
}

import 'package:flutter/material.dart';

class AppTypography {
  static const String fontFamily = 'Roboto';

  static final TextTheme textTheme = TextTheme(
    displayLarge: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
    displayMedium: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
    displaySmall: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
    headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
    headlineSmall: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
    titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
    titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
    bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
    bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
    labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
    labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
  );
}

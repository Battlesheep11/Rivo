import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: const Color(0xFFF8F8F8),
    primaryColor: const Color(0xFF2B6CB0),
    colorScheme: ColorScheme.light(
      primary: const Color(0xFF2B6CB0),
      secondary: const Color(0xFF68D391),
      surface: Colors.white,
      error: const Color(0xFFE53E3E),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.black87,
      onError: Colors.white,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
      titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black87),
      bodyMedium: TextStyle(fontSize: 16, color: Colors.black87),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2B6CB0),
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(50),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey.shade100,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      errorStyle: const TextStyle(color: Color(0xFFE53E3E)),
    ),
  );

  // Optional: colors you can use inside glass components
  static const Color glassBackground = Color.fromRGBO(255, 255, 255, 0.15);
  static const Color glassBorder = Color.fromRGBO(255, 255, 255, 0.2);
  static const Color darkGlassBackground = Color.fromRGBO(30, 30, 30, 0.25);
}

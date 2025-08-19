import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  static const String fontFamily = 'Sora';

  static final TextTheme textTheme = TextTheme(
    displayLarge: GoogleFonts.sora(fontSize: 48, fontWeight: FontWeight.bold),
    displayMedium: GoogleFonts.sora(fontSize: 36, fontWeight: FontWeight.bold),
    displaySmall: GoogleFonts.sora(fontSize: 28, fontWeight: FontWeight.bold),
    headlineMedium: GoogleFonts.sora(fontSize: 24, fontWeight: FontWeight.w600),
    headlineSmall: GoogleFonts.sora(fontSize: 20, fontWeight: FontWeight.w600),
    titleLarge: GoogleFonts.sora(fontSize: 18, fontWeight: FontWeight.w500),
    titleMedium: GoogleFonts.sora(fontSize: 16, fontWeight: FontWeight.w500),
    bodyLarge: GoogleFonts.sora(fontSize: 16, fontWeight: FontWeight.normal),
    bodyMedium: GoogleFonts.sora(fontSize: 14, fontWeight: FontWeight.normal),
    labelLarge: GoogleFonts.sora(fontSize: 14, fontWeight: FontWeight.w600),
    labelMedium: GoogleFonts.sora(fontSize: 12, fontWeight: FontWeight.w500),
  );
}

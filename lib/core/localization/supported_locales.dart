import 'package:flutter/material.dart';

class SupportedLocales {
  static const List<Locale> locales = [
    Locale('en'),
    Locale('he'),
  ];

  static String getLanguageName(Locale locale) {
    switch (locale.languageCode) {
      case 'he':
        return 'עברית';
      case 'en':
        return 'English';
      default:
        return locale.languageCode;
    }
  }
}

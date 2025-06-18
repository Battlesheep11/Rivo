import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class LocaleStorage {
  static const _localeKey = 'selected_locale';

  Future<void> saveLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale.languageCode);
  }

  Future<Locale?> loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_localeKey);
    if (code == null) return null;
    return Locale(code);
  }
}

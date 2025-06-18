import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'locale_storage.dart';

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<Locale> {
  final LocaleStorage _storage = LocaleStorage();

  LocaleNotifier() : super(const Locale('he')) {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final storedLocale = await _storage.loadLocale();
    if (storedLocale != null) {
      state = storedLocale;
    }
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    await _storage.saveLocale(locale);
  }

  
}

extension LocaleAlign on Locale {
  static const _rtlLanguages = ['ar', 'he', 'fa', 'ur'];

  bool get isRTL => _rtlLanguages.contains(languageCode);

  AlignmentDirectional get startAlignment {
    return isRTL ? AlignmentDirectional.topEnd : AlignmentDirectional.topStart;
  }

  AlignmentDirectional get endAlignment {
    return isRTL ? AlignmentDirectional.topStart : AlignmentDirectional.topEnd;
  }

  AlignmentDirectional get centerStartAlignment {
    return isRTL ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart;
  }

  AlignmentDirectional get centerEndAlignment {
    return isRTL ? AlignmentDirectional.centerStart : AlignmentDirectional.centerEnd;
  }

  TextDirection get textDirection {
    return isRTL ? TextDirection.rtl : TextDirection.ltr;
  }
}





import 'package:flutter/material.dart';
import 'package:formz/formz.dart';
import 'package:rivo_app_beta/core/localization/generated/app_localizations.dart';

/// Enum representing the different password validation errors.
enum PasswordValidationError {
  empty,
  tooShort,
  noUppercase,
  noLowercase,
  noNumber,
  noSpecialChar,
}

/// Extension to get localized error messages for [PasswordValidationError].
extension PasswordValidationErrorExtension on PasswordValidationError {
  String getErrorMessage(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (this) {
      case PasswordValidationError.empty:
        return l10n.passwordValidationEmpty;
      case PasswordValidationError.tooShort:
        return l10n.passwordValidationMinLength;
      case PasswordValidationError.noUppercase:
        return l10n.passwordValidationUppercase;
      case PasswordValidationError.noLowercase:
        return l10n.passwordValidationLowercase;
      case PasswordValidationError.noNumber:
        return l10n.passwordValidationNumber;
      case PasswordValidationError.noSpecialChar:
        return l10n.passwordValidationSpecialChar;
    }
  }
}

/// Formz input model for a password field.
class Password extends FormzInput<String, PasswordValidationError> {
  const Password.pure() : super.pure('');
  const Password.dirty([super.value = '']) : super.dirty();

  static final _upperCaseRegex = RegExp(r'[A-Z]');
  static final _lowerCaseRegex = RegExp(r'[a-z]');
  static final _numberRegex = RegExp(r'[0-9]');
  static final _specialCharRegex = RegExp(r'[!@#$%^&*(),.?\":{}|<>]');

  @override
  PasswordValidationError? validator(String value) {
    if (value.isEmpty) return PasswordValidationError.empty;
    if (value.length < 8) return PasswordValidationError.tooShort;
    if (!_upperCaseRegex.hasMatch(value)) return PasswordValidationError.noUppercase;
    if (!_lowerCaseRegex.hasMatch(value)) return PasswordValidationError.noLowercase;
    if (!_numberRegex.hasMatch(value)) return PasswordValidationError.noNumber;
    if (!_specialCharRegex.hasMatch(value)) return PasswordValidationError.noSpecialChar;
    return null;
  }
}

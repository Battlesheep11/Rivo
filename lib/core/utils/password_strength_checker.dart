import 'package:flutter/material.dart';

enum PasswordStrength {
  weak,
  medium,
  strong,
  verystrong,
}

class PasswordStrengthChecker {
  static PasswordStrength checkStrength(String password) {
    if (password.length < 8) {
      return PasswordStrength.weak;
    }
    bool hasUppercase = password.contains(RegExp(r'[A-Z]'));
    bool hasLowercase = password.contains(RegExp(r'[a-z]'));
    bool hasDigits = password.contains(RegExp(r'[0-9]'));
    bool hasSpecialCharacters = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    int strength = 0;
    if (hasUppercase) strength++;
    if (hasLowercase) strength++;
    if (hasDigits) strength++;
    if (hasSpecialCharacters) strength++;

    if (password.length >= 12 && strength >= 4) {
      return PasswordStrength.verystrong;
    }
    if (password.length >= 12 && strength >= 3) {
      return PasswordStrength.strong;
    }
    if (password.length >= 8 && strength >= 2) {
      return PasswordStrength.medium;
    }
    return PasswordStrength.weak;
  }

  static Color getColor(PasswordStrength strength) {
    switch (strength) {
      case PasswordStrength.weak:
        return Colors.red;
      case PasswordStrength.medium:
        return Colors.orange;
      case PasswordStrength.strong:
        return Colors.yellow;
      case PasswordStrength.verystrong:
        return Colors.green;
    }
  }
}

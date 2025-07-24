import 'package:flutter/material.dart';
import 'package:rivo_app_beta/core/utils/password_strength_checker.dart';
import 'package:rivo_app_beta/core/localization/generated/app_localizations.dart';

class PasswordStrengthIndicator extends StatelessWidget {
  final PasswordStrength strength;

  const PasswordStrengthIndicator({super.key, required this.strength});

  @override
  Widget build(BuildContext context) {
    final color = PasswordStrengthChecker.getColor(strength);
    final localizations = AppLocalizations.of(context)!;

    String strengthText;
    switch (strength) {
      case PasswordStrength.weak:
        strengthText = localizations.passwordStrengthWeak;
        break;
      case PasswordStrength.medium:
        strengthText = localizations.passwordStrengthMedium;
        break;
      case PasswordStrength.strong:
        strengthText = localizations.passwordStrengthStrong;
        break;
      case PasswordStrength.verystrong:
        strengthText = localizations.passwordStrengthVeryStrong;
        break;
    }

    return Row(
      children: [
        Expanded(
          child: LinearProgressIndicator(
            value: (strength.index + 1) / PasswordStrength.values.length,
            backgroundColor: Colors.grey[300],
            color: color,
            minHeight: 6,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          strengthText,
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

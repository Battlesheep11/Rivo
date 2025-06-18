import 'package:flutter/material.dart';
import 'package:rivo_app/core/localization/generated/app_localizations.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key});

  @override
  Widget build(BuildContext context) {
    final logoText = AppLocalizations.of(context)!.logoText;
    return Text(
      logoText,
      style: const TextStyle(
        fontFamily: 'Pacifico',
        fontSize: 42,
        color: Color(0xFF2B6CB0),
        fontWeight: FontWeight.w400,
      ),
    );
  }
}

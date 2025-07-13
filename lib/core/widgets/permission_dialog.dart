import 'package:flutter/material.dart';
import 'package:rivo_app_beta/core/localization/generated/app_localizations.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionDialog {
  static Future<void> show(
    BuildContext context, {
    required String title,
    required String message,
  }) async {
    final tr = AppLocalizations.of(context)!;

    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title, textAlign: TextAlign.start),
        content: Text(message, textAlign: TextAlign.start),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(tr.permissionDialogCancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await openAppSettings();
            },
            child: Text(tr.permissionDialogOpenSettings),
          ),
        ],
      ),
    );
  }
}

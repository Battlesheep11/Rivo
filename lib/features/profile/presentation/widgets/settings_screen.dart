import 'package:flutter/material.dart';
import 'package:rivo_app_beta/core/design_system/design_system.dart';
import 'package:rivo_app_beta/core/localization/generated/app_localizations.dart';
import 'package:rivo_app_beta/features/profile/presentation/screens/profile_screen.dart';


/// Settings screen accessible from the profile gear icon.
/// Currently only contains the logout button.
import 'package:hooks_riverpod/hooks_riverpod.dart';


class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settingsTooltip),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.onSurface,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // TODO: Add more settings here as needed

            // Logout button (already implemented in your app, wire this up)
            ElevatedButton.icon(
              icon: const Icon(Icons.logout),
              label: Text(AppLocalizations.of(context)!.logout),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                // Call logout logic using authViewModelProvider
                await ref.read(authViewModelProvider.notifier).signOut();
                // Optionally, navigate to login screen or root
              },
            ),
          ],
        ),
      ),
    );
  }
}

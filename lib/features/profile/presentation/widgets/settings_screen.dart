import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rivo_app_beta/core/design_system/design_system.dart';
import 'package:rivo_app_beta/core/localization/generated/app_localizations.dart';
import 'package:rivo_app_beta/features/auth/presentation/providers/auth_session_provider.dart';
import 'package:rivo_app_beta/features/profile/presentation/providers/auth_view_model_provider.dart';

/// Settings screen accessible from the profile gear icon.
/// Currently only contains the logout button.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final user = ref.watch(authSessionProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsTooltip),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.onSurface,
        elevation: 1,
      ),
      body: user == null
          ? _buildNotSignedInView(l10n)
          : _buildSettingsList(context, ref, l10n),
    );
  }

  Widget _buildNotSignedInView(AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Text(
          l10n.signInToAccessSettings,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildSettingsList(
      BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Logout Section
        Card(
          child: ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: Text(
              l10n.logout,
              style: const TextStyle(color: Colors.red),
            ),
            onTap: () async {
              await ref.read(authViewModelProvider.notifier).signOut();
            },
          ),
        ),
      ],
    );
  }
}

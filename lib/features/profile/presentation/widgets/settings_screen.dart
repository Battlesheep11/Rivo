import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rivo_app_beta/core/design_system/design_system.dart';
import 'package:rivo_app_beta/core/localization/generated/app_localizations.dart';
import 'package:rivo_app_beta/features/auth/presentation/providers/auth_session_provider.dart';
import 'package:rivo_app_beta/features/profile/presentation/providers/auth_view_model_provider.dart';
import 'package:rivo_app_beta/features/settings/presentation/providers/settings_providers.dart';
import 'package:rivo_app_beta/features/settings/presentation/widgets/post_upload_preferences_dialog.dart';


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
      body: user == null ? _buildNotSignedInView(l10n) : _buildSettingsContent(context, ref, user.id, l10n),
    );
  }

  Widget _buildNotSignedInView(AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Text(
          'Please sign in to access settings',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildSettingsContent(BuildContext context, WidgetRef ref, String userId, AppLocalizations l10n) {
    final settingsState = ref.watch(settingsViewModelProvider(userId));

    return settingsState.when(
      initial: () => const Center(child: CircularProgressIndicator()),
      loading: () => const Center(child: CircularProgressIndicator()),
      success: (preferences) => _buildSettingsList(context, ref, userId, l10n),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error loading settings: $error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.refresh(settingsViewModelProvider(userId)),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsList(BuildContext context, WidgetRef ref, String userId, AppLocalizations l10n) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Post Upload Section
        Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  l10n.postUpload,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListTile(
                title: Text(l10n.postUploadPreferences),
                subtitle: Text(l10n.postUploadPreferencesSubtitle),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => PostUploadPreferencesDialog(userId: userId),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        
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

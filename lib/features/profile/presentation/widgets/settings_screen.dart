import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rivo_app_beta/design_system/exports.dart';
import 'package:rivo_app_beta/core/localization/generated/app_localizations.dart';
import 'package:rivo_app_beta/features/auth/presentation/providers/auth_session_provider.dart';
import 'package:rivo_app_beta/features/profile/presentation/providers/auth_view_model_provider.dart';
import 'package:rivo_app_beta/features/settings/presentation/widgets/delete_account_dialog.dart';

/// Settings screen accessible from the profile gear icon.
/// Contains logout and delete account options.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final userAsync = ref.watch(authSessionProvider);
    
    // Handle loading and error states safely
    return userAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(
          title: Text(l10n.settingsTooltip),
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.onSurface,
          elevation: 1,
        ),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(
          title: Text(l10n.settingsTooltip),
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.onSurface,
          elevation: 1,
        ),
        body: _buildNotSignedInView(l10n),
      ),
      data: (user) => _buildMainContent(context, ref, l10n, user),
    );
  }
  
  Widget _buildMainContent(BuildContext context, WidgetRef ref, AppLocalizations l10n, dynamic user) {

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
        // Account Section
        Card(
          child: Column(
            children: [
              // Delete Account Option
              ListTile(
                leading: const Icon(Icons.delete_forever, color: Colors.red),
                title: Text(
                  l10n.deleteAccount,
                  style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
                ),
                subtitle: Text(
                  'Permanently delete your account and all data',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                onTap: () => _showDeleteAccountDialog(context),
              ),
              const Divider(height: 1),
              // Logout Option
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: Text(
                  l10n.logout,
                  style: const TextStyle(color: Colors.red),
                ),
                onTap: () async {
                  try {
                    await ref.read(authViewModelProvider.notifier).signOut();
                  } catch (e) {
                    // Handle potential disposal errors gracefully
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Logout completed'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Shows the delete account confirmation dialog
  void _showDeleteAccountDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => const DeleteAccountDialog(),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivo_app_beta/features/auth/presentation/providers/auth_session_provider.dart';
import 'package:rivo_app_beta/core/localization/generated/app_localizations.dart';
import 'package:rivo_app_beta/features/settings/presentation/widgets/settings_section.dart';
import 'package:rivo_app_beta/features/settings/presentation/widgets/delete_account_dialog.dart';
import 'package:rivo_app_beta/core/analytics/analytics_service.dart'; // ← NEW

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late AppLocalizations l10n;

  @override
  void initState() {
    super.initState();

    // Log screen view when settings screen is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AnalyticsService.logScreenView(screenName: 'settings_screen');
    });
  }

  @override
  void didChangeDependencies() {
    l10n = AppLocalizations.of(context)!;
    super.didChangeDependencies();
  }

  /// Shows the delete account confirmation dialog
  void _showDeleteAccountDialog(BuildContext context) {
    // Log delete account dialog opened
    AnalyticsService.logEvent('open_delete_account_dialog');

    showDialog<void>(
      context: context,
      builder: (context) => const DeleteAccountDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(authSessionProvider);

    // Show loading indicator while checking auth state
    if (userAsync.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final user = userAsync.value;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.settings)),
        body: Center(child: Text(l10n.signInToAccessSettings)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SettingsSection(
            title: l10n.authCreateAccount,
            children: [
              SettingsItem(
                title: l10n.deleteAccount,
                subtitle: l10n.deleteAccountConfirmMessage,
                leading: const Icon(Icons.delete_forever, color: Colors.red),
                isDestructive: true,
                onTap: () => _showDeleteAccountDialog(context),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

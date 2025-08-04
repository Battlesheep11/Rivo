import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivo_app_beta/features/auth/presentation/providers/auth_session_provider.dart';
import 'package:rivo_app_beta/features/settings/presentation/providers/settings_providers.dart';

import 'package:rivo_app_beta/features/settings/presentation/widgets/post_upload_preferences_dialog.dart';
import 'package:rivo_app_beta/core/localization/generated/app_localizations.dart';


class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late AppLocalizations l10n;
  @override
  void didChangeDependencies() {
    l10n = AppLocalizations.of(context)!;
    super.didChangeDependencies();
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
        body: const Center(child: Text('Please sign in to access settings')),
      );
    }
    
    final settingsState = ref.watch(settingsViewModelProvider(user.id));
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: settingsState.when(
        initial: () => const Center(child: CircularProgressIndicator()),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error loading settings: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.read(settingsViewModelProvider(user.id).notifier).loadPreferences(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        success: (preferences) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Post Upload Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.postUpload,
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    ListTile(
                      title: Text(l10n.postUploadPreferences),
                      subtitle: Text(l10n.postUploadPreferencesSubtitle),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => PostUploadPreferencesDialog(userId: user.id),
                        );
                      },
                    ),

                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivo_app_beta/core/localization/generated/app_localizations.dart';
import 'package:rivo_app_beta/features/settings/presentation/providers/settings_providers.dart';
import 'package:rivo_app_beta/features/settings/domain/entities/user_preferences.dart';
import 'package:rivo_app_beta/core/state/app_state.dart';

class PostUploadPreferencesDialog extends ConsumerStatefulWidget {
  final String userId;

  const PostUploadPreferencesDialog({
    super.key,
    required this.userId,
  });

  @override
  ConsumerState<PostUploadPreferencesDialog> createState() =>
      _PostUploadPreferencesDialogState();
}

class _PostUploadPreferencesDialogState
    extends ConsumerState<PostUploadPreferencesDialog> {
  late bool showDialogPref;
  late bool autoNavigatePref;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final settingsState = ref.read(settingsViewModelProvider(widget.userId));
    final currentPrefs = settingsState.maybeWhen(
      success: (data) => data,
      orElse: () => null,
    );
    showDialogPref = currentPrefs?.showPostUploadSuccessDialog ?? true;
    autoNavigatePref = currentPrefs?.autoNavigateToPostAfterUpload ?? false;
  }

  Future<void> _savePreferences() async {
    setState(() => _isLoading = true);

    final viewModel = ref.read(settingsViewModelProvider(widget.userId).notifier);
    final settingsState = ref.read(settingsViewModelProvider(widget.userId));

    if (settingsState is SuccessAppState<UserPreferences>) {
      final currentPreferences = settingsState.data;
      final newPreferences = currentPreferences.copyWith(
        showPostUploadSuccessDialog: showDialogPref,
        autoNavigateToPostAfterUpload: autoNavigatePref,
      );
      await viewModel.updatePreferences(newPreferences);
    }

    if (mounted) {
      Navigator.of(context).pop(true); // Return true to indicate save
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.postUploadPreferencesUpdated)),
      );
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return AlertDialog(
      title: Text(l10n.postUploadPreferences),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.postUploadPreferencesSubtitle),
            const SizedBox(height: 16),
            SwitchListTile(
              title: Text(l10n.showPostUploadDialog),
              subtitle: Text(l10n.showPostUploadDialogSubtitle),
              value: showDialogPref,
              onChanged: (value) => setState(() => showDialogPref = value),
            ),
            SwitchListTile(
              title: Text(l10n.autoNavigateToPost),
              subtitle: Text(l10n.autoNavigateToPostSubtitle),
              value: autoNavigatePref,
              onChanged: (value) => setState(() => autoNavigatePref = value),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _savePreferences,
          child: _isLoading
              ? const CircularProgressIndicator()
              : Text(MaterialLocalizations.of(context).okButtonLabel),
        ),
      ],
    );
  }
}

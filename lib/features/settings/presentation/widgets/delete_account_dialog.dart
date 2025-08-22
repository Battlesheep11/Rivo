import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rivo_app_beta/core/localization/generated/app_localizations.dart';
import 'package:rivo_app_beta/core/analytics/analytics_service.dart'; // ← NEW

/// Dialog widget for confirming account deletion
class DeleteAccountDialog extends StatefulWidget {
  const DeleteAccountDialog({super.key});

  @override
  State<DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<DeleteAccountDialog> {
  late AppLocalizations l10n;
  bool _isDeleting = false;

  @override
  void didChangeDependencies() {
    l10n = AppLocalizations.of(context)!;
    super.didChangeDependencies();
  }

  /// Handles the delete account action
  Future<void> _handleDeleteAccount() async {
    if (!mounted) return;

    setState(() {
      _isDeleting = true;
    });

    try {
      final supabaseClient = Supabase.instance.client;
      final response = await supabaseClient.functions.invoke('delete_user_self');

      if (!mounted) return;

      if (response.status >= 400) {
        setState(() => _isDeleting = false);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete account. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // ✅ Log successful deletion event
      await AnalyticsService.logEvent('account_deleted');

      await supabaseClient.auth.signOut();

      if (!mounted) return;

      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }

      if (context.mounted) {
        context.go('/onboarding');
      }

    } catch (e) {
      if (!mounted) return;

      setState(() => _isDeleting = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Network error. Please check your connection and try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Delete Account'),
      content: Text('Are you sure you want to delete your account? This action cannot be undone and will permanently remove all your data.'),
      actions: [
        TextButton(
          onPressed: _isDeleting ? null : () => context.pop(),
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: _isDeleting ? null : _handleDeleteAccount,
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: _isDeleting
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: 8),
                    Text('Deleting account...'),
                  ],
                )
              : Text('Delete'),
        ),
      ],
    );
  }
}

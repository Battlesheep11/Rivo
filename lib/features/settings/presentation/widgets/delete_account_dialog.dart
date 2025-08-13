import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rivo_app_beta/core/localization/generated/app_localizations.dart';

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
    // Early exit if widget is not mounted
    if (!mounted) return;
    
    setState(() {
      _isDeleting = true;
    });
    
    try {
      // Call the Supabase Edge Function directly
      final supabaseClient = Supabase.instance.client;
      final response = await supabaseClient.functions.invoke('delete_user_self');
      
      if (!mounted) return;
      
      if (response.status >= 400) {
        // Handle error
        setState(() {
          _isDeleting = false;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete account. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
      
      // Success - sign out and navigate
      await supabaseClient.auth.signOut();
      
      if (!mounted) return;
      
      // Close dialog
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }
      
      // Navigate to onboarding
      if (context.mounted) {
        context.go('/onboarding');
      }
      
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _isDeleting = false;
      });
      
      // Handle errors only if still mounted
      if (mounted && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Network error. Please check your connection and try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    return AlertDialog(
      title: Text('Delete Account'),
      content: Text('Are you sure you want to delete your account? This action cannot be undone and will permanently remove all your data.'),
      actions: [
        // Cancel button
        TextButton(
          onPressed: _isDeleting ? null : () => context.pop(),
          child: Text('Cancel'),
        ),
        
        // Delete button
        TextButton(
          onPressed: _isDeleting ? null : _handleDeleteAccount,
          style: TextButton.styleFrom(
            foregroundColor: Colors.red,
          ),
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

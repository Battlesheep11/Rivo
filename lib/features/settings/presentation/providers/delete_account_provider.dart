import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rivo_app_beta/features/auth/domain/repositories/delete_user_repository.dart';
import 'package:rivo_app_beta/features/auth/domain/repositories/delete_user_repository_provider.dart';

/// Enum representing the different states of account deletion process
enum DeleteAccountState {
  idle,
  deleting,
  success,
  error,
}

/// State notifier for managing account deletion process
class DeleteAccountNotifier extends StateNotifier<DeleteAccountState> {
  final DeleteUserRepository _deleteUserRepository;
  final SupabaseClient _supabaseClient;
  bool _isDisposed = false;

  DeleteAccountNotifier(this._deleteUserRepository, this._supabaseClient)
      : super(DeleteAccountState.idle);

  /// Deletes the current user's account
  /// Returns true if successful, false if failed
  Future<bool> deleteAccount() async {
    try {
      // Set state to deleting to show loading indicator
      if (!_isDisposed && mounted) {
        state = DeleteAccountState.deleting;
      }

      // Call the repository to delete the user account
      await _deleteUserRepository.deleteUser();

      // Sign out the user after successful deletion
      await _supabaseClient.auth.signOut();

      // Set state to success only if not disposed
      if (!_isDisposed && mounted) {
        state = DeleteAccountState.success;
      }
      return true;
    } catch (e) {
      // Set state to error if deletion failed and not disposed
      if (!_isDisposed && mounted) {
        state = DeleteAccountState.error;
      }
      return false;
    }
  }

  /// Resets the state back to idle
  void resetState() {
    if (!_isDisposed && mounted) {
      state = DeleteAccountState.idle;
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}

/// Provider for the delete account notifier
final deleteAccountProvider =
    StateNotifierProvider<DeleteAccountNotifier, DeleteAccountState>((ref) {
  final deleteUserRepository = ref.read(deleteUserRepositoryProvider);
  final supabaseClient = Supabase.instance.client;
  return DeleteAccountNotifier(deleteUserRepository, supabaseClient);
});

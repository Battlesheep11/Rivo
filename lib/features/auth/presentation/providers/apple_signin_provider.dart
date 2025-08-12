import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rivo_app_beta/features/auth/domain/repositories/auth_repository_provider.dart';

class AppleSignInViewModel extends StateNotifier<bool> {
  AppleSignInViewModel({
    required this.repository,
    required this.ref,
    required this.context,
  }) : super(false);

  final dynamic repository; // type from your authRepositoryProvider
  final Ref ref;
  final BuildContext context;

  Future<void> signInWithApple() async {
    if (state) return;
    state = true;
    try {
      await repository.signInWithApple(); // <- make sure your repository exposes this
      // Navigation is handled elsewhere by your authStateChanges listener.
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Apple sign-in failed: $e')),
        );
      }
    } finally {
      state = false;
    }
  }
}

final appleSignInViewModelProvider =
    StateNotifierProvider.autoDispose
        .family<AppleSignInViewModel, bool, BuildContext>((ref, context) {
  final repository = ref.read(authRepositoryProvider);
  return AppleSignInViewModel(repository: repository, ref: ref, context: context);
});

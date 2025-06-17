import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rivo_app/core/loading/loading_overlay_provider.dart';
import 'package:rivo_app/core/toast/toast_service.dart';
import 'package:rivo_app/features/auth/domain/repositories/auth_repository.dart';

class GoogleSignInViewModel extends StateNotifier<bool> {
  final AuthRepository repository;
  final Ref ref;
  final BuildContext context;

  GoogleSignInViewModel({
    required this.repository,
    required this.ref,
    required this.context,
  }) : super(false);

  Future<void> signInWithGoogle() async {
    final overlay = ref.read(loadingOverlayProvider);

    try {
      overlay.show(context);
      state = true;

      await repository.signInWithGoogle();

      ToastService().showSuccess('Google sign-in started!');
    } catch (e) {
      ToastService().showError('Google sign-in failed');
    } finally {
      overlay.hide();
      state = false;
    }
  }
}

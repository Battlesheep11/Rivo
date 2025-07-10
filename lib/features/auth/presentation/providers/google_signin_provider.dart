import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rivo_app_beta/features/auth/domain/repositories/auth_repository_provider.dart';
import 'package:rivo_app_beta/features/auth/presentation/viewmodels/google_signin_view_model.dart';

final googleSignInViewModelProvider = StateNotifierProvider.autoDispose
    .family<GoogleSignInViewModel, bool, BuildContext>((ref, context) {
  final repository = ref.read(authRepositoryProvider);
  return GoogleSignInViewModel(repository: repository, ref: ref, context: context);
});

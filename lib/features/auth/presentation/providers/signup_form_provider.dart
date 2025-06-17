import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivo_app/features/auth/domain/repositories/auth_repository_provider.dart';
import 'package:rivo_app/features/auth/presentation/viewmodels/signup_form_view_model.dart';

final signupFormViewModelProvider = StateNotifierProvider.autoDispose
    .family<SignupFormViewModel, SignupFormState, BuildContext>((ref, context) {
  final repository = ref.read(authRepositoryProvider);
  return SignupFormViewModel(repository: repository, ref: ref, context: context);
});

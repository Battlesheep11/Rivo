import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivo_app_beta/features/auth/domain/repositories/auth_repository_provider.dart';
import 'package:rivo_app_beta/features/auth/presentation/viewmodels/signin_form_view_model.dart';


final signinFormViewModelProvider = StateNotifierProvider.autoDispose
    .family<SigninFormViewModel, SigninFormState, BuildContext>((ref, context) {
  final repository = ref.read(authRepositoryProvider);
  return SigninFormViewModel(repository: repository, ref: ref, context: context);
});

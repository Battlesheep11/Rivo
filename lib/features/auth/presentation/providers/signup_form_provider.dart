import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivo_app_beta/features/auth/domain/repositories/auth_repository_provider.dart';
import 'package:rivo_app_beta/features/auth/presentation/viewmodels/signup_form_view_model.dart';

final signupFormViewModelProvider = StateNotifierProvider.autoDispose<
    SignupFormViewModel, SignupFormState>((ref) {
  final repository = ref.read(authRepositoryProvider);
  return SignupFormViewModel(repository: repository, ref: ref);
});

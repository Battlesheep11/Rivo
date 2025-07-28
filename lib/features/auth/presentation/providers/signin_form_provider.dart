import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivo_app_beta/features/auth/domain/repositories/auth_repository_provider.dart';
import 'package:rivo_app_beta/features/auth/presentation/viewmodels/signin_form_view_model.dart';


final signinFormViewModelProvider = StateNotifierProvider<SigninFormViewModel, SigninFormState>((ref) {
  final repository = ref.read(authRepositoryProvider);
  return SigninFormViewModel(repository: repository, ref: ref);
});

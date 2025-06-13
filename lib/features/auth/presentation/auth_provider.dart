import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'auth_view_model.dart';
import 'package:rivo_app/features/auth/data/repositories/auth_repository_provider.dart';
import 'auth_state.dart';

final authViewModelProvider =
    StateNotifierProvider<AuthViewModel, AuthState>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  return AuthViewModel(authRepository);
});

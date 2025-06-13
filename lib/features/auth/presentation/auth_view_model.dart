import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rivo_app/features/auth/domain/repositories/auth_repository.dart';


import 'auth_state.dart';

class AuthViewModel extends StateNotifier<AuthState> {
  final AuthRepository authRepository;

  AuthViewModel(this.authRepository) : super(const AuthState.initial());

  Future<void> signIn(String email, String password) async {
    state = const AuthState.loading();
    try {
      final result = await authRepository.signIn(email: email, password: password);
      result.fold(
        (failure) => state = AuthState.error(failure),
        (_) => state = const AuthState.authenticated(),
      );
    } catch (e) {
      state = AuthState.error('Unexpected error occurred');
    }
  }

  Future<void> signUp(String email, String password) async {
    state = const AuthState.loading();
    try {
      final result = await authRepository.signUp(email: email, password: password);
      result.fold(
        (failure) => state = AuthState.error(failure),
        (_) => state = const AuthState.authenticated(),
      );
    } catch (e) {
      state = AuthState.error('Unexpected error occurred');
    }
  }

  Future<void> signOut() async {
    try {
      await authRepository.signOut();
      state = const AuthState.initial();
    } catch (e) {
      state = AuthState.error('Failed to sign out');
    }
  }
}

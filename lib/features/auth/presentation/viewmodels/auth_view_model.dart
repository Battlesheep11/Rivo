import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivo_app_beta/features/auth/presentation/state/auth_state.dart';
import 'package:rivo_app_beta/features/auth/domain/repositories/auth_repository.dart';
class AuthViewModel extends StateNotifier<AuthState> {
  final AuthRepository repository;

  AuthViewModel({required this.repository}) : super(const AuthState.initial());

    Future<void> signUp({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    required String password,
  }) async {
    state = const AuthState.loading();
    final result = await repository.signUp(
        firstName: firstName, lastName: lastName, username: username, email: email, password: password);

    result.fold(
      (failure) => state = AuthState.error(failure),
      (user) => state = AuthState.authenticated(user),
    );
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = const AuthState.loading();
    final result = await repository.signIn(email: email, password: password);

    result.fold(
      (failure) => state = AuthState.error(failure),
      (user) => state = AuthState.authenticated(user),
    );
  }

  Future<void> signOut() async {
    state = const AuthState.loading();
    final result = await repository.signOut();

    result.fold(
      (failure) => state = AuthState.error(failure),
      (_) => state = const AuthState.initial(),
    );
  }

  Future<void> loadCurrentUser() async {
    state = const AuthState.loading();
    final result = await repository.getCurrentUser();

    result.fold(
      (failure) => state = AuthState.error(failure),
      (user) {
        if (user != null) {
          state = AuthState.authenticated(user);
        } else {
          state = const AuthState.initial();
        }
      },
    );
  }
}

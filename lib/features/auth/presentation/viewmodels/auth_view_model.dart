import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivo_app_beta/features/auth/presentation/state/auth_state.dart';
import 'package:rivo_app_beta/features/auth/domain/repositories/auth_repository.dart';
class AuthViewModel extends StateNotifier<AuthState> {
  final AuthRepository repository;
  bool _isDisposed = false;

  AuthViewModel({required this.repository}) : super(const AuthState.initial());
  
  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
  
  /// Safely updates state only if not disposed
  void _safeSetState(AuthState newState) {
    if (!_isDisposed && mounted) {
      state = newState;
    }
  }

    Future<void> signUp({
    required String username,
    required String email,
    required String password,
  }) async {
    _safeSetState(const AuthState.loading());
    final result = await repository.signUp(
        username: username, email: email, password: password);

    result.fold(
      (failure) => _safeSetState(AuthState.error(failure)),
      (user) => _safeSetState(AuthState.authenticated(user)),
    );
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    _safeSetState(const AuthState.loading());
    final result = await repository.signIn(email: email, password: password);

    result.fold(
      (failure) => _safeSetState(AuthState.error(failure)),
      (user) => _safeSetState(AuthState.authenticated(user)),
    );
  }

  Future<void> signOut() async {
    _safeSetState(const AuthState.loading());
    final result = await repository.signOut();

    result.fold(
      (failure) => _safeSetState(AuthState.error(failure)),
      (_) => _safeSetState(const AuthState.initial()),
    );
  }

  Future<void> loadCurrentUser() async {
    _safeSetState(const AuthState.loading());
    final result = await repository.getCurrentUser();

    result.fold(
      (failure) => _safeSetState(AuthState.error(failure)),
      (user) {
        if (user != null) {
          _safeSetState(AuthState.authenticated(user));
        } else {
          _safeSetState(const AuthState.initial());
        }
      },
    );
  }
}

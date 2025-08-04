import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivo_app_beta/features/auth/domain/repositories/auth_repository.dart';
import 'package:rivo_app_beta/features/auth/domain/repositories/auth_repository_provider.dart';
import 'package:dartz/dartz.dart';

class ForgotPasswordState {
  final bool isSubmitting;
  final bool isSuccess;
  final String? error;

  ForgotPasswordState({
    this.isSubmitting = false,
    this.isSuccess = false,
    this.error,
  });

  ForgotPasswordState copyWith({
    bool? isSubmitting,
    bool? isSuccess,
    String? error,
  }) {
    return ForgotPasswordState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      error: error ?? this.error,
    );
  }
}

class ForgotPasswordViewModel extends StateNotifier<ForgotPasswordState> {
  final AuthRepository _authRepository;

  ForgotPasswordViewModel(this._authRepository) : super(ForgotPasswordState());

  Future<Either<String, bool>> sendPasswordResetEmail(String email) async {
    state = state.copyWith(isSubmitting: true, error: null);
    
    try {
      final result = await _authRepository.sendPasswordResetEmail(email);
      
      return result.fold(
        (error) {
          state = state.copyWith(isSubmitting: false, error: error);
          return Left(error);
        },
        (success) {
          state = state.copyWith(isSubmitting: false, isSuccess: true);
          return const Right(true);
        },
      );
    } catch (e) {
      final error = 'An unexpected error occurred. Please try again.';
      state = state.copyWith(isSubmitting: false, error: error);
      return Left(error);
    }
  }
}

// Provider
final forgotPasswordViewModelProvider =
    StateNotifierProvider<ForgotPasswordViewModel, ForgotPasswordState>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return ForgotPasswordViewModel(authRepository);
});

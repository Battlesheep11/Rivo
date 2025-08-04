import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivo_app_beta/features/auth/domain/repositories/auth_repository.dart';
import 'package:rivo_app_beta/features/auth/domain/repositories/auth_repository_provider.dart';
import 'package:dartz/dartz.dart';

class ResetPasswordState {
  final bool isSubmitting;
  final bool isSuccess;
  final String? error;

  ResetPasswordState({
    this.isSubmitting = false,
    this.isSuccess = false,
    this.error,
  });

  ResetPasswordState copyWith({
    bool? isSubmitting,
    bool? isSuccess,
    String? error,
  }) {
    return ResetPasswordState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      error: error ?? this.error,
    );
  }
}

class ResetPasswordViewModel extends StateNotifier<ResetPasswordState> {
  final AuthRepository _authRepository;

  ResetPasswordViewModel(this._authRepository) : super(ResetPasswordState());

  Future<Either<String, bool>> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    state = state.copyWith(isSubmitting: true, error: null);
    
    try {
      final result = await _authRepository.resetPassword(
        token: token,
        newPassword: newPassword,
      );
      
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
final resetPasswordViewModelProvider =
    StateNotifierProvider<ResetPasswordViewModel, ResetPasswordState>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return ResetPasswordViewModel(authRepository);
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  ForgotPasswordViewModel() : super(ForgotPasswordState());

  Future<Either<String, bool>> sendPasswordResetEmail(String email) async {
    // Feature removed: always report failure quickly
    state = state.copyWith(isSubmitting: false, isSuccess: false, error: null);
    // Return empty error to avoid hardcoded string in UI
    return const Left('');
  }
}

// Provider
final forgotPasswordViewModelProvider =
    StateNotifierProvider<ForgotPasswordViewModel, ForgotPasswordState>((ref) {
  return ForgotPasswordViewModel();
});

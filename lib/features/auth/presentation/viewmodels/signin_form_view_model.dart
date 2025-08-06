import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivo_app_beta/core/security/rate_limiter_service.dart';
import 'package:rivo_app_beta/core/toast/toast_service.dart';
import 'package:rivo_app_beta/features/auth/domain/repositories/auth_repository.dart';
import 'package:rivo_app_beta/features/auth/presentation/forms/email.dart';
import 'package:rivo_app_beta/features/auth/presentation/forms/password.dart';

class SigninFormState {
  final Email email;
  final Password password;
  final bool isValid;
  final bool isSubmitting;
  final bool isSuccess;
  final bool isFailure;
  final String? errorMessage;

  SigninFormState({
    this.email = const Email.pure(),
    this.password = const Password.pure(),
    this.isValid = false,
    this.isSubmitting = false,
    this.isSuccess = false,
    this.isFailure = false,
    this.errorMessage,
  });

  SigninFormState copyWith({
    Email? email,
    Password? password,
    bool? isValid,
    bool? isSubmitting,
    bool? isSuccess,
    bool? isFailure,
    String? errorMessage,
  }) {
    return SigninFormState(
      email: email ?? this.email,
      password: password ?? this.password,
      isValid: isValid ?? this.isValid,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      isFailure: isFailure ?? this.isFailure,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class SigninFormViewModel extends StateNotifier<SigninFormState> {
  final AuthRepository repository;
  final Ref ref;

  /// ViewModel no longer stores BuildContext; context is only passed to submit().
  SigninFormViewModel({
    required this.repository,
    required this.ref,
  }) : super(SigninFormState());

  void onEmailChanged(String value) {
    final email = Email.dirty(value);
    final password = state.password;
    // For login, only require password to be non-empty (not strong)
    final isValid = email.isValid && password.value.isNotEmpty; // allow weak passwords for login
    state = state.copyWith(
      email: email,
      isValid: isValid,
    );
  }

  void onPasswordChanged(String value) {
    final password = Password.dirty(value);
    final email = state.email;
    // For login, only require password to be non-empty (not strong)
    final isValid = email.isValid && password.value.isNotEmpty; // allow weak passwords for login
    state = state.copyWith(
      password: password,
      isValid: isValid,
    );
  }

  Future<void> submit(BuildContext context) async {
    if (!state.isValid || state.isSubmitting) return;

    // Check rate limiting before attempting login
    final rateLimiter = RateLimiterService();
    final rateLimitError = rateLimiter.checkLoginAttempt(state.email.value);
    
    if (rateLimitError != null) {
      state = state.copyWith(
        isSubmitting: false,
        isFailure: true,
        errorMessage: rateLimitError,
      );
      ToastService().showError(rateLimitError);
      return;
    }

    state = state.copyWith(isSubmitting: true, isFailure: false, isSuccess: false);

    try {
      final result = await repository.signIn(
        email: state.email.value,
        password: state.password.value,
      );

      result.fold(
        (failure) {
          // Record failed login attempt
          rateLimiter.recordLoginAttempt(state.email.value);
          
          // Check rate limit again in case we just hit the threshold
          final rateLimitError = rateLimiter.checkLoginAttempt(state.email.value);
          final errorMessage = rateLimitError ?? 'Invalid email or password. Please try again.';
          
          state = state.copyWith(
            isSubmitting: false,
            isFailure: true,
            errorMessage: errorMessage,
          );
          ToastService().showError(errorMessage);
        },
        (user) {
          // Reset rate limiting on successful login
          rateLimiter.resetLoginAttempts(state.email.value);
          state = state.copyWith(isSubmitting: false, isSuccess: true);
          // Navigation will be handled by ref.listen in the UI
        },
      );
    } catch (e) {
      // Record failed login attempt on exception
      rateLimiter.recordLoginAttempt(state.email.value);
      final errorMessage = 'An unexpected error occurred. Please try again.';
      state = state.copyWith(
        isSubmitting: false,
        isFailure: true,
        errorMessage: errorMessage,
      );
      ToastService().showError(errorMessage);
      developer.log('Login error: $e', error: e, stackTrace: StackTrace.current);
    }
  }

  /// Clears the current error message from the state.
  void clearError() {
    if (state.isFailure) {
      state = state.copyWith(isFailure: false, errorMessage: null);
    }
  }
}

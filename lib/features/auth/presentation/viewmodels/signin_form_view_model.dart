import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivo_app_beta/core/localization/generated/app_localizations.dart';
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
    final isValid = email.isValid && password.isValid;
    state = state.copyWith(
      email: email,
      isValid: isValid,
    );
  }

  void onPasswordChanged(String value) {
    final password = Password.dirty(value);
    final email = state.email;
    final isValid = email.isValid && password.isValid;
    state = state.copyWith(
      password: password,
      isValid: isValid,
    );
  }

  Future<void> submit(BuildContext context) async {
    if (!state.isValid || state.isSubmitting) return;

    state = state.copyWith(isSubmitting: true, isFailure: false, isSuccess: false);

    final result = await repository.signIn(
      email: state.email.value,
      password: state.password.value,
    );

    result.fold(
      (failure) {
        final userError = AppLocalizations.of(context)!.authInvalidCredentials;
        state = state.copyWith(isSubmitting: false, isFailure: true, errorMessage: userError);
        ToastService().showError(userError); // A toast is fine for transient errors
      },
      (user) {
        state = state.copyWith(isSubmitting: false, isSuccess: true);
        // Navigation will be handled by ref.listen in the UI
      },
    );
  }

  /// Clears the current error message from the state.
  void clearError() {
    if (state.isFailure) {
      state = state.copyWith(isFailure: false, errorMessage: null);
    }
  }
}

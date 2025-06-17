import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:formz/formz.dart';
import 'package:rivo_app/core/loading/loading_overlay_provider.dart';
import 'package:rivo_app/core/toast/toast_service.dart';
import 'package:rivo_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:rivo_app/features/auth/presentation/forms/email.dart';
import 'package:rivo_app/features/auth/presentation/forms/password.dart';

class SignupFormState {
  final Email email;
  final Password password;
  final bool isValid;
  final bool isSubmitting;
  final bool isSuccess;
  final bool isFailure;
  final String? errorMessage;

  SignupFormState({
    this.email = const Email.pure(),
    this.password = const Password.pure(),
    this.isValid = false,
    this.isSubmitting = false,
    this.isSuccess = false,
    this.isFailure = false,
    this.errorMessage,
  });

  SignupFormState copyWith({
    Email? email,
    Password? password,
    bool? isValid,
    bool? isSubmitting,
    bool? isSuccess,
    bool? isFailure,
    String? errorMessage,
  }) {
    return SignupFormState(
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

class SignupFormViewModel extends StateNotifier<SignupFormState> {
  final AuthRepository repository;
  final Ref ref;
  final BuildContext context;

  SignupFormViewModel({
    required this.repository,
    required this.ref,
    required this.context,
  }) : super(SignupFormState());

  void onEmailChanged(String value) {
    final email = Email.dirty(value);
    final isValid = Formz.validate([email, state.password]);
    state = state.copyWith(
      email: email,
      isValid: isValid,
    );
  }

  void onPasswordChanged(String value) {
    final password = Password.dirty(value);
    final isValid = Formz.validate([state.email, password]);
    state = state.copyWith(
      password: password,
      isValid: isValid,
    );
  }

  Future<bool> submit() async {
    if (!state.isValid) return false;

    final overlay = ref.read(loadingOverlayProvider);
    state = state.copyWith(isSubmitting: true, isFailure: false, isSuccess: false);

    overlay.show(context);

    final result = await repository.signUp(
      email: state.email.value,
      password: state.password.value,
    );

    overlay.hide();

    bool success = false;

    result.fold(
      (failure) {
        state = state.copyWith(isSubmitting: false, isFailure: true, errorMessage: failure);
        ToastService().showError(failure);
        success = false;
      },
      (user) {
        state = state.copyWith(isSubmitting: false, isSuccess: true);
        ToastService().showSuccess("Success");
        success = true;
      },
    );

    return success;
  }
}

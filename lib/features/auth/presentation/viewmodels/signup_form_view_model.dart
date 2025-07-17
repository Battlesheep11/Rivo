import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:formz/formz.dart';
import 'package:rivo_app_beta/core/loading/loading_overlay_provider.dart';
import 'package:rivo_app_beta/core/toast/toast_service.dart';
import 'package:rivo_app_beta/features/auth/domain/repositories/auth_repository.dart';
import 'package:rivo_app_beta/features/auth/presentation/forms/confirmed_password.dart';
import 'package:rivo_app_beta/features/auth/presentation/forms/email.dart';
import 'package:rivo_app_beta/features/auth/presentation/forms/full_name.dart';
import 'package:rivo_app_beta/features/auth/presentation/forms/password.dart';
import 'package:rivo_app_beta/features/auth/presentation/forms/username.dart';

class SignupFormState {
  final FullName fullName;
  final Username username;
  final Email email;
  final Password password;
  final ConfirmedPassword confirmedPassword;
    final bool isStep1Valid;
  final bool isValid;
  final bool isSubmitting;
  final bool isSuccess;
  final bool isFailure;
  final String? errorMessage;

  SignupFormState({
    this.fullName = const FullName.pure(),
    this.username = const Username.pure(),
    this.email = const Email.pure(),
    this.password = const Password.pure(),
    this.confirmedPassword = const ConfirmedPassword.pure(),
        this.isStep1Valid = false,
    this.isValid = false,
    this.isSubmitting = false,
    this.isSuccess = false,
    this.isFailure = false,
    this.errorMessage,
  });

  SignupFormState copyWith({
    FullName? fullName,
    Username? username,
    Email? email,
    Password? password,
        ConfirmedPassword? confirmedPassword,
    bool? isStep1Valid,
    bool? isValid,
    bool? isSubmitting,
    bool? isSuccess,
    bool? isFailure,
    String? errorMessage,
  }) {
    return SignupFormState(
      fullName: fullName ?? this.fullName,
      username: username ?? this.username,
      email: email ?? this.email,
      password: password ?? this.password,
            confirmedPassword: confirmedPassword ?? this.confirmedPassword,
      isStep1Valid: isStep1Valid ?? this.isStep1Valid,
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

  void onFullNameChanged(String value) {
    final fullName = FullName.dirty(value);
        state = state.copyWith(
      fullName: fullName,
      isStep1Valid: Formz.validate([fullName, state.username, state.email]),
    );
  }

  void onUsernameChanged(String value) {
    final username = Username.dirty(value);
        state = state.copyWith(
      username: username,
      isStep1Valid: Formz.validate([state.fullName, username, state.email]),
    );
  }

  void onEmailChanged(String value) {
    final email = Email.dirty(value);
        state = state.copyWith(
      email: email,
      isStep1Valid: Formz.validate([state.fullName, state.username, email]),
    );
  }

  void onPasswordChanged(String value) {
    final password = Password.dirty(value);
    final confirmedPassword = ConfirmedPassword.dirty(password: password.value, value: state.confirmedPassword.value);
        state = state.copyWith(
      password: password,
      confirmedPassword: confirmedPassword,
      isValid: Formz.validate([state.fullName, state.username, state.email, password, confirmedPassword]),
    );
  }

  void onConfirmPasswordChanged(String value) {
    final confirmedPassword = ConfirmedPassword.dirty(password: state.password.value, value: value);
    state = state.copyWith(
      confirmedPassword: confirmedPassword,
      isValid: Formz.validate([state.fullName, state.username, state.email, state.password, confirmedPassword]),
    );
  }

  Future<bool> submit() async {
    if (!state.isValid) return false;

    final overlay = ref.read(loadingOverlayProvider);
    state = state.copyWith(isSubmitting: true, isFailure: false, isSuccess: false);

    overlay.show(context);

    final result = await repository.signUp(
      fullName: state.fullName.value,
      username: state.username.value,
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

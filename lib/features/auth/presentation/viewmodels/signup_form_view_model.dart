import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:formz/formz.dart';
import 'dart:developer' as developer;
import 'package:rivo_app_beta/core/loading/loading_overlay_provider.dart';
import 'package:rivo_app_beta/core/toast/toast_service.dart';
import 'package:rivo_app_beta/core/utils/password_strength_checker.dart';
import 'package:rivo_app_beta/features/auth/domain/repositories/auth_repository.dart';

import 'package:rivo_app_beta/features/auth/presentation/forms/confirmed_password.dart';
import 'package:rivo_app_beta/features/auth/presentation/forms/email.dart';
import 'package:rivo_app_beta/features/auth/presentation/forms/first_name.dart';
import 'package:rivo_app_beta/features/auth/presentation/forms/last_name.dart';
import 'package:rivo_app_beta/features/auth/presentation/forms/password.dart';
import 'package:rivo_app_beta/features/auth/presentation/forms/username.dart';
import 'package:rivo_app_beta/core/navigation/navigator_key_provider.dart';
import 'package:rivo_app_beta/core/security/field_security.dart';
import 'package:rivo_app_beta/core/error_handling/app_exception.dart';

class SignupFormState {
  final FirstName firstName;
  final LastName lastName;
  final Username username;
  final Email email;
  final Password password;
  final ConfirmedPassword confirmedPassword;
  final PasswordStrength passwordStrength;
  final bool isValid;
  final bool isSubmitting;
  final bool isSuccess;
  final bool isFailure;
  final String? errorMessage;
  final bool usernameExists;
  final bool emailExists;

  SignupFormState({
    this.firstName = const FirstName.pure(),
    this.lastName = const LastName.pure(),
    this.username = const Username.pure(),
    this.email = const Email.pure(),
    this.password = const Password.pure(),
    this.confirmedPassword = const ConfirmedPassword.pure(),
    this.passwordStrength = PasswordStrength.weak,

    this.isValid = false,
    this.isSubmitting = false,
    this.isSuccess = false,
    this.isFailure = false,
    this.errorMessage,
    this.usernameExists = false,
    this.emailExists = false,
  });

  SignupFormState copyWith({
    FirstName? firstName,
    LastName? lastName,
    Username? username,
    Email? email,
    Password? password,
    ConfirmedPassword? confirmedPassword,
    PasswordStrength? passwordStrength,

    bool? isValid,
    bool? isSubmitting,
    bool? isSuccess,
    bool? isFailure,
    String? errorMessage,
    bool? usernameExists,
    bool? emailExists,
  }) {
    return SignupFormState(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      username: username ?? this.username,
      email: email ?? this.email,
      password: password ?? this.password,
      confirmedPassword: confirmedPassword ?? this.confirmedPassword,
      passwordStrength: passwordStrength ?? this.passwordStrength,

      isValid: isValid ?? this.isValid,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      isFailure: isFailure ?? this.isFailure,
      errorMessage: errorMessage,
      usernameExists: usernameExists ?? this.usernameExists,
      emailExists: emailExists ?? this.emailExists,
    );
  }
}

class SignupFormViewModel extends StateNotifier<SignupFormState> {
  final AuthRepository _repository;
  final Ref _ref;

  SignupFormViewModel({
    required AuthRepository repository,
    required Ref ref,
  })  : _repository = repository,
        _ref = ref,
        super(SignupFormState());

  void onFirstNameChanged(String value) {
    final firstName = FirstName.dirty(value);
    state = state.copyWith(
      firstName: firstName,
      isValid: Formz.validate([firstName, state.lastName, state.username, state.email, state.password, state.confirmedPassword]),
    );
  }

  void onLastNameChanged(String value) {
    final lastName = LastName.dirty(value);
    state = state.copyWith(
      lastName: lastName,
      isValid: Formz.validate([state.firstName, lastName, state.username, state.email, state.password, state.confirmedPassword]),
    );
  }

  /// Called when the username text field changes. Resets usernameExists flag.
  void onUsernameChanged(String value) {
    final username = Username.dirty(value);
    state = state.copyWith(
      username: username,
      isValid: Formz.validate([state.firstName, state.lastName, username, state.email, state.password, state.confirmedPassword]),
      usernameExists: false,
    );
  }

  /// Called when the email text field changes. Resets emailExists flag.
  void onEmailChanged(String value) {
    final email = Email.dirty(value);
    state = state.copyWith(
      email: email,
      isValid: Formz.validate([state.firstName, state.lastName, state.username, email, state.password, state.confirmedPassword]),
      emailExists: false,
    );
  }

  void onPasswordChanged(String value) {
    final password = Password.dirty(value);
    final confirmedPassword = ConfirmedPassword.dirty(password: password.value, value: state.confirmedPassword.value);
    final strength = PasswordStrengthChecker.checkStrength(value);
    state = state.copyWith(
      password: password,
      confirmedPassword: confirmedPassword,
      passwordStrength: strength,
      isValid: Formz.validate([state.firstName, state.lastName, state.username, state.email, password, confirmedPassword]),
    );
  }

  void onConfirmPasswordChanged(String value) {
    final confirmedPassword = ConfirmedPassword.dirty(password: state.password.value, value: value);
    state = state.copyWith(
      confirmedPassword: confirmedPassword,
      isValid: Formz.validate([state.firstName, state.lastName, state.username, state.email, state.password, confirmedPassword]),
    );
  }

  Future<void> checkUsername() async {
    if (!state.username.isValid) return;
    final result = await _repository.checkUsername(state.username.value);
    result.fold(
      (l) => developer.log('[DEBUG] checkUsername error: $l'), // Handle error case if necessary
      (exists) {
        state = state.copyWith(usernameExists: exists);
        developer.log('[DEBUG] SignupFormViewModel.checkUsername: usernameExists = $exists');
      },
    );
  }

  Future<void> checkEmail() async {
    if (!state.email.isValid) return;
    final result = await _repository.checkEmail(state.email.value);
    result.fold(
      (l) => developer.log('[DEBUG] checkEmail error: $l'), // Handle error case if necessary
      (exists) {
        state = state.copyWith(emailExists: exists);
        developer.log('[DEBUG] SignupFormViewModel.checkEmail: emailExists = $exists');
      },
    );
  }



  Future<bool> validateStep1() async {
    // If username or email is already flagged as existing, skip backend check and loading overlay
    if (state.usernameExists || state.emailExists) {
      developer.log('[DEBUG] validateStep1: usernameExists or emailExists already true, skipping backend checks');
      return false;
    }

    // Only run backend checks if both flags are false
    await Future.wait([checkUsername(), checkEmail()]);

    // Re-read the latest state after both async checks complete to avoid race condition
    final currentState = state;
    developer.log('[DEBUG] validateStep1: usernameExists = ${currentState.usernameExists}, emailExists = ${currentState.emailExists}');
    return !currentState.usernameExists && !currentState.emailExists;
  }

  Future<bool> submit(BuildContext context) async {
    if (!state.isValid) return false;
    
    try {
      // Apply FieldSecurity validation
      final firstName = FieldSecurity.sanitizeString(
        value: state.firstName.value,
        fieldName: 'First name',
        isRequired: true,
        maxLength: 50,
      )!;

      final lastName = FieldSecurity.sanitizeString(
        value: state.lastName.value,
        fieldName: 'Last name',
        isRequired: true,
        maxLength: 50,
      )!;

      final username = FieldSecurity.sanitizeString(
        value: state.username.value,
        fieldName: 'Username',
        isRequired: true,
        maxLength: 30,
      )!;

      // Email is already validated by the Email Formz class
      final email = state.email.value;
      
      final overlay = _ref.read(loadingOverlayProvider);
      state = state.copyWith(isSubmitting: true, isFailure: false, isSuccess: false);
      overlay.show(context);

      final result = await _repository.signUp(
        firstName: firstName,
        lastName: lastName,
        username: username,
        email: email,
        password: state.password.value,
      );

      final currentContext = _ref.read(navigatorKeyProvider).currentContext;
      if (currentContext != null && currentContext.mounted) {
        overlay.hide();
      }

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
    } on AppException catch (e) {
      // Handle validation errors from FieldSecurity
      final errorMessage = e.toString();
      state = state.copyWith(
        isSubmitting: false,
        isFailure: true,
        errorMessage: errorMessage,
      );
      ToastService().showError(errorMessage);
      return false;
    } catch (e) {
      // Handle any other unexpected errors
      const errorMessage = 'An unexpected error occurred. Please try again.';
      state = state.copyWith(
        isSubmitting: false,
        isFailure: true,
        errorMessage: errorMessage,
      );
      ToastService().showError(errorMessage);
      return false;
    }
  }
}

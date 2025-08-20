import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:formz/formz.dart';
import 'dart:developer' as developer;

import 'package:rivo_app_beta/core/loading/loading_overlay_provider.dart';
import 'package:rivo_app_beta/core/toast/toast_service.dart';
import 'package:rivo_app_beta/core/utils/password_strength_checker.dart';
import 'package:rivo_app_beta/core/navigation/navigator_key_provider.dart';
import 'package:rivo_app_beta/core/security/field_security.dart';
import 'package:rivo_app_beta/core/error_handling/app_exception.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:rivo_app_beta/core/localization/generated/app_localizations.dart';

import 'package:rivo_app_beta/features/auth/domain/repositories/auth_repository.dart';
import 'package:rivo_app_beta/features/auth/presentation/forms/username.dart';
import 'package:rivo_app_beta/features/auth/presentation/forms/email.dart';
import 'package:rivo_app_beta/features/auth/presentation/forms/password.dart';
import 'package:rivo_app_beta/features/auth/presentation/forms/confirmed_password.dart';

class SignupFormState {
  final Username username;
  final Email email;
  final Password password;
  final ConfirmedPassword confirmedPassword;
  final PasswordStrength passwordStrength;

  /// Whole-form validity (username+email+password+confirmedPassword)
  final bool isValid;

  final bool isSubmitting;
  final bool isSuccess;
  final bool isFailure;
  final String? errorMessage;

  /// Backend existence flags
  final bool usernameExists;
  final bool emailExists;

  const SignupFormState({
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
    Username? username,
    Email? email,
    Password? password,
    ConfirmedPassword? confirmedPassword,
    PasswordStrength? passwordStrength,
    bool? isValid,
    bool? isSubmitting,
    bool? isSuccess,
    bool? isFailure,
    String? errorMessage, // pass explicit null to clear
    bool? usernameExists,
    bool? emailExists,
  }) {
    return SignupFormState(
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
        super(const SignupFormState());

  /// Username changed
  void onUsernameChanged(String value) {
    final nextUsername = Username.dirty(value);
    state = state.copyWith(
      username: nextUsername,
      // user edited the field -> clear old backend flag
      usernameExists: false,
      // recompute form validity
      isValid: Formz.validate([
        nextUsername,
        state.email,
        state.password,
        state.confirmedPassword,
      ]),
    );
  }

  /// Email changed
  void onEmailChanged(String value) {
    final nextEmail = Email.dirty(value);
    state = state.copyWith(
      email: nextEmail,
      emailExists: false,
      isValid: Formz.validate([
        state.username,
        nextEmail,
        state.password,
        state.confirmedPassword,
      ]),
    );
  }

  /// Password changed
  void onPasswordChanged(String value) {
    final nextPassword = Password.dirty(value);
    final nextConfirmed =
        ConfirmedPassword.dirty(password: nextPassword.value, value: state.confirmedPassword.value);
    final strength = PasswordStrengthChecker.checkStrength(value);

    state = state.copyWith(
      password: nextPassword,
      confirmedPassword: nextConfirmed,
      passwordStrength: strength,
      isValid: Formz.validate([state.username, state.email, nextPassword, nextConfirmed]),
    );
  }

  /// Confirm password changed
  void onConfirmPasswordChanged(String value) {
    final nextConfirmed =
        ConfirmedPassword.dirty(password: state.password.value, value: value);

    state = state.copyWith(
      confirmedPassword: nextConfirmed,
      isValid: Formz.validate([state.username, state.email, state.password, nextConfirmed]),
    );
  }

  Future<void> checkUsername() async {
    if (!state.username.isValid) return;
    final res = await _repository.checkUsername(state.username.value);
    res.fold(
      (err) => developer.log('[DEBUG] checkUsername error: $err'),
      (exists) {
        state = state.copyWith(usernameExists: exists);
        developer.log('[DEBUG] usernameExists=$exists');
      },
    );
  }

  Future<void> checkEmail() async {
    if (!state.email.isValid) return;
    final res = await _repository.checkEmail(state.email.value);
    res.fold(
      (err) => developer.log('[DEBUG] checkEmail error: $err'),
      (exists) {
        state = state.copyWith(emailExists: exists);
        developer.log('[DEBUG] emailExists=$exists');
      },
    );
  }

  /// Step-1 validation: backend checks for username/email uniqueness
  Future<bool> validateStep1() async {
    // If already flagged, don’t recheck
    if (state.usernameExists || state.emailExists) {
      developer.log('[DEBUG] validateStep1: flags already true');
      return false;
    }
    await Future.wait([checkUsername(), checkEmail()]);
    final s = state; // re-read
    return !s.usernameExists && !s.emailExists;
  }

  /// Final submit (account creation)
  Future<bool> submit(BuildContext context) async {
    if (!state.isValid) return false;

    // Grab localization early (before any awaits)
    final l10n = AppLocalizations.of(context)!;

    // Early connectivity check to avoid futile network calls (v6 returns a list)
    final results = await Connectivity().checkConnectivity();
    final bool isOffline = results.every((r) => r == ConnectivityResult.none);
    if (isOffline) {
      final msg = l10n.noInternetConnection; // localized message
      state = state.copyWith(isSubmitting: false, isFailure: true, errorMessage: msg);
      ToastService().showError(msg);
      return false;
    }

    try {
      // extra sanitize
      FieldSecurity.sanitizeString(
        value: state.username.value,
        fieldName: 'Username',
        isRequired: true,
        maxLength: 30,
      );

      if (!context.mounted) return false; // context safety after await above

      final overlay = _ref.read(loadingOverlayProvider);
      state = state.copyWith(isSubmitting: true, isFailure: false, isSuccess: false);
      overlay.show(context);

      final result = await _repository.signUp(
        username: state.username.value,
        email: state.email.value,
        password: state.password.value,
      );

      final currentContext = _ref.read(navigatorKeyProvider).currentContext;
      if (currentContext != null && currentContext.mounted) {
        overlay.hide();
      }

      // If the notifier was disposed in the meantime (e.g., screen navigated away),
      // avoid touching state to prevent "after dispose" errors.
      if (!mounted) {
        return false;
      }

      bool success = false;
      result.fold(
        (failure) {
          if (mounted) {
            state = state.copyWith(isSubmitting: false, isFailure: true, errorMessage: failure);
          }
          ToastService().showError(failure);
          success = false;
        },
        (_) {
          if (mounted) {
            state = state.copyWith(isSubmitting: false, isSuccess: true);
          }
          ToastService().showSuccess("Success");
          success = true;
        },
      );
      return success;
    } on AppException catch (e) {
      final msg = e.toString();
      if (mounted) {
        state = state.copyWith(isSubmitting: false, isFailure: true, errorMessage: msg);
      }
      ToastService().showError(msg);
      return false;
    } catch (_) {
      const msg = 'An unexpected error occurred. Please try again.';
      if (mounted) {
        state = state.copyWith(isSubmitting: false, isFailure: true, errorMessage: msg);
      }
      ToastService().showError(msg);
      return false;
    }
  }
}

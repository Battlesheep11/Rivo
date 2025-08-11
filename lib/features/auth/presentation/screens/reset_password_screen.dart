import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:formz/formz.dart';
import 'package:go_router/go_router.dart';
import 'package:rivo_app_beta/core/localization/generated/app_localizations.dart';
import 'package:rivo_app_beta/core/toast/toast_service.dart';
import 'package:rivo_app_beta/core/utils/password_strength_checker.dart';
import 'package:rivo_app_beta/features/auth/presentation/forms/confirmed_password.dart';
import 'package:rivo_app_beta/features/auth/presentation/forms/password.dart';
import 'package:rivo_app_beta/features/auth/presentation/viewmodels/reset_password_view_model.dart';
import 'package:rivo_app_beta/features/auth/presentation/widgets/password_strength_indicator.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  final String token;

  const ResetPasswordScreen({super.key, required this.token});

  @override
  ConsumerState<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final state = ref.watch(resetPasswordViewModelProvider);
    final viewModel = ref.read(resetPasswordViewModelProvider.notifier);

    ref.listen<ResetPasswordState>(resetPasswordViewModelProvider, (previous, next) {
      if (next.submissionStatus == FormzSubmissionStatus.failure) {
        ToastService().showError(next.errorMessage ?? localizations.errorOccurred);
      }
      if (next.submissionStatus == FormzSubmissionStatus.success) {
        ToastService().showSuccess(localizations.passwordResetSuccess);
        // Navigate to the login screen after successful password reset.
        context.go('/auth');
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.authResetPassword),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              localizations.resetPasswordMessage,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            _buildTextField(
              hintText: localizations.newPassword,
              obscureText: !_passwordVisible,
              onChanged: viewModel.onPasswordChanged,
              errorText: state.password.displayError?.errorMessage(localizations),
              suffixIcon: IconButton(
                icon: Icon(_passwordVisible ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => _passwordVisible = !_passwordVisible),
              ),
            ),
            const SizedBox(height: 8),
            PasswordStrengthIndicator(
              strength: PasswordStrengthChecker.checkStrength(state.password.value),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              hintText: localizations.confirmNewPassword,
              obscureText: !_confirmPasswordVisible,
              onChanged: viewModel.onConfirmPasswordChanged,
              errorText: state.confirmedPassword.displayError?.errorMessage(localizations),
              suffixIcon: IconButton(
                icon: Icon(_confirmPasswordVisible ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => _confirmPasswordVisible = !_confirmPasswordVisible),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: state.isValid
                  ? () => viewModel.submit(widget.token)
                  : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: state.submissionStatus == FormzSubmissionStatus.inProgress
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                    )
                  : Text(localizations.authResetPassword),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String hintText,
    required ValueChanged<String> onChanged,
    bool obscureText = false,
    Widget? suffixIcon,
    String? errorText,
  }) {
    return TextField(
      onChanged: onChanged,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hintText,
        errorText: errorText,
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
    );
  }
}

// Extension to map validation errors to localized strings
extension on PasswordValidationError {
  String errorMessage(AppLocalizations l10n) {
    switch (this) {
      case PasswordValidationError.empty:
        return l10n.passwordValidationEmpty;
      case PasswordValidationError.tooShort:
        return l10n.passwordValidationMinLength;
      case PasswordValidationError.noUppercase:
        return l10n.passwordValidationUppercase;
      case PasswordValidationError.noLowercase:
        return l10n.passwordValidationLowercase;
      case PasswordValidationError.noNumber:
        return l10n.passwordValidationNumber;
      case PasswordValidationError.noSpecialChar:
        return l10n.passwordValidationSpecialChar;
    }
  }
}

extension on ConfirmedPasswordValidationError {
  String errorMessage(AppLocalizations l10n) {
    switch (this) {
      case ConfirmedPasswordValidationError.mismatch:
        return l10n.passwordValidationMismatch;
      case ConfirmedPasswordValidationError.empty:
        return l10n.passwordValidationRequired;
    }
  }
}

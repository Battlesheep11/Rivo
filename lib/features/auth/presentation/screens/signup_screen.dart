import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivo_app_beta/features/auth/presentation/providers/signup_form_provider.dart';
import 'package:rivo_app_beta/design_system/exports.dart';
import 'package:rivo_app_beta/features/auth/presentation/widgets/password_strength_indicator.dart';
import 'package:rivo_app_beta/core/localization/generated/app_localizations.dart';
import 'package:rivo_app_beta/features/auth/presentation/forms/password.dart';
import 'package:go_router/go_router.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    usernameController.addListener(_onUsernameChanged);
    emailController.addListener(_onEmailChanged);
    passwordController.addListener(_onPasswordChanged);
    confirmPasswordController.addListener(_onConfirmPasswordChanged);
  }

  void _onUsernameChanged() {
    ref.read(signupFormViewModelProvider.notifier).onUsernameChanged(usernameController.text);
  }

  void _onEmailChanged() {
    ref.read(signupFormViewModelProvider.notifier).onEmailChanged(emailController.text);
  }

  void _onPasswordChanged() {
    ref.read(signupFormViewModelProvider.notifier).onPasswordChanged(passwordController.text);
  }

  void _onConfirmPasswordChanged() {
    ref.read(signupFormViewModelProvider.notifier).onConfirmPasswordChanged(confirmPasswordController.text);
  }

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final state = ref.watch(signupFormViewModelProvider);

    final VoidCallback? onSubmit = (state.isValid && !state.isSubmitting)
        ? () async {
            final success = await ref.read(signupFormViewModelProvider.notifier).submit(context);
            if (!context.mounted) return; // guard BuildContext after async gap
            if (success) {
              context.go('/onboarding');
            }
          }
        : null;

    return Scaffold(
      appBar: AppBar(title: AppFormTitle(text: localizations.signUp), centerTitle: true),
      body: AppFormContainer(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextField(controller: usernameController, hintText: localizations.authUsernameHint),
            if (state.usernameExists)
              AppErrorText(message: localizations.authUsernameTaken),
            const SizedBox(height: 16),
            AppTextField(
              controller: emailController,
              hintText: localizations.authEmailHint,
              keyboardType: TextInputType.emailAddress,
            ),
            if (state.emailExists)
              AppErrorText(message: localizations.authEmailTaken),
            const SizedBox(height: 16),
            AppTextField(controller: passwordController, hintText: localizations.authPasswordHint, obscureText: true),
            // Show password validation errors
            if (state.password.isNotValid && state.password.error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: AppErrorText(message: state.password.error!.getErrorMessage(context)),
              ),
            // Show password strength indicator
            if (state.password.value.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: PasswordStrengthIndicator(strength: state.passwordStrength),
              ),
            const SizedBox(height: 16),
            AppTextField(controller: confirmPasswordController, hintText: localizations.authConfirmPasswordHint, obscureText: true),
            // Show confirm password validation errors
            if (state.confirmedPassword.isNotValid && state.confirmedPassword.value.isNotEmpty)
              AppErrorText(message: localizations.authConfirmPasswordMismatch),
            const SizedBox(height: 16),
            // Enhanced button with feedback when disabled
            AppButton(
              text: state.isSubmitting ? localizations.authSigningUp : localizations.signUp, 
              onPressed: onSubmit,
            ),
            // Show explanation when button is disabled
            if (onSubmit == null && !state.isSubmitting)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: AppErrorText(
                  message: localizations.authSignupValidationMessage,
                ),
              ),
            if (state.isFailure && state.errorMessage != null)
              AppErrorText(message: state.errorMessage!),
          ],
        ),
      ),
    );
  }
}

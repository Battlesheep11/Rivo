import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivo_app_beta/features/auth/presentation/providers/signup_form_provider.dart';
import 'package:rivo_app_beta/core/design_system/design_system.dart';
import 'package:rivo_app_beta/features/auth/presentation/widgets/password_strength_indicator.dart';
import 'package:rivo_app_beta/core/localization/generated/app_localizations.dart';
import 'package:rivo_app_beta/features/auth/presentation/forms/password.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final fullNameController = TextEditingController();
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fullNameController.addListener(_onFirstNameChanged);
    usernameController.addListener(_onUsernameChanged);
    emailController.addListener(_onEmailChanged);
    passwordController.addListener(_onPasswordChanged);
    confirmPasswordController.addListener(_onConfirmPasswordChanged);
  }

  void _onFirstNameChanged() {
    // We'll need to split the fullNameController text into first and last name
    // For now, we'll just use the first word as first name and the rest as last name
    final fullName = fullNameController.text;
    final parts = fullName.split(' ');
    final firstName = parts.isNotEmpty ? parts[0] : '';
    final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';
    
    ref.read(signupFormViewModelProvider.notifier).onFirstNameChanged(firstName);
    ref.read(signupFormViewModelProvider.notifier).onLastNameChanged(lastName);
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
        fullNameController.dispose();
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
        ? () {
            ref.read(signupFormViewModelProvider.notifier).submit(context);
          }
        : null;

    return Scaffold(
      appBar: AppBar(title: AppFormTitle(text: localizations.signUp), centerTitle: true),
      body: AppFormContainer(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextField(controller: fullNameController, hintText: localizations.authFullName),
            const SizedBox(height: 16),
            AppTextField(controller: usernameController, hintText: localizations.authUsername),
            if (state.usernameExists)
              AppErrorText(message: localizations.authUsernameTaken),
            const SizedBox(height: 16),
            AppTextField(controller: emailController, hintText: localizations.email),
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

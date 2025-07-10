import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivo_app_beta/features/auth/presentation/state/auth_mode.dart';
import 'package:rivo_app_beta/features/auth/presentation/providers/signup_form_provider.dart';
import 'package:rivo_app_beta/features/auth/presentation/providers/google_signin_provider.dart';
import 'package:rivo_app_beta/features/auth/presentation/providers/signin_form_provider.dart';
import 'package:rivo_app_beta/core/design_system/design_system.dart';
import 'package:go_router/go_router.dart';
import 'package:rivo_app_beta/core/localization/widgets/language_selector.dart';
import 'package:rivo_app_beta/core/localization/generated/app_localizations.dart';



class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  AuthMode _authMode = AuthMode.signIn;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    emailController.addListener(_onEmailChanged);
    passwordController.addListener(_onPasswordChanged);
  }

  void _onEmailChanged() {
    if (_authMode == AuthMode.signIn) {
      ref
          .read(signinFormViewModelProvider(context).notifier)
          .onEmailChanged(emailController.text);
    } else {
      ref
          .read(signupFormViewModelProvider(context).notifier)
          .onEmailChanged(emailController.text);
    }
  }

  void _onPasswordChanged() {
    if (_authMode == AuthMode.signIn) {
      ref
          .read(signinFormViewModelProvider(context).notifier)
          .onPasswordChanged(passwordController.text);
    } else {
      ref
          .read(signupFormViewModelProvider(context).notifier)
          .onPasswordChanged(passwordController.text);
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final signinState = ref.watch(signinFormViewModelProvider(context));
    final signupState = ref.watch(signupFormViewModelProvider(context));
    final googleLoading = ref.watch(googleSignInViewModelProvider(context));

    final bool isSubmitting;
    final bool isValid;
    final bool isFailure;
    final String? errorMessage;

    if (_authMode == AuthMode.signIn) {
      isSubmitting = signinState.isSubmitting;
      isValid = signinState.isValid;
      isFailure = signinState.isFailure;
      errorMessage = signinState.errorMessage;
    } else {
      isSubmitting = signupState.isSubmitting;
      isValid = signupState.isValid;
      isFailure = signupState.isFailure;
      errorMessage = signupState.errorMessage;
    }

    final VoidCallback? onSubmit = (isValid && !isSubmitting)
        ? () async {
            bool success = false;

            if (_authMode == AuthMode.signIn) {
              success = await ref
                  .read(signinFormViewModelProvider(context).notifier)
                  .submit();
            } else {
              success = await ref
                  .read(signupFormViewModelProvider(context).notifier)
                  .submit();
            }

            if (success && context.mounted) {
              context.go('/redirect');
            }
          }
        : null;

    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Align(
              alignment: AlignmentDirectional.topEnd,
              child: Padding(
                padding: const EdgeInsetsDirectional.only(top: 16.0, end: 24.0),
                child: const LanguageSelector(),
              ),
            ),
          ),
          Center(
            child: AppFormContainer(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const AppLogo(),
                  const SizedBox(height: 32),
                  AppTextField(
                    controller: emailController,
                    hintText: AppLocalizations.of(context)!.email,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: passwordController,
                    hintText: AppLocalizations.of(context)!.password,
                    obscureText: true,
                  ),
                  const SizedBox(height: 16),
                  AppButton(
                    text: _authMode == AuthMode.signIn
                        ? AppLocalizations.of(context)!.signIn
                        : AppLocalizations.of(context)!.signUp,
                    onPressed: onSubmit,
                  ),
                  if (isFailure && errorMessage != null)
                    AppErrorText(message: errorMessage),
                  const SizedBox(height: 24),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _authMode = _authMode == AuthMode.signIn
                            ? AuthMode.signUp
                            : AuthMode.signIn;
                        emailController.clear();
                        passwordController.clear();
                      });
                    },
                    child: Text(
                      _authMode == AuthMode.signIn
                          ? AppLocalizations.of(context)!.dontHaveAccountText
                          : AppLocalizations.of(context)!.alreadyHaveAccountText,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  AppButton(
                    text: AppLocalizations.of(context)!.continueWithGoogleText,
                    onPressed: () {
                      ref
                          .read(googleSignInViewModelProvider(context).notifier)
                          .signInWithGoogle();
                    },
                    isLoading: googleLoading,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

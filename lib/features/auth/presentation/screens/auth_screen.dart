import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivo_app/features/auth/presentation/state/auth_mode.dart';
import 'package:rivo_app/features/auth/presentation/providers/signup_form_provider.dart';
import 'package:rivo_app/features/auth/presentation/providers/google_signin_provider.dart';
import 'package:rivo_app/features/auth/presentation/providers/signin_form_provider.dart';
import 'package:rivo_app/core/design_system/design_system.dart';

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
      ref.read(signinFormViewModelProvider(context).notifier).onEmailChanged(emailController.text);
    } else {
      ref.read(signupFormViewModelProvider(context).notifier).onEmailChanged(emailController.text);
    }
  }

  void _onPasswordChanged() {
    if (_authMode == AuthMode.signIn) {
      ref.read(signinFormViewModelProvider(context).notifier).onPasswordChanged(passwordController.text);
    } else {
      ref.read(signupFormViewModelProvider(context).notifier).onPasswordChanged(passwordController.text);
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
        ? () {
            if (_authMode == AuthMode.signIn) {
              ref.read(signinFormViewModelProvider(context).notifier).submit();
            } else {
              ref.read(signupFormViewModelProvider(context).notifier).submit();
            }
          }
        : null;

    return Scaffold(
      body: AppFormContainer(
        isLoading: isSubmitting,  
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppLogo(),
            const SizedBox(height: 32),
            AppTextField(controller: emailController, hintText: 'Email'),
            const SizedBox(height: 16),
            AppTextField(controller: passwordController, hintText: 'Password', obscureText: true),
            const SizedBox(height: 16),
            AppButton(
              text: _authMode == AuthMode.signIn ? 'Sign In' : 'Sign Up',
              onPressed: onSubmit,
              isLoading: isSubmitting, 
            ),
            if (isFailure && errorMessage != null)
              AppErrorText(message: errorMessage),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () {
                setState(() {
                  _authMode = _authMode == AuthMode.signIn ? AuthMode.signUp : AuthMode.signIn;
                  emailController.clear();
                  passwordController.clear();
                });
              },
              child: Text(
                _authMode == AuthMode.signIn
                    ? "Don't have an account? Sign Up"
                    : "Already have an account? Sign In",
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            AppButton(
              text: "Continue with Google",
              onPressed: () {
                ref.read(googleSignInViewModelProvider(context).notifier).signInWithGoogle();
              },
              isLoading: googleLoading,
            ),
          ],
        ),
      ),
    );
  }
}

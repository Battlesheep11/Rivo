import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivo_app/features/auth/presentation/providers/signup_form_provider.dart';
import 'package:rivo_app/core/design_system/design_system.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    emailController.addListener(_onEmailChanged);
    passwordController.addListener(_onPasswordChanged);
  }

  void _onEmailChanged() {
    ref.read(signupFormViewModelProvider(context).notifier).onEmailChanged(emailController.text);
  }

  void _onPasswordChanged() {
    ref.read(signupFormViewModelProvider(context).notifier).onPasswordChanged(passwordController.text);
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(signupFormViewModelProvider(context));

    final VoidCallback? onSubmit = (state.isValid && !state.isSubmitting)
        ? () {
            ref.read(signupFormViewModelProvider(context).notifier).submit();
          }
        : null;

    return Scaffold(
      appBar: AppBar(title: const AppFormTitle(text: 'Sign Up'), centerTitle: true),
      body: AppFormContainer(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextField(controller: emailController, hintText: 'Email'),
            const SizedBox(height: 16),
            AppTextField(controller: passwordController, hintText: 'Password', obscureText: true),
            const SizedBox(height: 16),
            AppButton(text: state.isSubmitting ? 'Signing Up...' : 'Sign Up', onPressed: onSubmit),
            if (state.isFailure && state.errorMessage != null)
              AppErrorText(message: state.errorMessage!),
          ],
        ),
      ),
    );
  }
}

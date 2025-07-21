import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivo_app_beta/features/auth/presentation/providers/signup_form_provider.dart';
import 'package:rivo_app_beta/core/design_system/design_system.dart';

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

  @override
  void initState() {
    super.initState();
        fullNameController.addListener(_onFullNameChanged);
    usernameController.addListener(_onUsernameChanged);
    emailController.addListener(_onEmailChanged);
    passwordController.addListener(_onPasswordChanged);
  }

      void _onFullNameChanged() {
    ref.read(signupFormViewModelProvider.notifier).onFullNameChanged(fullNameController.text);
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

  @override
  void dispose() {
        fullNameController.dispose();
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
        final state = ref.watch(signupFormViewModelProvider);

    final VoidCallback? onSubmit = (state.isValid && !state.isSubmitting)
        ? () {
            ref.read(signupFormViewModelProvider.notifier).submit(context);
          }
        : null;

    return Scaffold(
      appBar: AppBar(title: const AppFormTitle(text: 'Sign Up'), centerTitle: true),
      body: AppFormContainer(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
                        AppTextField(controller: fullNameController, hintText: 'Full Name'),
            const SizedBox(height: 16),
            AppTextField(controller: usernameController, hintText: 'Username'),
            if (state.isUsernameTaken)
              const AppErrorText(message: 'Username is already taken'),
            const SizedBox(height: 16),
            AppTextField(controller: emailController, hintText: 'Email'),
            if (state.isEmailTaken)
              const AppErrorText(message: 'Email is already in use'),
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

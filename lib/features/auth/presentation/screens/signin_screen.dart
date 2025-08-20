import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivo_app_beta/features/auth/presentation/providers/signin_form_provider.dart';
import 'package:rivo_app_beta/design_system/exports.dart';
import 'package:rivo_app_beta/core/localization/generated/app_localizations.dart';

class SigninScreen extends ConsumerStatefulWidget {
  const SigninScreen({super.key});

  @override
  ConsumerState<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends ConsumerState<SigninScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    emailController.addListener(_onEmailChanged);
    passwordController.addListener(_onPasswordChanged);
  }

  void _onEmailChanged() {
    ref.read(signinFormViewModelProvider.notifier).onEmailChanged(emailController.text);
  }

  void _onPasswordChanged() {
    ref.read(signinFormViewModelProvider.notifier).onPasswordChanged(passwordController.text);
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(signinFormViewModelProvider);

    final VoidCallback? onSubmit = (state.isValid && !state.isSubmitting)
        ? () {
            ref.read(signinFormViewModelProvider.notifier).submit(context);
          }
        : null;

    return Scaffold(
      appBar: AppBar(
        title: AppFormTitle(text: AppLocalizations.of(context)!.signIn),
        centerTitle: true,
      ),
      body: AppFormContainer(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
              text: state.isSubmitting 
                  ? AppLocalizations.of(context)!.signingIn 
                  : AppLocalizations.of(context)!.signIn, 
              onPressed: onSubmit,
            ),
            if (state.isFailure && state.errorMessage != null)
              AppErrorText(message: state.errorMessage!),
          ],
        ),
      ),
    );
  }
}

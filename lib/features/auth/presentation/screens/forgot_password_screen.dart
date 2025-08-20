import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rivo_app_beta/design_system/exports.dart';
import 'package:rivo_app_beta/core/localization/generated/app_localizations.dart';
import 'package:rivo_app_beta/features/auth/presentation/forms/email.dart';
import 'package:rivo_app_beta/features/auth/presentation/viewmodels/forgot_password_view_model.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _pageController = PageController();
  final _emailController = TextEditingController();
  Timer? _resendTimer;
  int _countdown = 60;

  @override
  void dispose() {
    _pageController.dispose();
    _emailController.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    final l10n = AppLocalizations.of(context)!;
    if (value == null || value.isEmpty) {
      return l10n.emailValidationEmpty;
    }
    final error = Email.dirty(value).validator(value);
    if (error != null) {
      switch (error) {
        case EmailValidationError.invalid:
          return l10n.emailValidationInvalid;
      }
    }
    return null;
  }

  void _startResendCountdown() {
    _countdown = 60;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() {
          _countdown--;
        });
      } else {
        _resendTimer?.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('ForgotPasswordScreen build called');
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildEmailInputStep(l10n),
            _buildConfirmationStep(l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailInputStep(AppLocalizations l10n) {
    final viewModel = ref.watch(forgotPasswordViewModelProvider);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(l10n.forgotPasswordTitle, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(l10n.forgotPasswordSubtitle, style: const TextStyle(fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 32),
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: l10n.email,
              hintText: l10n.forgotPasswordEmailHint,
              prefixIcon: const Icon(Icons.email_outlined),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
            keyboardType: TextInputType.emailAddress,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: _validateEmail,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: viewModel.isSubmitting ? null : () async {
              final result = await ref.read(forgotPasswordViewModelProvider.notifier).sendPasswordResetEmail(_emailController.text.trim());
              result.fold(
                (error) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error))),
                (success) {
                  _startResendCountdown();
                  _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
                },
              );
            },
            style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
            child: viewModel.isSubmitting ? const CircularProgressIndicator() : Text(l10n.forgotPasswordSendLink),
          ),
          const Spacer(),
          TextButton(
            onPressed: () => context.pop(),
            child: Text(l10n.forgotPasswordRemembered),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmationStep(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle_outline, color: Colors.green, size: 80),
          const SizedBox(height: 24),
          Text(l10n.forgotPasswordConfirmationTitle, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            l10n.forgotPasswordConfirmationSubtitle(_emailController.text),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 48),
          if (_countdown > 0)
            Text(l10n.forgotPasswordResendTimer(_countdown.toString()))
          else
            TextButton(
              onPressed: () async {
                final result = await ref.read(forgotPasswordViewModelProvider.notifier).sendPasswordResetEmail(_emailController.text.trim());
                result.fold(
                  (error) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error))),
                  (success) {
                    _startResendCountdown();
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.authResetEmailSent)));
                  },
                );
              },
              child: Text(l10n.forgotPasswordResendLink),
            ),
          const Spacer(),
          TextButton(
            onPressed: () => context.pop(),
            child: Text(l10n.authSignInLink),
          ),
        ],
      ),
    );
  }
}

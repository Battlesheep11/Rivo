import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivo_app_beta/features/auth/presentation/forms/email.dart';
import 'package:rivo_app_beta/features/auth/presentation/viewmodels/forgot_password_view_model.dart';
import 'package:rivo_app_beta/core/toast/toast_service.dart';
import 'package:rivo_app_beta/core/localization/generated/app_localizations.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  
  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.watch(forgotPasswordViewModelProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.authForgotPasswordTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              Text(
                AppLocalizations.of(context)!.authForgotPasswordSubtitle,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.email,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context)!.emailValidationEmpty;
                  }
                  if (!Email.dirty(value).isValid) {
                    return AppLocalizations.of(context)!.emailValidationInvalid;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: viewModel.isSubmitting
                    ? null
                    : () async {
                        if (_formKey.currentState?.validate() ?? false) {
                          final result = await ref
                              .read(forgotPasswordViewModelProvider.notifier)
                              .sendPasswordResetEmail(_emailController.text.trim());

                          result.fold(
                            (error) => ToastService().showError(error),
                            (success) {
                              ToastService().showSuccess(
                                      AppLocalizations.of(context)!.authResetEmailSent);
                              Navigator.of(context).pop();
                            },
                          );
                        }
                      },
                child: viewModel.isSubmitting
                    ? const CircularProgressIndicator()
                    : Text(AppLocalizations.of(context)!.authSendResetLink),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

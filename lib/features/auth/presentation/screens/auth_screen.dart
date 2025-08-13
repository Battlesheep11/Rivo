import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:formz/formz.dart';
import 'package:go_router/go_router.dart';
import 'package:rivo_app_beta/core/design_system/app_error_text.dart';
import 'package:rivo_app_beta/core/localization/generated/app_localizations.dart';
import 'package:rivo_app_beta/core/localization/widgets/language_selector.dart';
import 'package:rivo_app_beta/features/auth/presentation/providers/google_signin_provider.dart';
import 'package:rivo_app_beta/features/auth/presentation/providers/signin_form_provider.dart';
import 'package:rivo_app_beta/features/auth/presentation/providers/signup_form_provider.dart';
import 'package:rivo_app_beta/features/auth/presentation/state/auth_mode.dart';
import 'package:rivo_app_beta/features/auth/presentation/viewmodels/signup_form_view_model.dart';
import 'package:rivo_app_beta/features/auth/presentation/widgets/password_strength_indicator.dart';
import 'package:rivo_app_beta/features/auth/presentation/forms/password.dart';
import 'package:rivo_app_beta/features/auth/presentation/forms/confirmed_password.dart';

// ⬇️ Apple Sign-In provider (from v2)
import 'package:rivo_app_beta/features/auth/presentation/providers/apple_signin_provider.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

enum _SignupStep { userDetails, createPassword }

class _AuthScreenState extends ConsumerState<AuthScreen> {
  AuthMode _authMode = AuthMode.signIn;
  _SignupStep _signupStep = _SignupStep.userDetails;
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;
  bool _termsAccepted = false;

  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _emailController.addListener(() {
      if (_authMode == AuthMode.signIn) {
        ref.read(signinFormViewModelProvider.notifier).onEmailChanged(_emailController.text);
      } else {
        ref.read(signupFormViewModelProvider.notifier).onEmailChanged(_emailController.text);
      }
    });

    _passwordController.addListener(() {
      debugPrint('[DEBUG] PasswordController changed: ${_passwordController.text}');
      if (_authMode == AuthMode.signIn) {
        ref.read(signinFormViewModelProvider.notifier).onPasswordChanged(_passwordController.text);
      } else {
        ref.read(signupFormViewModelProvider.notifier).onPasswordChanged(_passwordController.text);
      }
    });

    _usernameController.addListener(() {
      debugPrint('[DEBUG] UsernameController changed: ${_usernameController.text}');
      ref.read(signupFormViewModelProvider.notifier).onUsernameChanged(_usernameController.text);
    });
    _confirmPasswordController.addListener(() {
      debugPrint('[DEBUG] ConfirmPasswordController changed: ${_confirmPasswordController.text}');
      ref.read(signupFormViewModelProvider.notifier).onConfirmPasswordChanged(_confirmPasswordController.text);
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<SignupFormState>(signupFormViewModelProvider, (previous, next) {
      if (next.isSubmitting) {
        // loading started
      }
      if (!next.isSubmitting && (previous?.isSubmitting ?? false)) {
        // loading ended
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 420),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                    child: _authMode == AuthMode.signIn
                        ? _buildSignInForm(context)
                        : _buildSignUpForm(context),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 6.0),
                child: Transform.scale(
                  scale: 0.8,
                  child: LanguageSelector(
                    onChanged: (_) {
                      ref.read(signinFormViewModelProvider.notifier).clearError();
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignInForm(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final signinState = ref.watch(signinFormViewModelProvider);
    final googleLoading = ref.watch(googleSignInViewModelProvider(context));
    // ⬇️ Apple loading (from v2)
    final appleLoading = ref.watch(appleSignInViewModelProvider(context));

    final isSubmitting = signinState.isSubmitting;

    ref.listen(signinFormViewModelProvider, (previous, next) {
      if (next.isSuccess && context.mounted) {
        context.go('/redirect');
      }
    });

    final VoidCallback? onSubmit = !isSubmitting
        ? () => ref.read(signinFormViewModelProvider.notifier).submit(context)
        : null;

    return Column(
      key: const ValueKey('signInForm'),
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(localizations.signIn, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A))),
        const SizedBox(height: 8),
        Text(localizations.authWelcomeSubtitle, style: const TextStyle(fontSize: 14, color: Color(0xFF666666))),
        const SizedBox(height: 32),
        _buildTextField(
          controller: _emailController,
          label: localizations.email,
          hintText: localizations.email,
          icon: Icons.email_outlined,
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _passwordController,
          label: localizations.password,
          hintText: localizations.authPasswordHint,
          icon: Icons.lock_outline,
          obscureText: !_passwordVisible,
          suffixIcon: IconButton(
            icon: Icon(_passwordVisible ? Icons.visibility_off : Icons.visibility, color: const Color(0xFF999999)),
            onPressed: () => setState(() => _passwordVisible = !_passwordVisible),
          ),
        ),
        if (signinState.isFailure && signinState.errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
            child: AppErrorText(message: signinState.errorMessage!),
          )
        else
          const SizedBox(height: 8),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: onSubmit,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF000000),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, fontFamily: 'Inter'),
          ),
          child: isSubmitting
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                )
              : Text(localizations.signIn),
        ),
        const SizedBox(height: 24),
        _buildDivider(context),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: _buildSocialButton(
                localizations.authGoogle,
                'assets/icons/google_logo.svg',
                () {
                  ref.read(googleSignInViewModelProvider(context).notifier).signInWithGoogle();
                },
                isLoading: googleLoading,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSocialButton(
                localizations.authApple,
                'assets/icons/apple_logo.svg',
                // ⬇️ from v2: actual Apple call + loading
                () {
                  ref.read(appleSignInViewModelProvider(context).notifier).signInWithApple();
                },
                isLoading: appleLoading,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildAuthToggle(context),
      ],
    );
  }

  Widget _buildSignUpForm(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
      child: _signupStep == _SignupStep.userDetails ? _buildUserDetailsStep(context) : _buildCreatePasswordStep(context),
    );
  }

  Widget _buildUserDetailsStep(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final signupState = ref.watch(signupFormViewModelProvider);
    final signupNotifier = ref.read(signupFormViewModelProvider.notifier);
    final googleLoading = ref.watch(googleSignInViewModelProvider(context));
    // ⬇️ Apple loading (from v2)
    final appleLoading = ref.watch(appleSignInViewModelProvider(context));

    final isStep1Valid = Formz.validate([signupState.username, signupState.email]);


    return Column(
      key: const ValueKey('userDetailsStep'),
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(localizations.signUp, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A))),
        const SizedBox(height: 8),
        Text(localizations.authSubheading, style: const TextStyle(fontSize: 14, color: Color(0xFF666666))),
        const SizedBox(height: 32),
        _buildTextField(
          controller: _usernameController,
          hintText: localizations.authUsernameHint,
          icon: Icons.account_circle_outlined,
        ),
        if (signupState.usernameExists)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4),
            child: Text(localizations.authUsernameTaken, style: const TextStyle(color: Colors.red, fontSize: 13)),
          ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _emailController,
          label: localizations.email,
          hintText: localizations.authEmailHint,
          icon: Icons.alternate_email,
        ),
        if (signupState.emailExists)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4),
            child: Text(localizations.authEmailTaken, style: const TextStyle(color: Colors.red, fontSize: 13)),
          ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: isStep1Valid && !signupState.isSubmitting
              ? () async {
                  final success = await signupNotifier.validateStep1();
                  if (!context.mounted) return;
                  if (success) {
                    setState(() => _signupStep = _SignupStep.createPassword);
                  } else {
                    if (!context.mounted) return;
                    final currentState = ref.read(signupFormViewModelProvider);
                    final messenger = ScaffoldMessenger.of(context);
                    if (currentState.usernameExists) {
                      if (!context.mounted) return;
                      messenger.showSnackBar(SnackBar(content: Text(localizations.authUsernameTaken)));
                    }
                    if (currentState.emailExists) {
                      if (!context.mounted) return;
                      messenger.showSnackBar(SnackBar(content: Text(localizations.authEmailTaken)));
                    }
                  }
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF000000),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, fontFamily: 'Inter'),
          ),
          child: Text(localizations.authContinue),
        ),
        const SizedBox(height: 24),
        _buildDivider(context),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: _buildSocialButton(
                localizations.authGoogle,
                'assets/icons/google_logo.svg',
                () {
                  ref.read(googleSignInViewModelProvider(context).notifier).signInWithGoogle();
                },
                isLoading: googleLoading,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSocialButton(
                localizations.authApple,
                'assets/icons/apple_logo.svg',
                // ⬇️ from v2: actual Apple call + loading
                () {
                  ref.read(appleSignInViewModelProvider(context).notifier).signInWithApple();
                },
                isLoading: appleLoading,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildAuthToggle(context),
      ],
    );
  }

  Widget _buildCreatePasswordStep(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final signupState = ref.watch(signupFormViewModelProvider);
    final passwordStrength = signupState.passwordStrength;
    final isSubmitting = signupState.isSubmitting;

    final isValid = signupState.isValid;

    String? passwordError;
    if (signupState.password.displayError != null) {
      passwordError = signupState.password.error?.getErrorMessage(context);
    }

    String? confirmPasswordError;
    if (signupState.confirmedPassword.displayError != null) {
      switch (signupState.confirmedPassword.displayError!) {
        case ConfirmedPasswordValidationError.mismatch:
          confirmPasswordError = localizations.passwordValidationMismatch;
          break;
        case ConfirmedPasswordValidationError.empty:
          confirmPasswordError = localizations.passwordValidationRequired;
          break;
      }
    }

    final VoidCallback? onSubmit = (isValid && !isSubmitting && _termsAccepted)
        ? () async {
            final success = await ref.read(signupFormViewModelProvider.notifier).submit(context);
            if (success && context.mounted) {
              context.go('/redirect');
            }
          }
        : null;

    return Column(
      key: const ValueKey('createPasswordStep'),
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(localizations.authCreatePassword, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A))),
        const SizedBox(height: 8),
        Text(localizations.authSecureAccount, style: const TextStyle(fontSize: 14, color: Color(0xFF666666))),
        const SizedBox(height: 32),
        _buildTextField(
          controller: _passwordController,
          label: localizations.password,
          hintText: localizations.authPasswordHint,
          icon: Icons.lock_outline,
          obscureText: !_passwordVisible,
          errorText: passwordError,
          suffixIcon: IconButton(
            icon: Icon(_passwordVisible ? Icons.visibility_off : Icons.visibility, color: const Color(0xFF999999)),
            onPressed: () => setState(() => _passwordVisible = !_passwordVisible),
          ),
        ),
        if (_passwordController.text.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: PasswordStrengthIndicator(strength: passwordStrength),
          ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _confirmPasswordController,
          label: localizations.authConfirmPassword,
          hintText: localizations.authConfirmPasswordHint,
          icon: Icons.lock_outline,
          obscureText: !_confirmPasswordVisible,
          errorText: confirmPasswordError,
          suffixIcon: IconButton(
            icon: Icon(_confirmPasswordVisible ? Icons.visibility_off : Icons.visibility, color: const Color(0xFF999999)),
            onPressed: () => setState(() => _confirmPasswordVisible = !_confirmPasswordVisible),
          ),
        ),
        const SizedBox(height: 24),
        _buildTermsAndConditions(context),
        const SizedBox(height: 24),
        if (!isValid || !_termsAccepted)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              !_termsAccepted ? localizations.authTermsAcceptanceRequired : localizations.authPasswordValidationRequired,
              style: const TextStyle(color: Colors.orange, fontSize: 13, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
          ),
        ElevatedButton(
          onPressed: onSubmit,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF000000),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, fontFamily: 'Inter'),
          ),
          child: isSubmitting
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                )
              : Text(localizations.authCreateAccount),
        ),
        const SizedBox(height: 24),
        _buildAuthToggle(context),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    String? label,
    bool obscureText = false,
    Widget? suffixIcon,
    String? errorText,
  }) {
    final borderColor = errorText != null ? Colors.red : const Color(0xFFE0E0E0);
    final focusedBorderColor = errorText != null ? Colors.red : const Color(0xFF1A73E8);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF333333))),
          ),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: Icon(icon, color: const Color(0xFF999999), size: 20),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: borderColor)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: borderColor)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: focusedBorderColor)),
            errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.red)),
            focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.red)),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4),
            child: Text(errorText, style: const TextStyle(color: Colors.red, fontSize: 13)),
          ),
      ],
    );
  }

  Widget _buildDivider(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Row(
      children: [
        const Expanded(child: Divider(color: Color(0xFFE0E0E0))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(localizations.authOrContinueWith, style: const TextStyle(color: Color(0xFF999999), fontSize: 14)),
        ),
        const Expanded(child: Divider(color: Color(0xFFE0E0E0))),
      ],
    );
  }

  Widget _buildSocialButton(String text, String assetName, VoidCallback onPressed, {bool isLoading = false}) {
    return OutlinedButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon: isLoading ? const SizedBox.shrink() : SvgPicture.asset(assetName, height: 18, width: 18),
      label: isLoading
          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
          : Text(text, style: const TextStyle(color: Color(0xFF333333), fontWeight: FontWeight.w500, fontSize: 14)),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        side: const BorderSide(color: Color(0xFFE0E0E0)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(fontFamily: 'Inter'),
      ),
    );
  }

  Widget _buildTermsAndConditions(BuildContext context) {
    // Keeping v1’s simple message for now
    const termsText = 'By creating an account, you agree to our Terms of Service and Privacy Policy';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Checkbox(
          value: _termsAccepted,
          onChanged: (bool? value) {
            setState(() {
              _termsAccepted = value ?? false;
              debugPrint('[DEBUG] TermsAccepted changed: $_termsAccepted');
            });
          },
          activeColor: const Color(0xFF1A73E8),
          visualDensity: VisualDensity.compact,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        const SizedBox(width: 8),
        const Expanded(
          child: Text(
            termsText,
            style: TextStyle(fontSize: 14, color: Color(0xFF666666), fontFamily: 'Inter'),
          ),
        ),
      ],
    );
  }

  Widget _buildAuthToggle(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final bool isSignIn = _authMode == AuthMode.signIn;

    return TextButton(
      onPressed: () {
        setState(() {
          _authMode = isSignIn ? AuthMode.signUp : AuthMode.signIn;
          _emailController.clear();
          _usernameController.clear();
          _passwordController.clear();
          _confirmPasswordController.clear();
          _signupStep = _SignupStep.userDetails; // Reset to first step
        });
      },
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 14, color: Color(0xFF666666), fontFamily: 'Inter'),
          children: [
            TextSpan(text: isSignIn ? localizations.authSignUpQuestion : localizations.authSignInQuestion),
            const TextSpan(text: ' '),
            TextSpan(
              text: isSignIn ? localizations.authSignUpLink : localizations.authSignInLink,
              style: const TextStyle(color: Color(0xFF1A73E8), fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}

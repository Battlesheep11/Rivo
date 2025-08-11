import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:formz/formz.dart';
import 'package:rivo_app_beta/features/auth/presentation/forms/confirmed_password.dart';
import 'package:rivo_app_beta/features/auth/presentation/forms/password.dart';

// State
class ResetPasswordState extends Equatable {
  const ResetPasswordState({
    this.password = const Password.pure(),
    this.confirmedPassword = const ConfirmedPassword.pure(),
    this.isValid = false,
    this.submissionStatus = FormzSubmissionStatus.initial,
    this.errorMessage,
  });

  final Password password;
  final ConfirmedPassword confirmedPassword;
  final bool isValid;
  final FormzSubmissionStatus submissionStatus;
  final String? errorMessage;

  ResetPasswordState copyWith({
    Password? password,
    ConfirmedPassword? confirmedPassword,
    bool? isValid,
    FormzSubmissionStatus? submissionStatus,
    String? errorMessage,
  }) {
    return ResetPasswordState(
      password: password ?? this.password,
      confirmedPassword: confirmedPassword ?? this.confirmedPassword,
      isValid: isValid ?? this.isValid,
      submissionStatus: submissionStatus ?? this.submissionStatus,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [password, confirmedPassword, isValid, submissionStatus, errorMessage];
}

// ViewModel
class ResetPasswordViewModel extends StateNotifier<ResetPasswordState> {
  ResetPasswordViewModel() : super(const ResetPasswordState());

  void onPasswordChanged(String value) {
    final password = Password.dirty(value);
    final confirmedPassword = ConfirmedPassword.dirty(
      password: password.value,
      value: state.confirmedPassword.value,
    );
    state = state.copyWith(
      password: password,
      confirmedPassword: confirmedPassword,
      isValid: Formz.validate([password, confirmedPassword]),
    );
  }

  void onConfirmPasswordChanged(String value) {
    final confirmedPassword = ConfirmedPassword.dirty(
      password: state.password.value,
      value: value,
    );
    state = state.copyWith(
      confirmedPassword: confirmedPassword,
      isValid: Formz.validate([state.password, confirmedPassword]),
    );
  }

  Future<void> submit(String token) async {
    if (!state.isValid) return;

    state = state.copyWith(submissionStatus: FormzSubmissionStatus.inProgress);

    // Feature removed: immediately fail gracefully without hardcoded UI string
    state = state.copyWith(
      submissionStatus: FormzSubmissionStatus.failure,
      errorMessage: '',
    );
  }
}

// Provider
final resetPasswordViewModelProvider =
    StateNotifierProvider.autoDispose<ResetPasswordViewModel, ResetPasswordState>((ref) {
  return ResetPasswordViewModel();
});

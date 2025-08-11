import 'package:formz/formz.dart';

enum ConfirmedPasswordValidationError { mismatch, empty }

class ConfirmedPassword extends FormzInput<String, ConfirmedPasswordValidationError> {
  final String password;

  const ConfirmedPassword.pure() : password = '', super.pure('');
  const ConfirmedPassword.dirty({this.password = '', String value = ''}) : super.dirty(value);

  @override
  ConfirmedPasswordValidationError? validator(String value) {
    if (value.isEmpty) {
      return ConfirmedPasswordValidationError.empty;
    }
    if (password != value) {
      return ConfirmedPasswordValidationError.mismatch;
    }
    return null;
  }
}

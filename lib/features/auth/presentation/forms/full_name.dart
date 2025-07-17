import 'package:formz/formz.dart';

enum FullNameValidationError { empty }

class FullName extends FormzInput<String, FullNameValidationError> {
  const FullName.pure() : super.pure('');
  const FullName.dirty([super.value = '']) : super.dirty();

  @override
  FullNameValidationError? validator(String value) {
    if (value.isEmpty) {
      return FullNameValidationError.empty;
    }
    return null;
  }
}

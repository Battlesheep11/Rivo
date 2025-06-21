import 'package:equatable/equatable.dart';

class AppException with EquatableMixin implements Exception {
  final String message;
  final String? code;
  final StackTrace? stackTrace;

  const AppException({
    required this.message,
    this.code,
    this.stackTrace,
  });

  factory AppException.network(String message, {String? code, StackTrace? stackTrace}) {
    return NetworkException(
      message: message,
      code: code,
      stackTrace: stackTrace,
    );
  }

  factory AppException.unexpected(String message, {String? code, StackTrace? stackTrace}) {
    return UnexpectedException(
      message: message,
      code: code,
      stackTrace: stackTrace,
    );
  }

  factory AppException.validation(String message, {String? code, StackTrace? stackTrace}) {
    return ValidationException(
      message: message,
      code: code,
      stackTrace: stackTrace,
    );
  }

  factory AppException.unauthorized(String message, {String? code, StackTrace? stackTrace}) {
    return UnauthorizedException(
      message: message,
      code: code,
      stackTrace: stackTrace,
    );
  }

  @override
  String toString() => 'AppException: $message${code != null ? ' (code: $code)' : ''}';

  @override
  List<Object?> get props => [message, code];
}

// Updated subclasses using super parameters
class NetworkException extends AppException {
  const NetworkException({
    required super.message,
    super.code = 'network_error',
    super.stackTrace,
  });
}

class UnexpectedException extends AppException {
  const UnexpectedException({
    required super.message,
    super.code = 'unexpected_error',
    super.stackTrace,
  });
}

class ValidationException extends AppException {
  const ValidationException({
    required super.message,
    super.code = 'validation_error',
    super.stackTrace,
  });
}

class UnauthorizedException extends AppException {
  const UnauthorizedException({
    required super.message,
    super.code = 'unauthorized',
    super.stackTrace,
  });
}

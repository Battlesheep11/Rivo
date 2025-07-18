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

  factory AppException.notFound(String message, {String? code, StackTrace? stackTrace}) {
    return NotFoundException(
      message: message,
      code: code ?? 'not_found',
      stackTrace: stackTrace,
    );
  }

  factory AppException.forbidden(String message, {String? code, StackTrace? stackTrace}) {
    return ForbiddenException(
      message: message,
      code: code ?? 'forbidden',
      stackTrace: stackTrace,
    );
  }

  factory AppException.conflict(String message, {String? code, StackTrace? stackTrace}) {
    return ConflictException(
      message: message,
      code: code ?? 'conflict',
      stackTrace: stackTrace,
    );
  }

  @override
  String toString() => 'AppException: $message${code != null ? ' (code: $code)' : ''}';

  @override
  List<Object?> get props => [message, code];
}

// -----------------------------
// Updated subclasses
// -----------------------------

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

class NotFoundException extends AppException {
  const NotFoundException({
    required super.message,
    super.code = 'not_found',
    super.stackTrace,
  });
}

class ForbiddenException extends AppException {
  const ForbiddenException({
    required super.message,
    super.code = 'forbidden',
    super.stackTrace,
  });
}

class ConflictException extends AppException {
  const ConflictException({
    required super.message,
    super.code = 'conflict',
    super.stackTrace,
  });
}

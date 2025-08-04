import 'package:equatable/equatable.dart';

/// Base class for all failures in the app
abstract class Failure extends Equatable {
  final String message;
  final StackTrace? stackTrace;

  const Failure(this.message, [this.stackTrace]);

  @override
  List<Object?> get props => [message, stackTrace];

  @override
  String toString() => 'Failure: $message';
}

/// Failure that occurs when there's a server error
class ServerFailure extends Failure {
  const ServerFailure(super.message, [super.stackTrace]);
}

/// Failure that occurs when there's a network error
class NetworkFailure extends Failure {
  const NetworkFailure(super.message, [super.stackTrace]);
}

/// Failure that occurs when there's a cache error
class CacheFailure extends Failure {
  const CacheFailure(super.message, [super.stackTrace]);
}

/// Failure that occurs when there's an invalid input
class InvalidInputFailure extends Failure {
  const InvalidInputFailure(super.message, [super.stackTrace]);
}

/// Failure that occurs when a resource is not found
class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message, [super.stackTrace]);
}

/// Failure that occurs when there's an authentication error
class AuthenticationFailure extends Failure {
  const AuthenticationFailure(super.message, [super.stackTrace]);
}

/// Failure that occurs when there's a permission error
class PermissionFailure extends Failure {
  const PermissionFailure(super.message, [super.stackTrace]);
}

/// Failure that occurs when there's a timeout
class TimeoutFailure extends Failure {
  const TimeoutFailure(super.message, [super.stackTrace]);
}

/// Failure that occurs when there's an unknown error
class UnknownFailure extends Failure {
  const UnknownFailure(super.message, [super.stackTrace]);
}

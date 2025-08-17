import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:rivo_app_beta/core/error_handling/failures.dart';

/// Generic use-case contract.
/// T = success type, P = params type
abstract class UseCase<T, P> {
  Future<Either<Failure, T>> call(P params);
}

class NoParams extends Equatable {
  const NoParams();
  @override
  List<Object?> get props => const [];
}

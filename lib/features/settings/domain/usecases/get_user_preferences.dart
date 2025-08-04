import 'package:dartz/dartz.dart';
import 'package:rivo_app_beta/core/error_handling/failures.dart';
import 'package:rivo_app_beta/core/use_cases/use_case.dart';
import 'package:rivo_app_beta/features/settings/domain/repositories/user_preferences_repository.dart';
import 'package:rivo_app_beta/features/settings/domain/entities/user_preferences.dart';

class GetUserPreferences implements UseCase<UserPreferences, String> {
  final UserPreferencesRepository repository;

  GetUserPreferences(this.repository);

  @override
  Future<Either<Failure, UserPreferences>> call(String userId) {
    return repository.getUserPreferences(userId);
  }
}

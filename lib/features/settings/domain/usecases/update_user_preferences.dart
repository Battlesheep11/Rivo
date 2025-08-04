import 'package:dartz/dartz.dart';
import 'package:rivo_app_beta/core/error_handling/failures.dart';
import 'package:rivo_app_beta/core/use_cases/use_case.dart';
import 'package:rivo_app_beta/features/settings/domain/entities/user_preferences.dart';
import 'package:rivo_app_beta/features/settings/domain/repositories/user_preferences_repository.dart';

class UpdateUserPreferences implements UseCase<Unit, UserPreferences> {
  final UserPreferencesRepository repository;

  UpdateUserPreferences(this.repository);

  @override
  Future<Either<Failure, Unit>> call(UserPreferences preferences) {
    return repository.updateUserPreferences(preferences);
  }
}

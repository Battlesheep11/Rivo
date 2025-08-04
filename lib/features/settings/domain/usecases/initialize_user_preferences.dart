import 'package:dartz/dartz.dart';
import 'package:rivo_app_beta/core/error_handling/failures.dart';
import 'package:rivo_app_beta/features/settings/domain/entities/user_preferences.dart';
import 'package:rivo_app_beta/features/settings/domain/repositories/user_preferences_repository.dart';

class InitializeUserPreferences {
  final UserPreferencesRepository repository;

  InitializeUserPreferences(this.repository);

  Future<Either<Failure, UserPreferences>> call(String userId) {
    return repository.initializeUserPreferences(userId);
  }
}

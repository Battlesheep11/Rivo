import 'package:dartz/dartz.dart';
import 'package:rivo_app_beta/core/error_handling/failures.dart';
import 'package:rivo_app_beta/features/settings/domain/entities/user_preferences.dart';

abstract class UserPreferencesRepository {
  /// Get the user's preferences
  Future<Either<Failure, UserPreferences>> getUserPreferences(String userId);

  /// Update the user's preferences
  Future<Either<Failure, Unit>> updateUserPreferences(UserPreferences preferences);

  /// Initialize default preferences for a new user
  Future<Either<Failure, UserPreferences>> initializeUserPreferences(String userId);
}

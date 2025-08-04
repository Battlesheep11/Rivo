import 'package:dartz/dartz.dart';
import 'package:rivo_app_beta/core/error_handling/failures.dart';
import 'package:rivo_app_beta/features/settings/data/datasources/user_preferences_remote_data_source.dart';
import 'package:rivo_app_beta/features/settings/data/mappers/user_preferences_mapper.dart';
import 'package:rivo_app_beta/features/settings/domain/entities/user_preferences.dart';
import 'package:rivo_app_beta/features/settings/domain/repositories/user_preferences_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserPreferencesRepositoryImpl implements UserPreferencesRepository {
  final UserPreferencesRemoteDataSource remoteDataSource;

  UserPreferencesRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, UserPreferences>> getUserPreferences(
      String userId) async {
    try {
      final preferences = await remoteDataSource.getUserPreferences(userId);
      return Right(preferences.toEntity());
    } on PostgrestException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateUserPreferences(
      UserPreferences preferences) async {
    try {
      await remoteDataSource.updateUserPreferences(preferences.toModel());
      return const Right(unit);
    } on PostgrestException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserPreferences>> initializeUserPreferences(
      String userId) async {
    try {
      final preferences = await remoteDataSource.initializeUserPreferences(userId);
      return Right(preferences.toEntity());
    } on PostgrestException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}

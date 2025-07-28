import 'package:rivo_app_beta/features/auth/domain/entities/user_entity.dart';
import 'package:dartz/dartz.dart';

abstract class AuthRepository {
  Future<Either<String, UserEntity>> signUp({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    required String password,
  });

  Future<Either<String, bool>> checkUsername(String username);
  Future<Either<String, bool>> checkEmail(String email);

  Future<Either<String, UserEntity>> signIn({
    required String email,
    required String password,
  });

  Future<Either<String, void>> signOut();

  Future<Either<String, UserEntity?>> getCurrentUser();

    Future<void> signInWithGoogle();

  Future<Either<String, bool>> checkUsername(String username);

  Future<Either<String, bool>> checkEmail(String email);
}

import 'package:rivo_app_beta/features/auth/domain/entities/user_entity.dart';
import 'package:dartz/dartz.dart';


abstract class AuthRepository {
  Future<Either<String, UserEntity>> signUp({
    required String email,
    required String password,
  });

  Future<Either<String, UserEntity>> signIn({
    required String email,
    required String password,
  });

  Future<Either<String, void>> signOut();

  Future<Either<String, UserEntity?>> getCurrentUser();

  Future<void> signInWithGoogle();
}

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
  
  /// Sends a password reset email to the specified email address
  /// Returns [Right(true)] if the email was sent successfully
  /// Returns [Left(error)] if there was an error sending the email
  Future<Either<String, bool>> sendPasswordResetEmail(String email);
  
  /// Resets the password using the provided token and new password
  /// Returns [Right(true)] if the password was reset successfully
  /// Returns [Left(error)] if there was an error resetting the password
  Future<Either<String, bool>> resetPassword({
    required String token,
    required String newPassword,
  });
}

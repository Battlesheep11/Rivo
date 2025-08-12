import 'package:dartz/dartz.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<String, UserEntity>> signUp({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final response = await remoteDataSource.signUp(
        username: username,
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) {
        return left('Signup failed: user is null');
      }

      return right(UserEntity(
        id: user.id,
        email: user.email ?? '',
      ));
    } catch (e) {
      return left('Signup failed: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, bool>> checkUsername(String username) async {
    try {
      final exists = await remoteDataSource.checkUsername(username);
      return right(exists);
    } catch (e) {
      return left(e.toString());
    }
  }

  @override
  Future<Either<String, bool>> checkEmail(String email) async {
    try {
      final exists = await remoteDataSource.checkEmail(email);
      return right(exists);
    } catch (e) {
      return left(e.toString());
    }
  }

  @override
  Future<Either<String, bool>> checkUsername(String username) async {
    try {
      final exists = await remoteDataSource.checkUsername(username);
      return right(exists);
    } catch (e) {
      return left(e.toString());
    }
  }

  @override
  Future<Either<String, bool>> checkEmail(String email) async {
    try {
      final exists = await remoteDataSource.checkEmail(email);
      return right(exists);
    } catch (e) {
      return left(e.toString());
    }
  }

  @override
  Future<Either<String, UserEntity>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await remoteDataSource.signIn(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) {
        return left('Login failed: user is null');
      }

      return right(UserEntity(
        id: user.id,
        email: user.email ?? '',
      ));
    } catch (e) {
      return left('Login failed: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, void>> signOut() async {
    try {
      await remoteDataSource.signOut();
      return right(null);
    } catch (e) {
      return left('Sign out failed: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, UserEntity?>> getCurrentUser() async {
    try {
      final user = remoteDataSource.getCurrentUser();
      if (user == null) return right(null);

      return right(UserEntity(
        id: user.id,
        email: user.email ?? '',
      ));
    } catch (e) {
      return left('Get current user failed: ${e.toString()}');
    }
  }

  @override
  Future<void> signInWithGoogle() async {
  @override
  Future<void> signInWithGoogle() async {
    await remoteDataSource.signInWithGoogle();
  }

  @override
  Future<void> signInWithApple() async {
    await remoteDataSource.signInWithApple();
  }

}

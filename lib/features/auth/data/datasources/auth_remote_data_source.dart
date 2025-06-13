import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rivo_app/features/auth/domain/entities/user_entity.dart';

class AuthRemoteDataSource {
  final SupabaseClient client;

  AuthRemoteDataSource({required this.client});

  Future<UserEntity> signUp({
    required String email,
    required String password,
  }) async {
    final response = await client.auth.signUp(
      email: email,
      password: password,
    );

    if (response.user == null) {
      throw Exception('Signup failed.');
    }

    return UserEntity(
      id: response.user!.id,
      email: response.user!.email ?? '',
    );
  }

  Future<UserEntity> signIn({
    required String email,
    required String password,
  }) async {
    final response = await client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (response.user == null) {
      throw Exception('Login failed.');
    }

    return UserEntity(
      id: response.user!.id,
      email: response.user!.email ?? '',
    );
  }

  Future<void> signOut() async {
    await client.auth.signOut();
  }

  Future<UserEntity?> getCurrentUser() async {
    final user = client.auth.currentUser;

    if (user == null) return null;

    return UserEntity(
      id: user.id,
      email: user.email ?? '',
    );
  }
  
}

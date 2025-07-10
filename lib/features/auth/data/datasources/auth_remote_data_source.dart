import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rivo_app_beta/features/auth/domain/entities/user_entity.dart';

class AuthRemoteDataSource {
  final SupabaseClient client;

  AuthRemoteDataSource({required this.client});

  Stream<UserEntity?> authStateChanges() {
      return client.auth.onAuthStateChange.map((event) {
        final user = event.session?.user;
        if (user == null) return null;
       return UserEntity(id: user.id, email: user.email ?? '');
      });
    }

  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    final response = await client.auth.signUp(
      email: email,
      password: password,
    );
    return response;
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    final response = await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    return response;
  }

  Future<void> signOut() async {
    await client.auth.signOut();
  }

  User? getCurrentUser() {
    return client.auth.currentUser;
  }


Future<void> signInWithGoogle() async {
  await client.auth.signInWithOAuth(
    OAuthProvider.google,
    redirectTo: 'com.example.rivo_app_beta://login-callback',
  );
}



}

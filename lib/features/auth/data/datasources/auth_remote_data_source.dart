import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rivo_app_beta/features/auth/domain/entities/user_entity.dart';

class AuthRemoteDataSource {
  final SupabaseClient client;

  AuthRemoteDataSource({required this.client});

  /// Listens to authentication state changes and returns a stream of UserEntity.
  /// Also ensures a corresponding profile record exists for every logged-in user.
  Stream<UserEntity?> authStateChanges() {
    return client.auth.onAuthStateChange.map((event) {
      final user = event.session?.user;
      if (user == null) return null;

      // Ensure profile is created for Google or OAuth users
      ensureProfileCreatedFor(user);

      return UserEntity(id: user.id, email: user.email ?? '');
    });
  }

  /// Signs up a user with email & password and stores username in metadata.
  /// Creates a profile entry in the 'profiles' table.
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    final response = await client.auth.signUp(
      email: email,
      password: password,
      data: {
        'username': username,
      },
    );

    final user = response.user;
    if (user != null) {
      await ensureProfileCreatedFor(user, usernameOverride: username);
    }

    return response;
  }

  /// Ensures a `profiles` record exists for the given Supabase user.
  /// Called after any type of authentication (OAuth, email, etc).
  Future<void> ensureProfileCreatedFor(User user, {String? usernameOverride}) async {
  final profile = await client
      .from('profiles')
      .select('id')
      .eq('id', user.id)
      .maybeSingle();

  if (profile == null) {
    final email = user.email;
    if (email == null) return; 

    final allowlisted = await client
        .from('seller_allowlist')
        .select('email')
        .eq('email', email) 
        .maybeSingle();

    final isSeller = allowlisted != null;

    await client.from('profiles').insert({
      'id': user.id,
      'username': usernameOverride ?? email.split('@')[0],
      'is_seller': isSeller,
    });
  }
}


  /// Checks if the given username already exists in the profiles table.
  Future<bool> checkUsername(String username) async {
    final response = await client
        .from('profiles')
        .select('username')
        .ilike('username', username)
        .maybeSingle();
    return response != null;
  }

  /// Checks if a given email already exists using a Supabase RPC function.
  Future<bool> checkEmail(String email) async {
    final result = await client.rpc('email_exists', params: {'email_address': email});
    return result as bool;
  }

  /// Signs in a user with email and password.
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Signs the current user out.
  Future<void> signOut() async {
    await client.auth.signOut();
  }

  /// Returns the current authenticated Supabase user.
  User? getCurrentUser() {
    return client.auth.currentUser;
  }

  /// Signs in with Google using Supabase OAuth.
  /// A profile will be created (if missing) once the auth state changes.
  Future<void> signInWithGoogle() async {
    await client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'com.example.rivo_app_beta://login-callback',
    );
    // Don't call ensureProfileCreated here – will be handled in authStateChanges
  }

  /// Sends a password reset email to the specified email address.
  Future<void> sendPasswordResetEmail(String email) async {
    await client.auth.resetPasswordForEmail(
      email,
      redirectTo: 'com.example.rivo_app_beta://reset-password',
    );
  }

  /// Resets the password using the provided token and new password.
  /// Throws if the reset token is invalid or expired.
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      await client.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } catch (e) {
      throw Exception('Failed to reset password. The link may have expired or is invalid.');
    }
  }
}

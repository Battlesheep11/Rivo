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
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    required String password,
  }) async {
    final response = await client.auth.signUp(
      email: email,
      password: password,
      data: {
        'username': username, // Pass username to the trigger
      },
    );

    if (response.user != null) {
      // After successful signup, create a profile entry
      await client.from('profiles').insert({
        'id': response.user!.id,
        'first_name': firstName,
        'last_name': lastName,
        'username': username,
      });
    }

    return response;
  }

  Future<bool> checkUsername(String username) async {
    final response = await client
      .from('profiles')
      .select('username')
      .ilike('username', username)
      .maybeSingle();
    final exists = response != null;
    return exists;
  }

  Future<bool> checkEmail(String email) async {
    final result = await client.rpc('email_exists', params: {'email_address': email});
    return result as bool;
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

  /// Sends a password reset email to the specified email address
  /// 
  /// Throws an exception if there's an error sending the email
  Future<void> sendPasswordResetEmail(String email) async {
    await client.auth.resetPasswordForEmail(
      email,
      redirectTo: 'com.example.rivo_app_beta://reset-password',
    );
  }

  /// Resets the password using the provided token and new password
  /// 
  /// Throws an exception if there's an error resetting the password
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      // First, sign out any existing session to prevent auto-login
      await client.auth.signOut();
      
      // Verify the token and get the user's email
      final session = await client.auth.verifyOTP(
        token: token,
        type: OtpType.recovery,
      );
      
      if (session.user == null) {
        throw Exception('Invalid or expired password reset link');
      }
      
      // Update the password
      await client.auth.updateUser(
        UserAttributes(
          password: newPassword,
        ),
      );
      
      // Sign out again to ensure the user needs to log in with the new password
      await client.auth.signOut();
      
    } catch (e) {
      throw Exception('Failed to reset password. The link may have expired or is invalid.');
    }
  }
}


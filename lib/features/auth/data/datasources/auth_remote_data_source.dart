import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rivo_app_beta/features/auth/domain/entities/user_entity.dart';

class AuthRemoteDataSource {
  final SupabaseClient client;

  AuthRemoteDataSource({required this.client});

  /// Stream of auth state → maps to your domain entity.
  /// Also guarantees a profile row exists once a user is logged in.
  Stream<UserEntity?> authStateChanges() {
    return client.auth.onAuthStateChange.map((event) {
      final user = event.session?.user;
      if (user == null) return null;

      ensureProfileCreatedFor(user);
      return UserEntity(id: user.id, email: user.email ?? '');
    });
  }

  /// Email/password sign up + store username.
  Future<AuthResponse> signUp({
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
      // Note: first_name/last_name omitted to align with repository API
      await client.from('profiles').insert({
        'id': response.user!.id,
        'username': username,
      });
    }

    return response;
  }




  /// Ensure a row in `profiles` for this user.
  Future<void> ensureProfileCreatedFor(
    User user, {
    String? usernameOverride,
  }) async {
    try {
      final profile = await client
          .from('profiles')
          .select('id')
          .eq('id', user.id)
          .maybeSingle();

      if (profile == null) {
        final email = user.email;
        if (email == null) {
          return;
        }

        final allowlisted = await client
            .from('seller_allowlist')
            .select('email')
            .eq('email', email)
            .maybeSingle();

        final isSeller = allowlisted != null;

        await client.from('profiles').insert({
          'id': user.id,
          'username': usernameOverride ?? email.split('@').first,
          'is_seller': isSeller,
        });
      }
    } catch (_) {
      // intentionally swallow to avoid breaking auth flow
    }
  }

  /// Username exists?
  Future<bool> checkUsername(String username) async {
    final response = await client
        .from('profiles')
        .select('username')
        .ilike('username', username)
        .maybeSingle();
    return response != null;
  }

  /// Email exists? (via RPC – ודאי שה־function קיים)
  Future<bool> checkEmail(String email) async {
    final result = await client.rpc('email_exists', params: {
      'email_address': email,
    });
    return result as bool;
  }

  /// Email/password sign in.
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) {
    return client.auth.signInWithPassword(email: email, password: password);
  }

  /// Google OAuth (Android/iOS Native).
  /// ודאי שהוספת ב־AndroidManifest את ה־intent filter עם ה־scheme com.rivo.app
  Future<void> signInWithGoogle() async {
    try {
      await client.auth.signInWithOAuth(
        Provider.google,
        redirectTo: 'com.rivo.app://login-callback',
        queryParams: const {
          'access_type': 'offline',
          'prompt': 'consent',
        },
      );

      final s = client.auth.currentSession;
      if (s?.user != null) {
        await ensureProfileCreatedFor(s!.user);
      }
    } catch (_) {
      // intentionally swallow to avoid breaking auth flow
    }
  }

  Future<void> signOut() => client.auth.signOut();

  User? getCurrentUser() => client.auth.currentUser;

  Future<void> sendPasswordResetEmail(String email) {
    return client.auth.resetPasswordForEmail(
      email,
      redirectTo: 'com.rivo.app://reset-password',
    );
  }

  Future<void> resetPassword({
    required String token, // kept for API symmetry
    required String newPassword,
  }) async {
    try {
      await client.auth.updateUser(UserAttributes(password: newPassword));
    } catch (_) {
      throw Exception(
        'Failed to reset password. The link may have expired or is invalid.',
      );
    }
  }


}

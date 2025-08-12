// lib/features/auth/data/datasources/auth_remote_data_source.dart
import 'dart:convert'; // utf8
import 'dart:math';    // Random.secure

import 'package:crypto/crypto.dart'; // sha256
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:rivo_app_beta/features/auth/domain/entities/user_entity.dart';

class AuthRemoteDataSource {
  final SupabaseClient client;

  AuthRemoteDataSource({required this.client});

  /// Emits your domain user (or null) on auth state changes
  Stream<UserEntity?> authStateChanges() {
    return client.auth.onAuthStateChange.map((event) {
      final user = event.session?.user;
      if (user == null) return null;

      ensureProfileCreatedFor(user);
      return UserEntity(id: user.id, email: user.email ?? '');
    });
  }
    return client.auth.onAuthStateChange.map((event) {
      final user = event.session?.user;
      if (user == null) return null;
      return UserEntity(id: user.id, email: user.email ?? '');
    });
  }

  /// Email/password sign up + store username.
  Future<AuthResponse> signUp({
  Future<AuthResponse> signUp({
    required String username,
    required String email,
    required String password,
  }) async {
    final response = await client.auth.signUp(
      email: email,
      password: password,
      data: {
        'username': username,
      },
    );
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
    // Note: your authStateChanges() stream should take care of navigation.
  }

  Future<bool> checkUsername(String username) async {
    final response =
        await client.from('profiles').select('id').eq('username', username);
    return response.isNotEmpty;
  }

  Future<bool> checkEmail(String email) async {
    final response =
        await client.from('profiles').select('id').eq('email', email);
    return response.isNotEmpty;
  }

  // -------- Apple Sign-In (native token flow via Supabase) --------

  String _randomNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }

  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<AuthResponse> signInWithApple() async {
    final rawNonce = _randomNonce();
    final hashedNonce = _sha256ofString(rawNonce);

    final appleCred = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: hashedNonce, // Apple expects SHA256(nonce)
    );

    final idToken = appleCred.identityToken;
    if (idToken == null) {
      throw Exception('No identityToken from Apple');
    }

    final res = await client.auth.signInWithIdToken(
      provider: OAuthProvider.apple,
      idToken: idToken,
      nonce: rawNonce, // RAW nonce here
    );

    return res;
  }
}

import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:rivo_app_beta/features/auth/domain/entities/user_entity.dart';

class AuthRemoteDataSource {
  final SupabaseClient client;
  AuthRemoteDataSource({required this.client});

  Stream<UserEntity?> authStateChanges() {
    return client.auth.onAuthStateChange.map((event) {
      final user = event.session?.user;
      if (user == null) return null;
      ensureProfileCreatedFor(user);
      return UserEntity(id: user.id, email: user.email ?? '');
    });
  }

  Future<AuthResponse> signUp({
    required String username,
    required String email,
    required String password,
  }) async {
    final response = await client.auth.signUp(
      email: email,
      password: password,
      data: {'username': username},
    );

    final user = response.user;
    if (user != null) {
      await ensureProfileCreatedFor(user, usernameOverride: username);
    }
    return response;
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) {
    return client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() => client.auth.signOut();

  User? getCurrentUser() => client.auth.currentUser;

  // -------------------- Google OAuth --------------------

  Future<void> signInWithGoogle() async {
    await client.auth.signInWithOAuth(
      OAuthProvider.google,
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
  }

  // -------------------- Apple OAuth --------------------

  String _randomNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
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
      scopes: const [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: hashedNonce,
    );

    final idToken = appleCred.identityToken;
    if (idToken == null) {
      throw Exception('No identityToken from Apple');
    }

    final res = await client.auth.signInWithIdToken(
      provider: OAuthProvider.apple,
      idToken: idToken,
      nonce: rawNonce,
    );

    final user = res.user;
    if (user != null) {
      final email = user.email ?? appleCred.email;
      final appleName = [
        appleCred.givenName,
        appleCred.familyName,
      ].where((p) => p != null && p.isNotEmpty).join(' ');
      final fallbackUsername = (appleName.isNotEmpty)
          ? appleName
          : (email != null
              ? email.split('@').first
              : 'user_${user.id.substring(0, 6)}');

      await ensureProfileCreatedFor(user, usernameOverride: fallbackUsername);
    }

    return res;
  }

  // -------------------- Helpers / profile bootstrap --------------------

  Future<bool> checkUsername(String username) async {
    final response = await client
        .from('profiles')
        .select('id')
        .eq('username', username)
        .limit(1);
    return response.isNotEmpty;
  }

  Future<bool> checkEmail(String email) async {
    final result = await client.rpc('email_exists', params: {
      'email_address': email,
    });
    return result as bool;
  }

  Future<void> sendPasswordResetEmail(String email) {
    // v2: email is positional
    return client.auth.resetPasswordForEmail(
      email,
      redirectTo: 'com.rivo.app://reset-password',
    );
  }

  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    await client.auth.updateUser(UserAttributes(password: newPassword));
  }

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
        final derivedUsername = usernameOverride ??
            (email != null
                ? email.split('@').first
                : 'user_${user.id.substring(0, 6)}');

        bool isSeller = false;
        if (email != null) {
          final allowlisted = await client
              .from('seller_allowlist')
              .select('email')
              .eq('email', email)
              .maybeSingle();
          isSeller = allowlisted != null;
        }

        await client.from('profiles').insert({
          'id': user.id,
          'username': derivedUsername,
          'is_seller': isSeller,
        });
      }
    } catch (_) {
      // ignore
    }
  }
}

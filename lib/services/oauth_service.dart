import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OAuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<AuthResponse?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        await _supabase.auth.signInWithOAuth(
          OAuthProvider.google,
          redirectTo: 'http://localhost:3000/auth/callback',
        );
        return null;
      } else {
        await _supabase.auth.signInWithOAuth(
          OAuthProvider.google,
          redirectTo: 'cloudos://auth/callback',
        );
        return null;
      }
    } catch (e) {
      throw Exception('Google sign-in failed: $e');
    }
  }

  Future<AuthResponse?> signInWithMicrosoft() async {
    try {
      if (kIsWeb) {
        await _supabase.auth.signInWithOAuth(
          OAuthProvider.azure,
          redirectTo: 'http://localhost:3000/auth/callback',
        );
        return null;
      } else {
        await _supabase.auth.signInWithOAuth(
          OAuthProvider.azure,
          redirectTo: 'cloudos://auth/callback',
        );
        return null;
      }
    } catch (e) {
      throw Exception('Microsoft sign-in failed: $e');
    }
  }

  Future<AuthResponse> signInWithApple() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final idToken = credential.identityToken;
      if (idToken == null) {
        throw Exception('Failed to get Apple ID token');
      }

      return await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.apple,
        idToken: idToken,
      );
    } catch (e) {
      throw Exception('Apple sign-in failed: $e');
    }
  }

  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception('Email sign-in failed: $e');
    }
  }

  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName},
      );

      if (response.user != null) {
        await _supabase.from('user_profiles').insert({
          'id': response.user!.id,
          'email': email,
          'full_name': fullName,
          'is_active': true,
          'role': 'user',
        });
      }

      return response;
    } catch (e) {
      throw Exception('Email sign-up failed: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }

  User? getCurrentUser() {
    return _supabase.auth.currentUser;
  }

  Stream<AuthState> get authStateChanges {
    return _supabase.auth.onAuthStateChange;
  }
}
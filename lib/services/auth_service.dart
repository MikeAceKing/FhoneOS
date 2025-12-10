import 'package:supabase_flutter/supabase_flutter.dart';

/// Authentication service for FhoneOS
/// Handles all authentication operations with Supabase
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  static AuthService get instance => _instance;

  SupabaseClient get _client => Supabase.instance.client;

  /// Get current user
  dynamic get currentUser => _client.auth.currentUser;

  /// Check if user is authenticated
  bool get isAuthenticated => currentUser != null;

  /// Sign in with email and password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

      // Verify user profile exists and is active
      if (response.user != null) {
        final profile = await _client
            .from('user_profiles')
            .select('is_active')
            .eq('id', response.user!.id)
            .single();

        // If user is not active, sign them out immediately
        if (profile['is_active'] != true) {
          await signOut();
          throw AuthException('Account is inactive');
        }
      }

      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Sign up with email, password, and profile data
  Future<dynamic> signUp({
    required String email,
    required String password,
    required String fullName,
    String? avatarUrl,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email.trim(),
        password: password,
        data: {
          'full_name': fullName,
          'avatar_url': avatarUrl ?? '',
          'role': 'user',
          'is_active': true,
        },
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  /// Reset password
  Future<void> resetPassword({required String email}) async {
    try {
      await _client.auth.resetPasswordForEmail(email.trim());
    } catch (e) {
      rethrow;
    }
  }

  /// Get user profile data from user_profiles table
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      if (!isAuthenticated) return null;

      final response = await _client
          .from('user_profiles')
          .select()
          .eq('id', currentUser!.id)
          .single();

      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Update user profile
  Future<void> updateUserProfile({String? fullName, String? avatarUrl}) async {
    try {
      if (!isAuthenticated) return;

      final updates = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (fullName != null) updates['full_name'] = fullName;
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;

      await _client
          .from('user_profiles')
          .update(updates)
          .eq('id', currentUser!.id);
    } catch (e) {
      rethrow;
    }
  }

  /// Listen to auth state changes
  Stream<dynamic> get authStateChanges => _client.auth.onAuthStateChange;

  Future<AuthResponse> signInWithOAuth(OAuthProvider provider) async {
    try {
      final response = await _client.auth.signInWithOAuth(
        provider,
        redirectTo: 'fhoneos://login-callback',
        authScreenLaunchMode: LaunchMode.externalApplication,
      );

      // Return an AuthResponse instead of bool
      return AuthResponse(session: null, user: null);
    } on AuthException catch (e) {
      throw AuthException('OAuth authentication failed: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error during OAuth: $e');
    }
  }

  Future<void> linkOAuthProvider(OAuthProvider provider) async {
    try {
      await _client.auth.signInWithOAuth(
        provider,
        redirectTo: 'fhoneos://link-callback',
        authScreenLaunchMode: LaunchMode.externalApplication,
      );
    } on AuthException catch (e) {
      throw AuthException('Failed to link provider: ${e.message}');
    }
  }

  Future<List<UserIdentity>> getLinkedIdentities() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return [];

      return user.identities ?? [];
    } catch (e) {
      return [];
    }
  }

  Future<void> unlinkIdentity(UserIdentity identity) async {
    try {
      await _client.auth.unlinkIdentity(identity);
    } on AuthException catch (e) {
      throw AuthException('Failed to unlink provider: ${e.message}');
    }
  }
}
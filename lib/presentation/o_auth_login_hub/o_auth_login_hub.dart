import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../services/auth_service.dart';
import '../fhone_os_dashboard/fhone_os_dashboard.dart';
import './widgets/biometric_prompt_widget.dart';
import './widgets/email_login_form_widget.dart';
import './widgets/oauth_provider_button_widget.dart';
import './widgets/privacy_consent_widget.dart';

class OAuthLoginHub extends StatefulWidget {
  const OAuthLoginHub({super.key});

  @override
  State<OAuthLoginHub> createState() => _OAuthLoginHubState();
}

class _OAuthLoginHubState extends State<OAuthLoginHub> {
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String? _errorMessage;
  bool _showEmailForm = false;
  bool _biometricAvailable = false;

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
    _checkAuthState();
  }

  Future<void> _checkBiometricAvailability() async {
    // Check if device supports biometric authentication
    setState(() {
      _biometricAvailable = true; // Platform-specific implementation needed
    });
  }

  Future<void> _checkAuthState() async {
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const FhoneOsDashboard()),
        );
      }
    }
  }

  Future<void> _handleOAuthLogin(OAuthProvider provider) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authService.signInWithOAuth(provider);

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const FhoneOsDashboard()),
        );
      }
    } on AuthException catch (e) {
      setState(() {
        _errorMessage = _getReadableError(e.message);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'An unexpected error occurred. Please try again.';
        _isLoading = false;
      });
    }
  }

  Future<void> _handleEmailLogin(String email, String password) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authService.signIn(email: email, password: password);

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const FhoneOsDashboard()),
        );
      }
    } on AuthException catch (e) {
      setState(() {
        _errorMessage = _getReadableError(e.message);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Invalid credentials or network error';
        _isLoading = false;
      });
    }
  }

  Future<void> _handleBiometricLogin() async {
    // Implement biometric authentication
    setState(() {
      _errorMessage = 'Biometric authentication is not yet configured';
    });
  }

  String _getReadableError(String error) {
    if (error.toLowerCase().contains('invalid')) {
      return 'Invalid email or password';
    } else if (error.toLowerCase().contains('network')) {
      return 'Network error. Please check your connection.';
    } else if (error.toLowerCase().contains('timeout')) {
      return 'Connection timeout. Please try again.';
    }
    return 'Authentication failed. Please try again.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.primary.withAlpha(26),
                Theme.of(context).colorScheme.secondary.withAlpha(13),
              ],
            ),
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: Column(
                children: [
                  // Logo and Title
                  Column(
                    children: [
                      Container(
                        width: 100.w,
                        height: 100.h,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withAlpha(77),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.phone_android,
                          size: 50.w,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 24.h),
                      Text(
                        'FhoneOS',
                        style:
                            Theme.of(context).textTheme.headlineLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Sign in to continue',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),

                  SizedBox(height: 48.h),

                  // Error Message
                  if (_errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline,
                              color: Colors.red[700], size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(
                                  color: Colors.red[700], fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Loading Indicator
                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 24),
                      child: CircularProgressIndicator(),
                    ),

                  // OAuth Providers
                  if (!_showEmailForm && !_isLoading) ...[
                    OAuthProviderButton(
                      provider: OAuthProvider.google,
                      onPressed: () => _handleOAuthLogin(OAuthProvider.google),
                      icon: Icons.g_mobiledata,
                      label: 'Continue with Google',
                      backgroundColor: Colors.white,
                      textColor: Colors.black87,
                    ),
                    SizedBox(height: 16.h),
                    OAuthProviderButton(
                      provider: OAuthProvider.apple,
                      onPressed: () => _handleOAuthLogin(OAuthProvider.apple),
                      icon: Icons.apple,
                      label: 'Continue with Apple',
                      backgroundColor: Colors.black,
                      textColor: Colors.white,
                    ),
                    SizedBox(height: 16.h),
                    OAuthProviderButton(
                      provider: OAuthProvider.github,
                      onPressed: () => _handleOAuthLogin(OAuthProvider.github),
                      icon: Icons.code,
                      label: 'Continue with GitHub',
                      backgroundColor: const Color(0xFF24292E),
                      textColor: Colors.white,
                    ),
                    SizedBox(height: 16.h),
                    OAuthProviderButton(
                      provider: OAuthProvider.azure,
                      onPressed: () => _handleOAuthLogin(OAuthProvider.azure),
                      icon: Icons.window,
                      label: 'Continue with Microsoft',
                      backgroundColor: const Color(0xFF00A4EF),
                      textColor: Colors.white,
                    ),

                    SizedBox(height: 32.h),

                    // Divider
                    Row(
                      children: [
                        const Expanded(child: Divider()),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'OR',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const Expanded(child: Divider()),
                      ],
                    ),

                    SizedBox(height: 32.h),

                    // Email/Password Option
                    OutlinedButton(
                      onPressed: () => setState(() => _showEmailForm = true),
                      style: OutlinedButton.styleFrom(
                        minimumSize: Size(double.infinity, 56.h),
                        side: BorderSide(
                            color: Theme.of(context).colorScheme.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.email_outlined, size: 20.w),
                          const SizedBox(width: 12),
                          const Text('Sign in with Email'),
                        ],
                      ),
                    ),

                    // Biometric Option
                    if (_biometricAvailable) ...[
                      SizedBox(height: 16.h),
                      BiometricPromptWidget(
                        onBiometricPressed: _handleBiometricLogin,
                      ),
                    ],
                  ],

                  // Email Form
                  if (_showEmailForm && !_isLoading)
                    EmailLoginFormWidget(
                      onLogin: _handleEmailLogin,
                      onBack: () => setState(() => _showEmailForm = false),
                    ),

                  SizedBox(height: 32.h),

                  // Privacy Consent
                  const PrivacyConsentWidget(),

                  SizedBox(height: 24.h),

                  // Account Recovery
                  TextButton(
                    onPressed: () {
                      // Navigate to account recovery
                    },
                    child: const Text('Forgot password?'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

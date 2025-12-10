import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import '../../routes/app_routes.dart';
import '../../services/oauth_service.dart';
import './widgets/biometric_setup_widget.dart';
import './widgets/oauth_buttons_widget.dart';
import './widgets/profile_setup_widget.dart';
import './widgets/registration_progress_widget.dart';
import './widgets/terms_acceptance_widget.dart';

class EnhancedOAuthRegistrationFlow extends StatefulWidget {
  const EnhancedOAuthRegistrationFlow({super.key});

  @override
  State<EnhancedOAuthRegistrationFlow> createState() =>
      _EnhancedOAuthRegistrationFlowState();
}

class _EnhancedOAuthRegistrationFlowState
    extends State<EnhancedOAuthRegistrationFlow> {
  final OAuthService _oauthService = OAuthService();
  int _currentStep = 0;
  bool _isLoading = false;
  String? _errorMessage;

  final Map<String, dynamic> _registrationData = {
    'provider': null,
    'email': '',
    'fullName': '',
    'avatarUrl': '',
    'biometricEnabled': false,
    'termsAccepted': false,
  };

  Future<void> _handleOAuthSignIn(String provider) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      switch (provider) {
        case 'google':
          await _oauthService.signInWithGoogle();
          break;
        case 'microsoft':
          await _oauthService.signInWithMicrosoft();
          break;
        case 'apple':
          await _oauthService.signInWithApple();
          break;
      }

      _registrationData['provider'] = provider;
      setState(() => _currentStep = 1);
    } catch (e) {
      setState(() => _errorMessage = 'Authentication failed: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleEmailSignUp(
      String email, String password, String fullName) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _oauthService.signUpWithEmail(
        email: email,
        password: password,
        fullName: fullName,
      );

      _registrationData['provider'] = 'email';
      _registrationData['email'] = email;
      _registrationData['fullName'] = fullName;
      setState(() => _currentStep = 1);
    } catch (e) {
      setState(() => _errorMessage = 'Sign up failed: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _handleProfileSetup(Map<String, String> profileData) {
    _registrationData.addAll(profileData);
    setState(() => _currentStep = 2);
  }

  void _handleBiometricSetup(bool enabled) {
    _registrationData['biometricEnabled'] = enabled;
    setState(() => _currentStep = 3);
  }

  Future<void> _handleCompleteRegistration() async {
    if (!_registrationData['termsAccepted']) {
      setState(() => _errorMessage = 'Please accept the terms and conditions');
      return;
    }

    setState(() => _isLoading = true);

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    Navigator.pushReplacementNamed(
      context,
      AppRoutes.fhoneOsDashboard,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            RegistrationProgressWidget(
              currentStep: _currentStep,
              totalSteps: 4,
            ),
            if (_errorMessage != null)
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade300),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildCurrentStep(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return OAuthButtonsWidget(
          onOAuthSignIn: _handleOAuthSignIn,
          onEmailSignUp: _handleEmailSignUp,
        );
      case 1:
        return ProfileSetupWidget(
          onComplete: _handleProfileSetup,
        );
      case 2:
        return BiometricSetupWidget(
          onComplete: _handleBiometricSetup,
        );
      case 3:
        return TermsAcceptanceWidget(
          onAccept: (accepted) {
            _registrationData['termsAccepted'] = accepted;
          },
          onComplete: _handleCompleteRegistration,
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

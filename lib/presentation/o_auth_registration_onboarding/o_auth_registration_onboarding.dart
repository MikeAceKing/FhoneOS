import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../models/oauth_provider.dart';
import '../../routes/app_routes.dart';
import '../../services/oauth_service.dart';
import './widgets/email_registration_form_widget.dart';
import './widgets/oauth_button_widget.dart';
import './widgets/terms_acceptance_widget.dart';

class OAuthRegistrationOnboarding extends StatefulWidget {
  const OAuthRegistrationOnboarding({super.key});

  @override
  State<OAuthRegistrationOnboarding> createState() =>
      _OAuthRegistrationOnboardingState();
}

class _OAuthRegistrationOnboardingState
    extends State<OAuthRegistrationOnboarding> {
  final OAuthService _oauthService = OAuthService();
  final List<OAuthProvider> _providers = OAuthProvider.getDefaultProviders();
  bool _isLoading = false;
  bool _termsAccepted = false;

  Future<void> _handleOAuthSignIn(String providerId) async {
    if (!_termsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Accepteer eerst de voorwaarden'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      switch (providerId) {
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

      if (mounted) {
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.premiumPlanSelectionHub,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Inloggen mislukt: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleEmailRegistration({
    required String email,
    required String password,
    required String fullName,
  }) async {
    if (!_termsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Accepteer eerst de voorwaarden'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _oauthService.signUpWithEmail(
        email: email,
        password: password,
        fullName: fullName,
      );

      if (mounted) {
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.premiumPlanSelectionHub,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registratie mislukt: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF6366F1),
              const Color(0xFF8B5CF6),
              const Color(0xFFEC4899),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(4.w),
              child: Container(
                constraints: BoxConstraints(maxWidth: 500),
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(26),
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.rocket_launch,
                      size: 48,
                      color: Color(0xFF6366F1),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Welkom bij FhoneOS',
                      style: GoogleFonts.inter(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      'Kies een inlogmethode om te beginnen',
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 4.h),
                    if (_isLoading)
                      CircularProgressIndicator()
                    else ...[
                      ..._providers.map((provider) => Padding(
                            padding: EdgeInsets.only(bottom: 2.h),
                            child: OAuthButtonWidget(
                              provider: provider,
                              onPressed: () => _handleOAuthSignIn(provider.id),
                            ),
                          )),
                      SizedBox(height: 2.h),
                      Row(
                        children: [
                          Expanded(child: Divider()),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 2.w),
                            child: Text(
                              'of',
                              style: GoogleFonts.inter(
                                color: Colors.grey[600],
                                fontSize: 12.sp,
                              ),
                            ),
                          ),
                          Expanded(child: Divider()),
                        ],
                      ),
                      SizedBox(height: 2.h),
                      EmailRegistrationFormWidget(
                        onSubmit: _handleEmailRegistration,
                      ),
                      SizedBox(height: 3.h),
                      TermsAcceptanceWidget(
                        isAccepted: _termsAccepted,
                        onChanged: (value) =>
                            setState(() => _termsAccepted = value),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
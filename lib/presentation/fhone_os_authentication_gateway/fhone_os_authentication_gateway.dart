import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import '../../services/auth_service.dart';
import './widgets/connection_status_widget.dart';
import './widgets/login_form_widget.dart';

class FhoneOSAuthenticationGateway extends StatefulWidget {
  const FhoneOSAuthenticationGateway({Key? key}) : super(key: key);

  @override
  State<FhoneOSAuthenticationGateway> createState() =>
      _FhoneOSAuthenticationGatewayState();
}

class _FhoneOSAuthenticationGatewayState
    extends State<FhoneOSAuthenticationGateway> {
  final _authService = AuthService.instance;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  void _checkAuthStatus() {
    if (_authService.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, AppRoutes.fhoneOsDashboard);
      });
    }
  }

  void _handleQuickDemoLogin() async {
    setState(() => _isLoading = true);
    try {
      await _authService.signIn(
        email: 'demo@cloudos.com',
        password: 'demo123456',
      );
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.fhoneOsDashboard);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Demo login failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
              const Color(0xFF0F172A),
              const Color(0xFF1E293B),
              const Color(0xFF334155),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 40.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const ConnectionStatusWidget(),
                  const SizedBox(height: 48),
                  _buildWelcomeHeader(),
                  const SizedBox(height: 32),
                  LoginFormWidget(
                    onLoginSuccess: () {
                      Navigator.pushReplacementNamed(
                        context,
                        AppRoutes.fhoneOsDashboard,
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  _buildDemoLoginButton(),
                  const SizedBox(height: 32),
                  _buildSignupPrompt(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    return Column(
      children: [
        Text(
          'Welcome to FhoneOS',
          style: GoogleFonts.inter(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Always connected to your cloud phone',
          style: GoogleFonts.inter(fontSize: 16, color: Colors.white70),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildDemoLoginButton() {
    return OutlinedButton.icon(
      onPressed: _isLoading ? null : _handleQuickDemoLogin,
      icon:
          _isLoading
              ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
              : const Icon(Icons.play_arrow, color: Colors.white70),
      label: Text(
        _isLoading ? 'Logging in...' : 'Quick Demo Login',
        style: GoogleFonts.inter(fontSize: 16, color: Colors.white70),
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        side: const BorderSide(color: Colors.white30),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildSignupPrompt() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'New to FhoneOS?',
          style: GoogleFonts.inter(fontSize: 14, color: Colors.white70),
        ),
        TextButton(
          onPressed: () {
            Navigator.pushNamed(context, AppRoutes.signupStepperFlow);
          },
          child: Text(
            'Create account',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF3B82F6),
            ),
          ),
        ),
      ],
    );
  }
}
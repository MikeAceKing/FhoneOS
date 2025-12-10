import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/auth_service.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/decorative_background_widget.dart';
import './widgets/login_form_widget.dart';
import './widgets/social_login_widget.dart';

/// FhoneOS Login Screen - "Always connected"
/// Rich authentication experience with demo access and social login
class WelcomeLoginScreen extends StatefulWidget {
  const WelcomeLoginScreen({super.key});

  @override
  State<WelcomeLoginScreen> createState() => _WelcomeLoginScreenState();
}

class _WelcomeLoginScreenState extends State<WelcomeLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await AuthService.instance.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      final userProfile = await AuthService.instance.getUserProfile();

      if (userProfile != null && userProfile['is_active'] == true) {
        HapticFeedback.mediumImpact();

        if (mounted) {
          Navigator.pushReplacementNamed(context, '/fhone-os-dashboard');
        }
      } else {
        await AuthService.instance.signOut();
        setState(() {
          _isLoading = false;
          _errorMessage =
              'Your account is currently inactive. Please contact support.';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Invalid email or password';
      });
    }
  }

  Future<void> _handleDemoLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    _emailController.text = 'demo@cloudos.com';
    _passwordController.text = 'CloudOS@2025';

    await Future.delayed(const Duration(milliseconds: 300));

    try {
      await AuthService.instance.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      final userProfile = await AuthService.instance.getUserProfile();

      if (userProfile != null && userProfile['is_active'] == true) {
        HapticFeedback.mediumImpact();

        if (mounted) {
          Navigator.pushReplacementNamed(context, '/fhone-os-dashboard');
        }
      } else {
        await AuthService.instance.signOut();
        setState(() {
          _isLoading = false;
          _errorMessage = 'Demo account is currently inactive.';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Demo login failed. Please try again.';
      });
    }
  }

  Future<void> _handleSocialLogin(String provider) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Simulate OAuth flow
    await Future.delayed(const Duration(seconds: 2));

    // Mock successful social login
    HapticFeedback.mediumImpact();

    if (mounted) {
      Navigator.pushReplacementNamed(context, '/fhone-os-dashboard');
    }
  }

  void _navigateToSignUp() {
    Navigator.pushNamed(context, '/fhoneos-signup-flow');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final keyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      body: SafeArea(
        child: Stack(
          children: [
            DecorativeBackgroundWidget(),

            SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: size.height - MediaQuery.of(context).padding.top,
                ),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: keyboardVisible ? 16.0 : 40.0,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildFhoneOSHeader(theme),

                        SizedBox(height: keyboardVisible ? 24.0 : 48.0),

                        LoginFormWidget(
                          formKey: _formKey,
                          emailController: _emailController,
                          passwordController: _passwordController,
                          isPasswordVisible: _isPasswordVisible,
                          onPasswordVisibilityToggle: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                          errorMessage: _errorMessage,
                        ),

                        const SizedBox(height: 16.0),

                        _buildDemoLoginButton(theme),

                        const SizedBox(height: 24.0),

                        _buildActionButtons(theme),

                        const SizedBox(height: 32.0),

                        SocialLoginWidget(
                          onSocialLogin: (provider) async {},
                          isLoading: _isLoading,
                        ),

                        const SizedBox(height: 16.0),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            if (_isLoading)
              Container(
                color: Colors.black.withValues(alpha: 0.7),
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF00D9FF),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFhoneOSHeader(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF00D9FF), Color(0xFF7B2FFF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20.0),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00D9FF).withValues(alpha: 0.3),
                blurRadius: 20.0,
                spreadRadius: 2.0,
              ),
            ],
          ),
          child: CustomIconWidget(
            iconName: 'phone_in_talk',
            color: Colors.white,
            size: 48.0,
          ),
        ),
        const SizedBox(height: 24.0),
        Text(
          'Welcome to FhoneOS',
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 28.0,
          ),
        ),
        const SizedBox(height: 8.0),
        Text(
          'Always connected to your cloud phone.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 16.0,
          ),
        ),
      ],
    );
  }

  Widget _buildDemoLoginButton(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF7B2FFF).withValues(alpha: 0.2),
            const Color(0xFF00D9FF).withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: const Color(0xFF00D9FF).withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isLoading ? null : _handleDemoLogin,
          borderRadius: BorderRadius.circular(12.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 14.0,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00D9FF).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: CustomIconWidget(
                    iconName: 'flash_on',
                    color: const Color(0xFF00D9FF),
                    size: 20.0,
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quick Demo Login',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2.0),
                      Text(
                        'Explore FhoneOS instantly',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 12.0,
                        ),
                      ),
                    ],
                  ),
                ),
                CustomIconWidget(
                  iconName: 'arrow_forward',
                  color: const Color(0xFF00D9FF),
                  size: 20.0,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(ThemeData theme) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56.0,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00D9FF),
              foregroundColor: const Color(0xFF0A0E27),
              elevation: 4.0,
              shadowColor: const Color(0xFF00D9FF).withValues(alpha: 0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
            child:
                _isLoading
                    ? const SizedBox(
                      height: 24.0,
                      width: 24.0,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF0A0E27),
                        ),
                      ),
                    )
                    : Text(
                      'Sign In',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: const Color(0xFF0A0E27),
                        fontWeight: FontWeight.w700,
                        fontSize: 16.0,
                      ),
                    ),
          ),
        ),

        const SizedBox(height: 16.0),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'New to FhoneOS?',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(width: 8.0),
            GestureDetector(
              onTap: _isLoading ? null : _navigateToSignUp,
              child: Text(
                'Create account',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF00D9FF),
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                  decorationColor: const Color(0xFF00D9FF),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

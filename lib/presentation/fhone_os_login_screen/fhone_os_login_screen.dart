import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../services/auth_service.dart';
import './widgets/login_form_widget.dart';
import './widgets/fhone_os_branding_widget.dart';
import './widgets/demo_credentials_widget.dart';

/// FhoneOS Login Screen
/// Provides secure authentication with modern Flutter design patterns
class FhoneOsLoginScreen extends StatefulWidget {
  const FhoneOsLoginScreen({super.key});

  @override
  State<FhoneOsLoginScreen> createState() => _FhoneOsLoginScreenState();
}

class _FhoneOsLoginScreenState extends State<FhoneOsLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await AuthService.instance.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      // Navigate to dashboard on successful login
      Navigator.pushReplacementNamed(context, '/fhone-os-dashboard');
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login failed: ${e.toString()}'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _togglePasswordVisibility() {
    setState(() => _obscurePassword = !_obscurePassword);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFF020617), // slate-950
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // FhoneOS Branding
                  const FhoneOsBrandingWidget(),
                  SizedBox(height: 4.h),

                  // Login Form Card
                  Card(
                    elevation: 0,
                    color: const Color(0xFF020617),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                      side: const BorderSide(
                        color: Color(0xFF1E293B),
                      ), // slate-800
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(18),
                      child: LoginFormWidget(
                        formKey: _formKey,
                        emailController: _emailController,
                        passwordController: _passwordController,
                        obscurePassword: _obscurePassword,
                        isLoading: _isLoading,
                        onTogglePasswordVisibility: _togglePasswordVisibility,
                        onLogin: _handleLogin,
                      ),
                    ),
                  ),
                  SizedBox(height: 2.h),

                  // Demo Credentials Section
                  const DemoCredentialsWidget(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

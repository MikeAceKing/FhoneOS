import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/auth_service.dart';
import '../../routes/app_routes.dart';
import './widgets/auth_tab_bar_widget.dart';
import './widgets/login_tab_widget.dart';
import './widgets/signup_tab_widget.dart';
import './widgets/social_auth_widget.dart';

/// Registration & Authentication Hub - Complete authentication system
/// Implements tabbed login/signup with OAuth integration and auto-demo login
class RegistrationAuthenticationHub extends StatefulWidget {
  const RegistrationAuthenticationHub({super.key});

  @override
  State<RegistrationAuthenticationHub> createState() =>
      _RegistrationAuthenticationHubState();
}

class _RegistrationAuthenticationHubState
    extends State<RegistrationAuthenticationHub>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _handleDemoLogin() async {
    setState(() => _isLoading = true);

    try {
      // Auto-login with demo credentials
      await AuthService.instance.signIn(
        email: 'demo@cloudos.com',
        password: 'CloudOS@2025',
      );

      HapticFeedback.mediumImpact();

      if (mounted) {
        // Check if user has active subscription
        final userProfile = await AuthService.instance.getUserProfile();
        if (userProfile != null && userProfile['is_active'] == true) {
          Navigator.pushReplacementNamed(context, AppRoutes.fhoneOsDashboard);
        } else {
          // New user - redirect to subscription selection
          Navigator.pushReplacementNamed(
            context,
            AppRoutes.subscriptionManagementHub,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Demo login failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Stack(
          children: [
            // Main content
            CustomScrollView(
              slivers: [
                // App bar with branding
                SliverAppBar(
                  floating: true,
                  elevation: 0,
                  backgroundColor: theme.colorScheme.primary,
                  title: Text(
                    'FhoneOS',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // Content
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Welcome header
                        Text(
                          'Welcome!',
                          style: theme.textTheme.displaySmall?.copyWith(
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          'Sign in or create your account',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.7,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32.0),

                        // Tab bar
                        AuthTabBarWidget(controller: _tabController),

                        const SizedBox(height: 24.0),

                        // Tab content
                        SizedBox(
                          height: size.height * 0.5,
                          child: TabBarView(
                            controller: _tabController,
                            children: const [
                              LoginTabWidget(),
                              SignupTabWidget(),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24.0),

                        // Demo login button
                        OutlinedButton.icon(
                          onPressed: _isLoading ? null : _handleDemoLogin,
                          icon: Icon(
                            Icons.rocket_launch,
                            color: theme.colorScheme.secondary,
                          ),
                          label: Text(
                            'Try Demo Account',
                            style: TextStyle(
                              color: theme.colorScheme.secondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            side: BorderSide(
                              color: theme.colorScheme.secondary,
                              width: 2.0,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24.0),

                        // Social authentication
                        const SocialAuthWidget(),

                        const SizedBox(height: 16.0),

                        // Terms and privacy
                        Text(
                          'By continuing, you agree to our Terms of Service and Privacy Policy',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.6,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Loading overlay
            if (_isLoading)
              Container(
                color: Colors.black.withValues(alpha: 0.5),
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

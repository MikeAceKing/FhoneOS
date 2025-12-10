import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../services/auth_service.dart';

/// Social authentication options (Google, Apple, Microsoft)
class SocialAuthWidget extends StatefulWidget {
  const SocialAuthWidget({super.key});

  @override
  State<SocialAuthWidget> createState() => _SocialAuthWidgetState();
}

class _SocialAuthWidgetState extends State<SocialAuthWidget> {
  bool _isLoading = false;

  Future<void> _handleSocialLogin(
    OAuthProvider provider,
    String providerName,
  ) async {
    setState(() => _isLoading = true);

    try {
      await AuthService.instance.signInWithOAuth(provider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$providerName authentication initiated'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$providerName login failed: ${e.toString()}'),
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

    return Column(
      children: [
        // Divider with "or continue with"
        Row(
          children: [
            Expanded(
              child: Divider(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'or continue with',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ),
            Expanded(
              child: Divider(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16.0),

        // Social login buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Google
            _SocialLoginButton(
              icon: Icons.g_mobiledata_rounded,
              label: 'Google',
              color: Colors.red,
              onPressed:
                  _isLoading
                      ? null
                      : () =>
                          _handleSocialLogin(OAuthProvider.google, 'Google'),
            ),

            // Apple
            _SocialLoginButton(
              icon: Icons.apple,
              label: 'Apple',
              color: Colors.black,
              onPressed:
                  _isLoading
                      ? null
                      : () => _handleSocialLogin(OAuthProvider.apple, 'Apple'),
            ),

            // Microsoft
            _SocialLoginButton(
              icon: Icons.window,
              label: 'Microsoft',
              color: Colors.blue,
              onPressed:
                  _isLoading
                      ? null
                      : () =>
                          _handleSocialLogin(OAuthProvider.azure, 'Microsoft'),
            ),
          ],
        ),
      ],
    );
  }
}

class _SocialLoginButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onPressed;

  const _SocialLoginButton({
    required this.icon,
    required this.label,
    required this.color,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: color, size: 24.0),
        label: Text(
          label,
          style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 12.0),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
          side: BorderSide(color: theme.colorScheme.outline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),
    );
  }
}

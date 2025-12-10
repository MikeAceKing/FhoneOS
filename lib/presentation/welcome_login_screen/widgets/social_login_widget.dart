import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Social login options with OAuth integration
/// Supports Facebook and Snapchat authentication
class SocialLoginWidget extends StatelessWidget {
  final Function(String) onSocialLogin;
  final bool isLoading;

  const SocialLoginWidget({
    super.key,
    required this.onSocialLogin,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Divider with text
        Row(
          children: [
            Expanded(
              child: Divider(
                color: theme.colorScheme.outline.withValues(alpha: 0.5),
                thickness: 1.0,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Or continue with',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            Expanded(
              child: Divider(
                color: theme.colorScheme.outline.withValues(alpha: 0.5),
                thickness: 1.0,
              ),
            ),
          ],
        ),

        const SizedBox(height: 24.0),

        // Social login buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSocialButton(
              context: context,
              provider: 'Facebook',
              icon: 'facebook',
              color: const Color(0xFF1877F2),
            ),
            const SizedBox(width: 24.0),
            _buildSocialButton(
              context: context,
              provider: 'Snapchat',
              icon: 'camera_alt',
              color: const Color(0xFFFFFC00),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required BuildContext context,
    required String provider,
    required String icon,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : () => onSocialLogin(provider),
        borderRadius: BorderRadius.circular(12.0),
        child: Container(
          width: 56.0,
          height: 56.0,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.3),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8.0,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: CustomIconWidget(
              iconName: icon,
              color: color,
              size: 28.0,
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

/// Custom tab bar for authentication modes (Login/Sign Up)
class AuthTabBarWidget extends StatelessWidget {
  final TabController controller;

  const AuthTabBarWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: TabBar(
        controller: controller,
        indicator: BoxDecoration(
          color: theme.colorScheme.primary,
          borderRadius: BorderRadius.circular(12.0),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: theme.colorScheme.onSurface.withValues(
          alpha: 0.6,
        ),
        labelStyle: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        tabs: const [Tab(text: 'Login'), Tab(text: 'Sign Up')],
      ),
    );
  }
}

import 'package:flutter/material.dart';

/// Decorative background with curved blue elements
/// Creates immersive brand experience with animated curves
class DecorativeBackgroundWidget extends StatelessWidget {
  const DecorativeBackgroundWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Stack(
      children: [
        // Top-right curved decoration
        Positioned(
          top: -size.height * 0.15,
          right: -size.width * 0.2,
          child: Container(
            width: size.width * 0.8,
            height: size.height * 0.4,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
          ),
        ),

        // Bottom-left curved decoration
        Positioned(
          bottom: -size.height * 0.1,
          left: -size.width * 0.3,
          child: Container(
            width: size.width * 0.7,
            height: size.height * 0.35,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
          ),
        ),

        // Additional accent curve
        Positioned(
          top: size.height * 0.3,
          left: -size.width * 0.15,
          child: Container(
            width: size.width * 0.5,
            height: size.height * 0.25,
            decoration: BoxDecoration(
              color: theme.colorScheme.secondary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }
}

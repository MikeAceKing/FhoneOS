import 'package:flutter/material.dart';
import '../camera_interface.dart';

/// Mode selector widget
/// Allows switching between photo, video, and portrait modes
class ModeSelectorWidget extends StatelessWidget {
  final CaptureMode currentMode;
  final Function(CaptureMode) onModeChanged;

  const ModeSelectorWidget({
    super.key,
    required this.currentMode,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildModeButton(
          context: context,
          mode: CaptureMode.photo,
          label: 'PHOTO',
          isSelected: currentMode == CaptureMode.photo,
        ),
        const SizedBox(width: 24),
        _buildModeButton(
          context: context,
          mode: CaptureMode.video,
          label: 'VIDEO',
          isSelected: currentMode == CaptureMode.video,
        ),
        const SizedBox(width: 24),
        _buildModeButton(
          context: context,
          mode: CaptureMode.portrait,
          label: 'PORTRAIT',
          isSelected: currentMode == CaptureMode.portrait,
        ),
      ],
    );
  }

  Widget _buildModeButton({
    required BuildContext context,
    required CaptureMode mode,
    required String label,
    required bool isSelected,
  }) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => onModeChanged(mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withValues(alpha: 0.3)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            color: isSelected
                ? theme.colorScheme.primary
                : Colors.white.withValues(alpha: 0.7),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}

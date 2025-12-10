import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Theme selection widget with dark/light/system options
class ThemeSelectorWidget extends StatelessWidget {
  final String currentTheme;
  final Function(String) onThemeChanged;

  const ThemeSelectorWidget({
    super.key,
    required this.currentTheme,
    required this.onThemeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Theme Mode',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12.0),
          Row(
            children: [
              Expanded(
                child: _buildThemeOption(
                  context: context,
                  label: 'Light',
                  value: 'light',
                  icon: Icons.light_mode,
                ),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: _buildThemeOption(
                  context: context,
                  label: 'Dark',
                  value: 'dark',
                  icon: Icons.dark_mode,
                ),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: _buildThemeOption(
                  context: context,
                  label: 'System',
                  value: 'system',
                  icon: Icons.brightness_auto,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption({
    required BuildContext context,
    required String label,
    required String value,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    final isSelected = currentTheme == value;

    return GestureDetector(
      onTap: () => onThemeChanged(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withValues(alpha: 0.1)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withValues(alpha: 0.2),
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
              size: 24.0,
            ),
            const SizedBox(height: 4.0),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

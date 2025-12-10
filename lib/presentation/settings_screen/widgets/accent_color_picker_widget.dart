import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Accent color picker widget with brand palette
class AccentColorPickerWidget extends StatelessWidget {
  final Color currentColor;
  final Function(Color) onColorChanged;

  const AccentColorPickerWidget({
    super.key,
    required this.currentColor,
    required this.onColorChanged,
  });

  static const List<Color> brandColors = [
    Color(0xFF4A9EFF), // Bright blue
    Color(0xFF00D4AA), // Green accent
    Color(0xFFF5A623), // Yellow
    Color(0xFFFF4757), // Red
    Color(0xFF9B59B6), // Purple
    Color(0xFF3498DB), // Light blue
    Color(0xFFE74C3C), // Orange red
    Color(0xFF1ABC9C), // Turquoise
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Accent Color',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12.0),
          Wrap(
            spacing: 12.0,
            runSpacing: 12.0,
            children: brandColors.map((color) {
              final isSelected = currentColor.value == color.value;
              return GestureDetector(
                onTap: () => onColorChanged(color),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 48.0,
                  height: 48.0,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? theme.colorScheme.onSurface
                          : Colors.transparent,
                      width: 3.0,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: color.withValues(alpha: 0.4),
                              blurRadius: 8.0,
                              spreadRadius: 2.0,
                            ),
                          ]
                        : null,
                  ),
                  child: isSelected
                      ? Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 24.0,
                        )
                      : null,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

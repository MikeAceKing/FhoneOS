import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class PlatformFilterWidget extends StatelessWidget {
  final String selectedPlatform;
  final Function(String) onPlatformChanged;

  const PlatformFilterWidget({
    super.key,
    required this.selectedPlatform,
    required this.onPlatformChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        child: Row(
          children: [
            _buildFilterChip(theme, 'all', 'All', Icons.chat_bubble),
            SizedBox(width: 2.w),
            _buildFilterChip(theme, 'whatsapp', 'WhatsApp', Icons.help_outline),
            SizedBox(width: 2.w),
            _buildFilterChip(theme, 'sms', 'SMS', Icons.message),
            SizedBox(width: 2.w),
            _buildFilterChip(theme, 'telegram', 'Telegram', Icons.telegram),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(
      ThemeData theme, String platform, String label, IconData icon) {
    final isSelected = selectedPlatform == platform;

    return GestureDetector(
      onTap: () => onPlatformChanged(platform),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF25D366)
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected
                  ? Colors.white
                  : theme.colorScheme.onSurfaceVariant,
            ),
            SizedBox(width: 1.w),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isSelected
                    ? Colors.white
                    : theme.colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

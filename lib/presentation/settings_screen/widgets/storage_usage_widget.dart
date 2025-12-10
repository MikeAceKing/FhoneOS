import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Storage usage breakdown widget with visual indicators
class StorageUsageWidget extends StatelessWidget {
  final Map<String, double> storageData;
  final double totalStorage;

  const StorageUsageWidget({
    super.key,
    required this.storageData,
    required this.totalStorage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final usedStorage =
        storageData.values.fold(0.0, (sum, value) => sum + value);
    final usagePercentage =
        (usedStorage / totalStorage * 100).clamp(0.0, 100.0);

    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Storage Used',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Text(
                '${usedStorage.toStringAsFixed(1)} GB / ${totalStorage.toStringAsFixed(1)} GB',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12.0),
          ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: LinearProgressIndicator(
              value: usagePercentage / 100,
              minHeight: 8.0,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(
                usagePercentage > 80
                    ? theme.colorScheme.error
                    : theme.colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 16.0),
          ...storageData.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  Container(
                    width: 12.0,
                    height: 12.0,
                    decoration: BoxDecoration(
                      color: _getCategoryColor(entry.key, theme),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: Text(
                      entry.key,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  Text(
                    '${entry.value.toStringAsFixed(2)} GB',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category, ThemeData theme) {
    switch (category.toLowerCase()) {
      case 'media':
        return const Color(0xFF4A9EFF);
      case 'messages':
        return const Color(0xFF00D4AA);
      case 'cache':
        return const Color(0xFFF5A623);
      case 'documents':
        return const Color(0xFF9B59B6);
      default:
        return theme.colorScheme.primary;
    }
  }
}

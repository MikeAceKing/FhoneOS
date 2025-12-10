import 'package:flutter/material.dart';

import '../../../core/app_export.dart';

/// Device card widget showing connected device information
class DeviceCardWidget extends StatelessWidget {
  final String deviceName;
  final String deviceType;
  final String lastSync;
  final bool isCurrentDevice;
  final VoidCallback? onLogout;

  const DeviceCardWidget({
    super.key,
    required this.deviceName,
    required this.deviceType,
    required this.lastSync,
    this.isCurrentDevice = false,
    this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: isCurrentDevice
              ? theme.colorScheme.primary
              : theme.colorScheme.outline.withValues(alpha: 0.2),
          width: isCurrentDevice ? 2.0 : 1.0,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: CustomIconWidget(
              iconName: _getDeviceIcon(deviceType),
              color: theme.colorScheme.onPrimaryContainer,
              size: 24.0,
            ),
          ),
          const SizedBox(width: 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        deviceName,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isCurrentDevice) ...[
                      const SizedBox(width: 8.0),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 2.0,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        child: Text(
                          'Current',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4.0),
                Text(
                  'Last sync: $lastSync',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (!isCurrentDevice && onLogout != null) ...[
            const SizedBox(width: 8.0),
            IconButton(
              icon: CustomIconWidget(
                iconName: 'logout',
                color: theme.colorScheme.error,
                size: 20.0,
              ),
              onPressed: onLogout,
              tooltip: 'Logout',
            ),
          ],
        ],
      ),
    );
  }

  String _getDeviceIcon(String type) {
    switch (type.toLowerCase()) {
      case 'mobile':
        return 'smartphone';
      case 'tablet':
        return 'tablet';
      case 'desktop':
        return 'computer';
      case 'web':
        return 'language';
      default:
        return 'devices';
    }
  }
}

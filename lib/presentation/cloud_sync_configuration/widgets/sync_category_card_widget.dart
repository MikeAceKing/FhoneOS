import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/sync_configuration.dart';

class SyncCategoryCardWidget extends StatelessWidget {
  final SyncConfiguration configuration;
  final Function(bool) onToggle;
  final VoidCallback onSettingsTap;

  const SyncCategoryCardWidget({
    Key? key,
    required this.configuration,
    required this.onToggle,
    required this.onSettingsTap,
  }) : super(key: key);

  IconData _getCategoryIcon() {
    switch (configuration.categoryType) {
      case 'contacts':
        return Icons.contacts;
      case 'messages':
        return Icons.message;
      case 'call_history':
        return Icons.phone;
      case 'media':
        return Icons.photo_library;
      case 'app_settings':
        return Icons.settings;
      case 'device_preferences':
        return Icons.devices;
      default:
        return Icons.sync;
    }
  }

  Color _getCategoryColor() {
    switch (configuration.categoryType) {
      case 'contacts':
        return Colors.blue;
      case 'messages':
        return Colors.green;
      case 'call_history':
        return Colors.purple;
      case 'media':
        return Colors.orange;
      case 'app_settings':
        return Colors.teal;
      case 'device_preferences':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }

  String _formatLastSync() {
    if (configuration.lastSyncAt == null) return 'Never synced';
    final now = DateTime.now();
    final diff = now.difference(configuration.lastSyncAt!);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    final categoryColor = _getCategoryColor();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: categoryColor.withAlpha(26),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _getCategoryIcon(),
                  color: categoryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      configuration.categoryName,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatLastSync(),
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: configuration.isEnabled,
                onChanged: onToggle,
                activeColor: categoryColor,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildInfoChip(
                  'Frequency',
                  configuration.syncFrequency.toUpperCase(),
                  Icons.schedule,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildInfoChip(
                  'Storage',
                  '${configuration.storageUsedMb.toStringAsFixed(1)} MB',
                  Icons.storage,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (configuration.wifiOnly)
                _buildStatusBadge('WiFi Only', Icons.wifi, Colors.blue),
              if (configuration.backgroundSync)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: _buildStatusBadge(
                      'Background', Icons.cloud_sync, Colors.green),
                ),
              const Spacer(),
              TextButton.icon(
                onPressed: onSettingsTap,
                icon: Icon(Icons.settings, size: 16, color: categoryColor),
                label: Text(
                  'Settings',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: categoryColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
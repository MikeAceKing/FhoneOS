import 'package:flutter/material.dart';

class PermissionCategoryWidget extends StatelessWidget {
  final String title;
  final String description;
  final List<Map<String, String>> permissions;
  final Color categoryColor;

  const PermissionCategoryWidget({
    super.key,
    required this.title,
    required this.description,
    required this.permissions,
    required this.categoryColor,
  });

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'phone':
        return Icons.phone;
      case 'message':
        return Icons.message;
      case 'contacts':
        return Icons.contacts;
      case 'camera_alt':
        return Icons.camera_alt;
      case 'mic':
        return Icons.mic;
      case 'storage':
        return Icons.storage;
      case 'location_on':
        return Icons.location_on;
      case 'location_searching':
        return Icons.location_searching;
      case 'my_location':
        return Icons.my_location;
      case 'calendar_today':
        return Icons.calendar_today;
      case 'notifications':
        return Icons.notifications;
      case 'fingerprint':
        return Icons.fingerprint;
      default:
        return Icons.help_outline;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'granted':
        return Colors.green;
      case 'denied':
        return Colors.red;
      case 'restricted':
        return Colors.orange;
      case 'not_requested':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'granted':
        return 'Granted';
      case 'denied':
        return 'Denied';
      case 'restricted':
        return 'Restricted';
      case 'not_requested':
        return 'Not Requested';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: categoryColor.withAlpha(26),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.shield, color: categoryColor, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...permissions.map((permission) {
              final status = permission['status'] ?? 'not_requested';
              final iconName = permission['icon'] ?? 'help_outline';
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(
                      _getIconData(iconName),
                      color: Colors.grey[700],
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        permission['name'] ?? '',
                        style: const TextStyle(fontSize: 15),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(status).withAlpha(26),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getStatusText(status),
                        style: TextStyle(
                          fontSize: 12,
                          color: _getStatusColor(status),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Switch(
                      value: status == 'granted',
                      onChanged: (value) {},
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

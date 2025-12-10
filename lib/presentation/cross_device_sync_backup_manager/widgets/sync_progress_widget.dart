import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class SyncProgressWidget extends StatelessWidget {
  final Map<String, dynamic> syncStats;

  const SyncProgressWidget({
    Key? key,
    required this.syncStats,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final contactsTotal = syncStats['contacts_total'] ?? 0;
    final contactsSynced = syncStats['contacts_synced'] ?? 0;
    final messagesTotal = syncStats['messages_total'] ?? 0;
    final messagesSynced = syncStats['messages_synced'] ?? 0;
    final mediaTotal = syncStats['media_total'] ?? 0;
    final mediaSynced = syncStats['media_synced'] ?? 0;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSyncCard(
          context,
          icon: Icons.contacts,
          title: 'Contacts',
          total: contactsTotal,
          synced: contactsSynced,
          color: Colors.blue,
        ),
        const SizedBox(height: 12),
        _buildSyncCard(
          context,
          icon: Icons.message,
          title: 'Messages',
          total: messagesTotal,
          synced: messagesSynced,
          color: Colors.green,
        ),
        const SizedBox(height: 12),
        _buildSyncCard(
          context,
          icon: Icons.perm_media,
          title: 'Media Files',
          total: mediaTotal,
          synced: mediaSynced,
          color: Colors.purple,
        ),
        const SizedBox(height: 24),
        _buildStorageUsageCard(context),
      ],
    );
  }

  Widget _buildSyncCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required int total,
    required int synced,
    required Color color,
  }) {
    final progress = total > 0 ? synced / total : 0.0;
    final percentage = (progress * 100).toInt();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withAlpha(26),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$synced / $total items synced',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '$percentage%',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: color.withAlpha(26),
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 8,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStorageUsageCard(BuildContext context) {
    final storageUsed = syncStats['storage_used_gb'] ?? 0.0;
    final storageTotal = syncStats['storage_total_gb'] ?? 50.0;
    final usagePercentage = (storageUsed / storageTotal * 100).toInt();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Storage Usage',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: storageUsed,
                      title: '${storageUsed.toStringAsFixed(1)} GB',
                      color: Theme.of(context).primaryColor,
                      radius: 80,
                      titleStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    PieChartSectionData(
                      value: storageTotal - storageUsed,
                      title:
                          '${(storageTotal - storageUsed).toStringAsFixed(1)} GB',
                      color: Colors.grey[300],
                      radius: 80,
                      titleStyle: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total: ${storageTotal.toStringAsFixed(1)} GB',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  '$usagePercentage% Used',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

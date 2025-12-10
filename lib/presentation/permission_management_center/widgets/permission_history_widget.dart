import 'package:flutter/material.dart';

class PermissionHistoryWidget extends StatelessWidget {
  const PermissionHistoryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final historyItems = [
      {
        'permission': 'Camera',
        'action': 'Granted',
        'timestamp': '2 hours ago',
        'context': 'Setup wizard - profile photos',
        'frequency': 25,
      },
      {
        'permission': 'Microphone',
        'action': 'Denied',
        'timestamp': '1 day ago',
        'context': 'User revoked in settings',
        'frequency': 0,
      },
      {
        'permission': 'Location',
        'action': 'Granted',
        'timestamp': '3 days ago',
        'context': 'Map navigation feature',
        'frequency': 15,
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: historyItems.length,
      itemBuilder: (context, index) {
        final item = historyItems[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: item['action'] == 'Granted'
                  ? Colors.green[100]
                  : Colors.red[100],
              child: Icon(
                item['action'] == 'Granted' ? Icons.check : Icons.close,
                color: item['action'] == 'Granted' ? Colors.green : Colors.red,
              ),
            ),
            title: Text(
              '${item['permission']} - ${item['action']}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(item['context'] as String),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      item['timestamp'] as String,
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.trending_up, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      '${item['frequency']} uses',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }
}

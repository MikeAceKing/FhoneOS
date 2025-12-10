import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class UsageHistoryListWidget extends StatelessWidget {
  final List<Map<String, dynamic>> usageHistory;

  const UsageHistoryListWidget({
    super.key,
    required this.usageHistory,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: usageHistory.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final record = usageHistory[index];
          final usageType = record['usage_type'] as String;
          final createdAt = DateTime.parse(record['created_at'] as String);
          final direction = record['direction'] as String?;
          final phoneNumber = record['phone_numbers'] as Map<String, dynamic>?;
          final number =
              phoneNumber?['e164_number'] as String? ?? 'Onbekend nummer';

          final isCall = usageType == 'call';
          final duration =
              isCall ? record['duration_seconds'] as int? ?? 0 : null;
          final cost = (record['cost'] as num?)?.toDouble() ?? 0.0;

          return ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isCall
                    ? Colors.blue.withAlpha(26)
                    : Colors.green.withAlpha(26),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isCall ? Icons.phone : Icons.message,
                color: isCall ? Colors.blue : Colors.green,
                size: 20,
              ),
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    number,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: direction == 'outbound'
                        ? Colors.orange.withAlpha(26)
                        : Colors.blue.withAlpha(26),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    direction == 'outbound' ? 'Uitgaand' : 'Inkomend',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: direction == 'outbound'
                          ? Colors.orange[700]
                          : Colors.blue[700],
                    ),
                  ),
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  DateFormat('dd MMM yyyy HH:mm').format(createdAt),
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
                if (isCall && duration != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Duur: ${_formatDuration(duration)}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
            trailing: cost > 0
                ? Text(
                    '€${cost.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  )
                : null,
          );
        },
      ),
    );
  }

  String _formatDuration(int seconds) {
    final minutes = (seconds / 60).floor();
    final remainingSeconds = seconds % 60;
    if (minutes > 0) {
      return '$minutes min ${remainingSeconds}s';
    }
    return '${remainingSeconds}s';
  }
}

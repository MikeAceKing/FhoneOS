import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/subscription_usage.dart';

class UsageStatsWidget extends StatelessWidget {
  final SubscriptionUsage usage;

  const UsageStatsWidget({
    super.key,
    required this.usage,
  });

  Color _getUsageColor(double percentage) {
    if (percentage >= 90) return Colors.red;
    if (percentage >= 75) return Colors.orange;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    final minutesColor = _getUsageColor(usage.minutesUsagePercentage);
    final smsColor = _getUsageColor(usage.smsUsagePercentage);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.analytics_outlined, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Verbruik deze periode',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Tot ${DateFormat('dd MMM yyyy').format(usage.periodEnd)}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            if (usage.isBundleExceeded) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red, width: 1),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning, color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Bundel limiet bereikt. Upgrade voor meer bellen/sms\'en.',
                        style: TextStyle(
                          color: Colors.red[900],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            _buildUsageSection(
              'Belminuten',
              Icons.phone,
              usage.minutesUsed,
              usage.minutesRemaining,
              minutesColor,
              usage.minutesUsagePercentage,
            ),
            const SizedBox(height: 24),
            _buildUsageSection(
              'SMS berichten',
              Icons.message,
              usage.smsUsed,
              usage.smsRemaining,
              smsColor,
              usage.smsUsagePercentage,
            ),
            const SizedBox(height: 16),
            Text(
              'Laatst bijgewerkt: ${DateFormat('dd MMM HH:mm').format(usage.lastUpdated)}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsageSection(
    String title,
    IconData icon,
    int used,
    int remaining,
    Color color,
    double percentage,
  ) {
    final total = used + remaining;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$used / $total gebruikt',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${percentage.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: Colors.grey[200],
            color: color,
            minHeight: 8,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$remaining resterend',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

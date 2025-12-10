import 'package:flutter/material.dart';
import '../../../models/fhoneos_subscription_plan.dart';
import 'package:intl/intl.dart';

class UsageOverviewWidget extends StatelessWidget {
  final SubscriptionUsage usage;
  final VoidCallback onRefresh;

  const UsageOverviewWidget({
    super.key,
    required this.usage,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (usage.periodStart != null && usage.periodEnd != null) ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Current Billing Period',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${DateFormat('MMM dd').format(usage.periodStart!)} - ${DateFormat('MMM dd, yyyy').format(usage.periodEnd!)}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: onRefresh,
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Refresh Usage',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
        _buildUsageCard(
          context,
          'Calling Minutes',
          Icons.phone,
          usage.minutesUsed,
          usage.minutesLimit,
          Colors.blue,
        ),
        const SizedBox(height: 16),
        _buildUsageCard(
          context,
          'SMS Messages',
          Icons.message,
          usage.smsUsed,
          usage.smsLimit,
          Colors.green,
        ),
        const SizedBox(height: 24),
        _buildUsageBreakdown(context),
      ],
    );
  }

  Widget _buildUsageCard(
    BuildContext context,
    String title,
    IconData icon,
    int used,
    int limit,
    Color color,
  ) {
    final percentage = limit > 0 ? (used / limit) * 100 : 0;
    final remaining = (limit - used).clamp(0, limit);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$used / $limit',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$remaining remaining',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                CircularProgressIndicator(
                  value: percentage / 100,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    percentage > 80 ? Colors.red : color,
                  ),
                  strokeWidth: 8,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percentage / 100,
                minHeight: 8,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  percentage > 80 ? Colors.red : color,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${percentage.toStringAsFixed(1)}% used',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                if (percentage > 80)
                  Text(
                    'Low on resources!',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.red[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsageBreakdown(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Usage Breakdown',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildBreakdownRow(
              'Minutes Used',
              usage.minutesUsed.toString(),
              Icons.phone,
              Colors.blue,
            ),
            const Divider(height: 24),
            _buildBreakdownRow(
              'SMS Sent',
              usage.smsUsed.toString(),
              Icons.message,
              Colors.green,
            ),
            const Divider(height: 24),
            _buildBreakdownRow(
              'Total Remaining Minutes',
              usage.minutesRemaining.toString(),
              Icons.access_time,
              Colors.orange,
            ),
            const Divider(height: 24),
            _buildBreakdownRow(
              'Total Remaining SMS',
              usage.smsRemaining.toString(),
              Icons.sms,
              Colors.purple,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBreakdownRow(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

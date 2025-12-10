import 'package:flutter/material.dart';

class CostBreakdownWidget extends StatelessWidget {
  final Map<String, dynamic> statistics;

  const CostBreakdownWidget({
    super.key,
    required this.statistics,
  });

  @override
  Widget build(BuildContext context) {
    final hasSubscription = statistics['has_subscription'] as bool? ?? false;
    if (!hasSubscription) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Text(
              'Geen actief abonnement',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
        ),
      );
    }

    final planName = statistics['plan_name'] as String? ?? 'Onbekend';
    final minutesUsed = statistics['minutes_used'] as int? ?? 0;
    final smsUsed = statistics['sms_used'] as int? ?? 0;
    final minutesPercentage =
        statistics['minutes_percentage'] as double? ?? 0.0;
    final smsPercentage = statistics['sms_percentage'] as double? ?? 0.0;
    final isBundleExceeded = statistics['is_bundle_exceeded'] as bool? ?? false;

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
                const Icon(Icons.analytics, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Verbruiksoverzicht',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withAlpha(26),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.card_membership,
                      color: Colors.blue, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    planName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Minuten',
                    minutesUsed.toString(),
                    '${minutesPercentage.toStringAsFixed(1)}%',
                    Colors.blue,
                    Icons.phone,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'SMS',
                    smsUsed.toString(),
                    '${smsPercentage.toStringAsFixed(1)}%',
                    Colors.green,
                    Icons.message,
                  ),
                ),
              ],
            ),
            if (isBundleExceeded) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withAlpha(26),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red, width: 1),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning, color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Bundel limiet overschreden. Upgrade voor meer gebruik.',
                        style: TextStyle(
                          color: Colors.red[900],
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    String percentage,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withAlpha(13),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(51)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            percentage,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

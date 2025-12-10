import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CurrentSubscriptionWidget extends StatelessWidget {
  final Map<String, dynamic> subscription;
  final VoidCallback onCancelPressed;

  const CurrentSubscriptionWidget({
    super.key,
    required this.subscription,
    required this.onCancelPressed,
  });

  @override
  Widget build(BuildContext context) {
    final plan = subscription['plans'];
    final periodEnd = subscription['current_period_end'] != null
        ? DateTime.parse(subscription['current_period_end'])
        : null;

    final daysRemaining =
        periodEnd != null ? periodEnd.difference(DateTime.now()).inDays : 0;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Current Subscription',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Chip(
                  label: Text(subscription['status'].toString().toUpperCase()),
                  backgroundColor: _getStatusColor(subscription['status']),
                  labelStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              plan['name'],
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              plan['description'],
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            _buildInfoRow(
              Icons.euro,
              'Monthly Price',
              '€${(plan['price_monthly'] as num).toStringAsFixed(2)}',
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.phone,
              'Included Minutes',
              '${plan['minutes_included']} minutes',
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.message,
              'Included SMS',
              '${plan['sms_included']} messages',
            ),
            const SizedBox(height: 12),
            if (periodEnd != null) ...[
              _buildInfoRow(
                Icons.calendar_today,
                'Next Billing Date',
                DateFormat('MMM dd, yyyy').format(periodEnd),
              ),
              const SizedBox(height: 12),
              _buildInfoRow(
                Icons.timer,
                'Days Remaining',
                '$daysRemaining days',
              ),
            ],
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onCancelPressed,
                    icon: const Icon(Icons.cancel),
                    label: const Text('Cancel Subscription'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.blue),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'trialing':
        return Colors.blue;
      case 'past_due':
        return Colors.orange;
      case 'canceled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

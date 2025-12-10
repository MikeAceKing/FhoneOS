import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AutoRenewalWidget extends StatelessWidget {
  final bool enabled;
  final Function(bool) onToggle;
  final Map<String, dynamic> subscription;

  const AutoRenewalWidget({
    super.key,
    required this.enabled,
    required this.onToggle,
    required this.subscription,
  });

  @override
  Widget build(BuildContext context) {
    final endsAt = subscription['ends_at'] != null
        ? DateTime.parse(subscription['ends_at'] as String)
        : null;
    final status = subscription['status'] as String;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
              const Icon(Icons.autorenew, color: Colors.blue, size: 24),
              const SizedBox(width: 12),
              const Text(
                'Auto-Renewal Settings',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: enabled
                  ? Colors.green.withAlpha(13)
                  : Colors.orange.withAlpha(13),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: enabled
                    ? Colors.green.withAlpha(77)
                    : Colors.orange.withAlpha(77),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        enabled
                            ? 'Auto-Renewal Active'
                            : 'Auto-Renewal Disabled',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: enabled ? Colors.green : Colors.orange,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        enabled
                            ? 'Your subscription will automatically renew'
                            : 'Subscription will end on expiry date',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      if (endsAt != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Expires: ${DateFormat('MMM dd, yyyy').format(endsAt)}',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                Switch(
                  value: enabled,
                  onChanged: status == 'active' ? onToggle : null,
                  activeColor: Colors.green,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withAlpha(13),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Important Information',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildInfoItem(
                  '• Cancel at least 30 days before renewal to avoid charges',
                ),
                _buildInfoItem(
                  '• Disabling auto-renewal will not cancel your current subscription',
                ),
                _buildInfoItem(
                  '• You\'ll receive email notification 14 days before renewal',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey[700],
          height: 1.4,
        ),
      ),
    );
  }
}

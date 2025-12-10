import 'package:flutter/material.dart';

class SubscriptionSummaryWidget extends StatelessWidget {
  final double totalSpent;
  final double subscriptionCost;
  final double callCost;
  final double messageCost;

  const SubscriptionSummaryWidget({
    super.key,
    required this.totalSpent,
    required this.subscriptionCost,
    required this.callCost,
    required this.messageCost,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF020617),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Color(0xFF1E293B)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Usage Summary',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Current month breakdown',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white60,
              ),
            ),
            const SizedBox(height: 16),
            _buildSummaryRow(
              'Subscription',
              subscriptionCost,
              Icons.card_membership,
              const Color(0xFF6366F1),
            ),
            const SizedBox(height: 12),
            _buildSummaryRow(
              'Calls',
              callCost,
              Icons.phone,
              const Color(0xFF22C55E),
            ),
            const SizedBox(height: 12),
            _buildSummaryRow(
              'Messages',
              messageCost,
              Icons.sms,
              const Color(0xFF8B5CF6),
            ),
            const SizedBox(height: 16),
            const Divider(color: Color(0xFF1E293B)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Spent',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '€${totalSpent.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6366F1),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
      String label, double amount, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withAlpha(26),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 18,
            color: color,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.white70,
            ),
          ),
        ),
        Text(
          '€${amount.toStringAsFixed(2)}',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

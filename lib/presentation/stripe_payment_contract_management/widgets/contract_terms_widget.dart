import 'package:flutter/material.dart';
import '../../../models/subscription_plan.dart';

class ContractTermsWidget extends StatelessWidget {
  final SubscriptionPlan? plan;
  final String paymentType;

  const ContractTermsWidget({
    super.key,
    required this.plan,
    required this.paymentType,
  });

  @override
  Widget build(BuildContext context) {
    if (plan == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.orange.withAlpha(77),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withAlpha(26),
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
              const Icon(Icons.gavel, color: Colors.orange, size: 24),
              const SizedBox(width: 12),
              const Text(
                'Contract Terms (Benelux Compliant)',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTermItem(
            icon: Icons.calendar_today,
            title: '12-Month Commitment',
            description: paymentType == 'yearly_full'
                ? 'Annual subscription paid upfront for full year'
                : 'Monthly billing with 12-month commitment period',
            color: Colors.blue,
          ),
          const Divider(height: 24),
          _buildTermItem(
            icon: Icons.autorenew,
            title: 'Auto-Renewal',
            description:
                'Subscription automatically renews unless canceled 30 days before expiry',
            color: Colors.green,
          ),
          const Divider(height: 24),
          _buildTermItem(
            icon: Icons.cancel_outlined,
            title: '14-Day Right of Withdrawal',
            description:
                'EU law allows cancellation within 14 days of purchase with full refund',
            color: Colors.purple,
          ),
          const Divider(height: 24),
          _buildTermItem(
            icon: Icons.lock,
            title: 'Binding Period',
            description:
                'After 14 days, commitment is binding for 12 months. Early cancellation not permitted.',
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withAlpha(26),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.warning_amber_rounded,
                    color: Colors.orange, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Emergency calls (112) are NOT supported. This is a VoIP service.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[800],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermItem({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withAlpha(26),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

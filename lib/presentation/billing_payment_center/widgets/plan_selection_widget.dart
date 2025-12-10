import 'package:flutter/material.dart';
import '../../../models/fhoneos_subscription_plan.dart';

class PlanSelectionWidget extends StatelessWidget {
  final List<FhoneOSSubscriptionPlan> plans;
  final String? currentPlanId;
  final Function(String) onPlanSelected;

  const PlanSelectionWidget({
    super.key,
    required this.plans,
    this.currentPlanId,
    required this.onPlanSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: plans.map((plan) => _buildPlanCard(context, plan)).toList(),
    );
  }

  Widget _buildPlanCard(BuildContext context, FhoneOSSubscriptionPlan plan) {
    final isCurrentPlan = plan.id == currentPlanId;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: isCurrentPlan ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isCurrentPlan
              ? Theme.of(context).primaryColor
              : Colors.transparent,
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            plan.name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (isCurrentPlan) ...[
                            const SizedBox(width: 8),
                            Chip(
                              label: const Text('Current Plan'),
                              backgroundColor:
                                  Theme.of(context).primaryColor.withAlpha(51),
                              labelStyle: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        plan.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  '€${plan.priceMonthly.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  ' / month',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            _buildFeatureItem(
              Icons.phone,
              '${plan.minutesIncluded} calling minutes',
            ),
            const SizedBox(height: 8),
            _buildFeatureItem(
              Icons.message,
              '${plan.smsIncluded} SMS messages',
            ),
            const SizedBox(height: 8),
            _buildFeatureItem(
              Icons.smartphone,
              '1 phone number included',
            ),
            const SizedBox(height: 8),
            _buildFeatureItem(
              Icons.attach_money,
              'Profit margin: €${plan.profitMarginEur.toStringAsFixed(2)}',
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isCurrentPlan ? null : () => onPlanSelected(plan.id),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  isCurrentPlan ? 'Current Plan' : 'Select Plan',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.green),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import '../../../models/fhoneos_plan.dart';

class PlanCardWidget extends StatelessWidget {
  final FhoneOSPlan plan;
  final bool isCurrentPlan;
  final VoidCallback onSelect;

  const PlanCardWidget({
    super.key,
    required this.plan,
    required this.isCurrentPlan,
    required this.onSelect,
  });

  Color _getPlanColor() {
    if (plan.code.contains('basic')) return Colors.blue;
    if (plan.code.contains('plus')) return Colors.purple;
    if (plan.code.contains('pro')) return Colors.orange;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    final planColor = _getPlanColor();

    return Card(
      elevation: isCurrentPlan ? 8 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isCurrentPlan
            ? BorderSide(color: planColor, width: 2)
            : BorderSide.none,
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: planColor.withAlpha(26),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    plan.name.replaceAll('FhoneOS ', ''),
                    style: TextStyle(
                      color: planColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                const Spacer(),
                if (isCurrentPlan)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Huidig',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              plan.formattedPrice,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              plan.description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 20),
            _buildFeatureRow(
              Icons.phone,
              '${plan.minutesIncluded} belminuten',
              planColor,
            ),
            const SizedBox(height: 12),
            _buildFeatureRow(
              Icons.message,
              '${plan.smsIncluded} sms berichten',
              planColor,
            ),
            const SizedBox(height: 12),
            _buildFeatureRow(
              Icons.phone_android,
              '${plan.phoneNumbersIncluded} telefoonnummer',
              planColor,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isCurrentPlan ? null : onSelect,
                style: ElevatedButton.styleFrom(
                  backgroundColor: planColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  disabledBackgroundColor: Colors.grey[300],
                ),
                child: Text(
                  isCurrentPlan ? 'Huidige abonnement' : 'Selecteer',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 12),
        Text(
          text,
          style: const TextStyle(fontSize: 15),
        ),
      ],
    );
  }
}

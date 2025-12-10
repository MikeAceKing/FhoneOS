import 'package:flutter/material.dart';

/// Individual plan tier card displaying plan details and features
class PlanTierCardWidget extends StatelessWidget {
  final Map<String, dynamic> plan;
  final bool isSelected;
  final VoidCallback onSelect;

  const PlanTierCardWidget({
    super.key,
    required this.plan,
    required this.isSelected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final monthlyPrice = (plan['price_monthly'] ?? 0.0).toDouble();
    final yearlyPrice = (plan['price_yearly'] ?? 0.0).toDouble();
    final minutesIncluded = plan['minutes_included'] ?? 0;
    final smsIncluded = plan['sms_included'] ?? 0;
    final aiLevel = plan['ai_level'] ?? 'none';
    final numbersIncluded = plan['numbers_included'] ?? 0;

    return InkWell(
      onTap: onSelect,
      borderRadius: BorderRadius.circular(16.0),
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? theme.colorScheme.primaryContainer
                  : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : Colors.transparent,
            width: 2.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  plan['name'] ?? '',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isSelected ? theme.colorScheme.primary : null,
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: theme.colorScheme.primary,
                    size: 32.0,
                  ),
              ],
            ),

            const SizedBox(height: 8.0),

            // Price
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '€${monthlyPrice.toStringAsFixed(0)}',
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 4.0),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    '/month',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 4.0),

            // Yearly price
            Text(
              '€${yearlyPrice.toStringAsFixed(0)}/year commitment',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),

            const SizedBox(height: 16.0),

            // Features
            _buildFeature(
              Icons.phone,
              '$numbersIncluded phone number${numbersIncluded > 1 ? 's' : ''}',
              theme,
            ),
            _buildFeature(Icons.call, '$minutesIncluded minutes', theme),
            _buildFeature(Icons.sms, '$smsIncluded SMS', theme),
            _buildFeature(
              Icons.smart_toy,
              aiLevel == 'none'
                  ? 'No AI'
                  : aiLevel == 'ai_lite'
                  ? 'AI Lite'
                  : aiLevel == 'ai_full'
                  ? 'Full AI'
                  : 'Premium AI',
              theme,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeature(IconData icon, String text, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 18.0, color: theme.colorScheme.primary),
          const SizedBox(width: 8.0),
          Text(text, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}

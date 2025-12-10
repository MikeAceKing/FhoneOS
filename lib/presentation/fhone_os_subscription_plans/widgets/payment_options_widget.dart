import 'package:flutter/material.dart';

/// Payment options selector (yearly full vs monthly terms)
class PaymentOptionsWidget extends StatelessWidget {
  final String selectedType;
  final Function(String) onTypeChange;

  const PaymentOptionsWidget({
    super.key,
    required this.selectedType,
    required this.onTypeChange,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Payment Options',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16.0),

        // Yearly full payment
        _buildPaymentOption(
          context,
          'yearly_full',
          'Pay Annually in Full',
          'Save with one-time payment',
          Icons.payment,
          theme,
        ),

        const SizedBox(height: 12.0),

        // Monthly terms
        _buildPaymentOption(
          context,
          'monthly_term',
          'Monthly Payments',
          '12-month commitment, billed monthly',
          Icons.calendar_month,
          theme,
        ),
      ],
    );
  }

  Widget _buildPaymentOption(
    BuildContext context,
    String type,
    String title,
    String description,
    IconData icon,
    ThemeData theme,
  ) {
    final isSelected = selectedType == type;

    return InkWell(
      onTap: () => onTypeChange(type),
      borderRadius: BorderRadius.circular(12.0),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? theme.colorScheme.primaryContainer
                  : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : Colors.transparent,
            width: 2.0,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color:
                  isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withValues(alpha: 0.7),
              size: 32.0,
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected ? theme.colorScheme.primary : null,
                    ),
                  ),
                  Text(
                    description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: theme.colorScheme.primary,
                size: 24.0,
              ),
          ],
        ),
      ),
    );
  }
}

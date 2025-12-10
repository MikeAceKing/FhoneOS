import 'package:flutter/material.dart';

class PaymentMethodSelectionWidget extends StatelessWidget {
  final String selectedPaymentType;
  final Function(String) onPaymentTypeChanged;

  const PaymentMethodSelectionWidget({
    super.key,
    required this.selectedPaymentType,
    required this.onPaymentTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
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
              const Icon(Icons.payment, color: Colors.blue, size: 24),
              const SizedBox(width: 12),
              const Text(
                'Payment Options',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildPaymentOption(
            type: 'monthly_term',
            title: '12 Monthly Payments',
            description: 'Pay monthly, commit to 12 months',
            icon: Icons.calendar_month,
            recommended: true,
          ),
          const SizedBox(height: 12),
          _buildPaymentOption(
            type: 'yearly_full',
            title: 'Pay Yearly in Full',
            description: 'One-time payment, save on processing fees',
            icon: Icons.attach_money,
            recommended: false,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withAlpha(13),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.blue.withAlpha(51),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.security, color: Colors.blue[700], size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Secure payment powered by Stripe. PCI-DSS compliant.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
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

  Widget _buildPaymentOption({
    required String type,
    required String title,
    required String description,
    required IconData icon,
    required bool recommended,
  }) {
    final isSelected = selectedPaymentType == type;

    return InkWell(
      onTap: () => onPaymentTypeChanged(type),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.withAlpha(26) : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue : Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey[600],
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.blue : Colors.black87,
                        ),
                      ),
                      if (recommended) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'POPULAR',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Radio<String>(
              value: type,
              groupValue: selectedPaymentType,
              onChanged: (value) {
                if (value != null) onPaymentTypeChanged(value);
              },
              activeColor: Colors.blue,
            ),
          ],
        ),
      ),
    );
  }
}

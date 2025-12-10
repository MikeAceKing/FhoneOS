import 'package:flutter/material.dart';

class QuickTopUpWidget extends StatelessWidget {
  final Function(double) onAmountSelected;

  const QuickTopUpWidget({
    super.key,
    required this.onAmountSelected,
  });

  static const List<double> _presetAmounts = [5.0, 10.0, 20.0, 50.0];

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
              'Quick Top-Up',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Add funds instantly',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white60,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 4,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.2,
              children: _presetAmounts.map((amount) {
                return _buildAmountButton(amount);
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountButton(double amount) {
    return InkWell(
      onTap: () => onAmountSelected(amount),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF1E293B),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.add_circle_outline,
              size: 20,
              color: Color(0xFF6366F1),
            ),
            const SizedBox(height: 6),
            Text(
              '€${amount.toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

/// Progress indicator showing signup steps
class SignupProgressIndicatorWidget extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const SignupProgressIndicatorWidget({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      child: Column(
        children: [
          Row(
            children: List.generate(totalSteps, (index) {
              final isActive = index == currentStep;
              final isCompleted = index < currentStep;

              return Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 4.0,
                        decoration: BoxDecoration(
                          color:
                              isCompleted || isActive
                                  ? const Color(0xFF00D9FF)
                                  : Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(2.0),
                        ),
                      ),
                    ),
                    if (index < totalSteps - 1) const SizedBox(width: 8.0),
                  ],
                ),
              );
            }),
          ),
          const SizedBox(height: 12.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStepLabel('Account', 0),
              _buildStepLabel('Phone', 1),
              _buildStepLabel('Add-ons', 2),
              _buildStepLabel('Billing', 3),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepLabel(String label, int stepIndex) {
    final isActive = stepIndex == currentStep;
    final isCompleted = stepIndex < currentStep;

    return Text(
      label,
      style: TextStyle(
        color:
            isCompleted || isActive
                ? const Color(0xFF00D9FF)
                : Colors.white.withValues(alpha: 0.5),
        fontSize: 12.0,
        fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
      ),
    );
  }
}

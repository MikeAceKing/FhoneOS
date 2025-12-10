import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';


class BiometricPromptWidget extends StatelessWidget {
  final VoidCallback onBiometricPressed;

  const BiometricPromptWidget({
    super.key,
    required this.onBiometricPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withAlpha(26),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withAlpha(77),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.fingerprint,
            size: 48.w,
            color: Theme.of(context).colorScheme.primary,
          ),
          SizedBox(height: 12.h),
          Text(
            'Quick Sign In',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Use biometric authentication for faster access',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          SizedBox(height: 16.h),
          OutlinedButton.icon(
            onPressed: onBiometricPressed,
            icon: const Icon(Icons.fingerprint),
            label: const Text('Use Biometric'),
            style: OutlinedButton.styleFrom(
              minimumSize: Size(double.infinity, 48.h),
              side: BorderSide(color: Theme.of(context).colorScheme.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

class BiometricSetupWidget extends StatefulWidget {
  final Function(bool) onComplete;

  const BiometricSetupWidget({
    super.key,
    required this.onComplete,
  });

  @override
  State<BiometricSetupWidget> createState() => _BiometricSetupWidgetState();
}

class _BiometricSetupWidgetState extends State<BiometricSetupWidget> {
  bool _biometricAvailable = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.fingerprint,
            size: 80,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(height: 24),
          Text(
            'Enable Biometric Authentication',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Use your fingerprint or face ID to securely access your account',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          if (_biometricAvailable)
            ElevatedButton(
              onPressed: () => widget.onComplete(true),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
              ),
              child: const Text('Enable Biometric'),
            )
          else
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade300),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange.shade700),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                        'Biometric authentication not available on this device'),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => widget.onComplete(false),
            child: const Text('Skip for now'),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

class TermsAcceptanceWidget extends StatefulWidget {
  final Function(bool) onAccept;
  final VoidCallback onComplete;

  const TermsAcceptanceWidget({
    super.key,
    required this.onAccept,
    required this.onComplete,
  });

  @override
  State<TermsAcceptanceWidget> createState() => _TermsAcceptanceWidgetState();
}

class _TermsAcceptanceWidgetState extends State<TermsAcceptanceWidget> {
  bool _termsAccepted = false;
  bool _privacyAccepted = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Terms & Privacy',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Terms of Service',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                const Text(
                  'By using FhoneOS, you agree to our terms of service. This includes proper usage of phone numbers, messaging, and calling features.',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          CheckboxListTile(
            value: _termsAccepted,
            onChanged: (value) {
              setState(() => _termsAccepted = value ?? false);
              widget.onAccept(_termsAccepted && _privacyAccepted);
            },
            title: const Text('I accept the Terms of Service'),
            controlAffinity: ListTileControlAffinity.leading,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Privacy Policy',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                const Text(
                  'We respect your privacy. Your data is encrypted and stored securely. We do not share your information with third parties.',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          CheckboxListTile(
            value: _privacyAccepted,
            onChanged: (value) {
              setState(() => _privacyAccepted = value ?? false);
              widget.onAccept(_termsAccepted && _privacyAccepted);
            },
            title: const Text('I accept the Privacy Policy'),
            controlAffinity: ListTileControlAffinity.leading,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (_termsAccepted && _privacyAccepted)
                  ? widget.onComplete
                  : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
              child: const Text('Complete Registration'),
            ),
          ),
        ],
      ),
    );
  }
}

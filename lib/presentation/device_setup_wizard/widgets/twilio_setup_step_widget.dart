import 'package:flutter/material.dart';

class TwilioSetupStepWidget extends StatefulWidget {
  final VoidCallback onContinue;
  final VoidCallback onBack;
  final VoidCallback onSkip;

  const TwilioSetupStepWidget({
    super.key,
    required this.onContinue,
    required this.onBack,
    required this.onSkip,
  });

  @override
  State<TwilioSetupStepWidget> createState() => _TwilioSetupStepWidgetState();
}

class _TwilioSetupStepWidgetState extends State<TwilioSetupStepWidget> {
  bool _isConnecting = false;
  bool _isConnected = false;

  void _connectTwilio() {
    setState(() => _isConnecting = true);
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isConnecting = false;
        _isConnected = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Icon(
            _isConnected ? Icons.check_circle : Icons.phone_in_talk,
            size: 80,
            color: _isConnected
                ? Colors.green
                : Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 24),
          Text(
            _isConnected ? 'Twilio Connected!' : 'Twilio Integration',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            _isConnected
                ? 'Your phone number is ready to use'
                : 'Connect your Twilio account for telephony services',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          if (!_isConnected)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[700], size: 32),
                  const SizedBox(height: 12),
                  Text(
                    'Twilio enables calling and SMS features',
                    style: TextStyle(
                      color: Colors.blue[900],
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildInfoRow('Phone Number', '+1 (555) 123-4567'),
                  const Divider(height: 24),
                  _buildInfoRow('Status', 'Active'),
                  const Divider(height: 24),
                  _buildInfoRow('Carrier', 'Twilio'),
                ],
              ),
            ),
          const Spacer(),
          if (!_isConnected)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isConnecting ? null : _connectTwilio,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isConnecting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Connect Twilio'),
              ),
            ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: widget.onBack,
                child: const Text('Back'),
              ),
              Row(
                children: [
                  if (!_isConnected)
                    TextButton(
                      onPressed: widget.onSkip,
                      child: const Text('Skip'),
                    ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _isConnected ? widget.onContinue : null,
                    child: const Text('Continue'),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[700],
                fontWeight: FontWeight.w600,
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }
}

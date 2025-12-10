import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';


class PrivacyConsentWidget extends StatefulWidget {
  const PrivacyConsentWidget({super.key});

  @override
  State<PrivacyConsentWidget> createState() => _PrivacyConsentWidgetState();
}

class _PrivacyConsentWidgetState extends State<PrivacyConsentWidget> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.privacy_tip_outlined,
                size: 20.w,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Privacy & Data Usage',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              IconButton(
                icon: Icon(
                  _expanded ? Icons.expand_less : Icons.expand_more,
                  size: 24.w,
                ),
                onPressed: () => setState(() => _expanded = !_expanded),
              ),
            ],
          ),
          if (_expanded) ...[
            const Divider(),
            SizedBox(height: 8.h),
            Text(
              'FhoneOS Authentication Policy',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            SizedBox(height: 8.h),
            _buildPrivacyPoint(
              'Authentication data is securely stored using industry-standard encryption',
            ),
            _buildPrivacyPoint(
              'OAuth providers share only basic profile information (name, email)',
            ),
            _buildPrivacyPoint(
              'Your credentials are never stored on our servers',
            ),
            _buildPrivacyPoint(
              'Session tokens are automatically refreshed and rotated',
            ),
            _buildPrivacyPoint(
              'All data transmission uses TLS 1.3 encryption',
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // Open Terms of Service
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Terms of Service',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // Open Privacy Policy
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Privacy Policy',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (!_expanded)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'By signing in, you agree to our Terms of Service and Privacy Policy. Tap to learn more about how we protect your data.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                      fontSize: 11,
                    ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPrivacyPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 16.w,
            color: Colors.green[600],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

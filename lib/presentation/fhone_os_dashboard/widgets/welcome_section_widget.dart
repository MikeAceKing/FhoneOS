import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

/// Welcome Section Widget
/// Displays welcome message and quick action buttons
class WelcomeSectionWidget extends StatelessWidget {
  final String userName;

  const WelcomeSectionWidget({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: const Color(0xFF020617),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Color(0xFF1E293B)),
      ),
      child: Padding(
        padding: EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'WELKOM TERUG',
              style: TextStyle(
                fontSize: 11.sp,
                letterSpacing: 1.3,
                color: Colors.white60,
              ),
            ),
            SizedBox(height: 0.5.h),
            Text(
              'Jouw virtuele Android-device is klaar 🚀',
              style: TextStyle(
                fontSize: 17.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'Session: Secure · EU Region · Last login: zojuist',
              style: TextStyle(fontSize: 11.sp, color: Colors.white54),
            ),
            SizedBox(height: 2.h),

            // Quick Actions
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _QuickActionButton(
                  icon: Icons.phone_outlined,
                  label: 'Start call',
                  subtitle: 'Open Phone app',
                  onTap:
                      () => Navigator.pushNamed(context, '/dialer-interface'),
                ),
                _QuickActionButton(
                  icon: Icons.sms_outlined,
                  label: 'New message',
                  subtitle: 'SMS / chat',
                  onTap:
                      () =>
                          Navigator.pushNamed(context, '/messaging-interface'),
                ),
                _QuickActionButton(
                  icon: Icons.upload_file_outlined,
                  label: 'Upload file',
                  subtitle: 'Naar storage',
                  onTap:
                      () => Navigator.pushNamed(context, '/camera-interface'),
                ),
                _QuickActionButton(
                  icon: Icons.storefront_outlined,
                  label: 'Open Store',
                  subtitle: 'Nieuwe apps',
                  onTap: () {}, // Placeholder
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final width = (MediaQuery.of(context).size.width - 100) / 2;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        width: width,
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFF020617),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF1E293B)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: Colors.white),
            SizedBox(height: 0.6.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 0.2.h),
            Text(
              subtitle,
              style: TextStyle(fontSize: 11.sp, color: Colors.white54),
            ),
          ],
        ),
      ),
    );
  }
}

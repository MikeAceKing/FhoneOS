import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

/// Demo Credentials Widget
/// Displays available demo user credentials for testing
class DemoCredentialsWidget extends StatelessWidget {
  const DemoCredentialsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: const Color(0xFF0F172A).withValues(alpha: 0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFF1E293B)),
      ),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: const Color(0xFF22C55E), // emerald-500
                ),
                SizedBox(width: 1.w),
                Text(
                  'Demo Credentials',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF22C55E),
                  ),
                ),
              ],
            ),
            SizedBox(height: 1.h),
            _buildCredentialRow('Admin', 'admin@fhoneos.com', 'admin123'),
            SizedBox(height: 0.5.h),
            _buildCredentialRow('User', 'michael@fhoneos.com', 'user123'),
          ],
        ),
      ),
    );
  }

  Widget _buildCredentialRow(String role, String email, String password) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.3.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$role:',
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
              color: Colors.white70,
            ),
          ),
          SizedBox(height: 0.3.h),
          Text(
            'Email: $email',
            style: TextStyle(
              fontSize: 10.sp,
              color: Colors.white54,
              fontFamily: 'monospace',
            ),
          ),
          Text(
            'Pass: $password',
            style: TextStyle(
              fontSize: 10.sp,
              color: Colors.white54,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}

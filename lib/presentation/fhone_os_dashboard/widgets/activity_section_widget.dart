import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

/// Activity Section Widget
/// Displays recent user activities
class ActivitySectionWidget extends StatelessWidget {
  const ActivitySectionWidget({super.key});

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
              'Laatste acties',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 1.h),
            _ActivityRow(
              icon: Icons.cloud_outlined,
              title: 'CloudOS sessie gestart',
              subtitle: 'Nieuwe login vanaf web client',
            ),
            _ActivityRow(
              icon: Icons.phone_in_talk_outlined,
              title: 'Testcall via Phone app',
              subtitle: 'WebRTC (later) · 02:13 min',
            ),
            _ActivityRow(
              icon: Icons.upload_file_outlined,
              title: '3 bestanden geüpload',
              subtitle: 'Naar virtual storage',
            ),
            SizedBox(height: 1.h),
            TextButton(
              onPressed: () {
                // TODO: Open full activity log
              },
              child: Text(
                'Bekijk volledige log >',
                style: TextStyle(
                  fontSize: 11.sp,
                  color: const Color(0xFF6366F1),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _ActivityRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.4.h),
      child: Row(
        children: [
          Container(
            height: 26,
            width: 26,
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Icon(icon, size: 16, color: Colors.white),
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 11.sp, color: Colors.white54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

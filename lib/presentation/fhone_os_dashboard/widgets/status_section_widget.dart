import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

/// Status Section Widget
/// Displays system status indicators
class StatusSectionWidget extends StatelessWidget {
  const StatusSectionWidget({super.key});

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'STATUS',
                  style: TextStyle(
                    fontSize: 11.sp,
                    letterSpacing: 1.3,
                    color: Colors.white60,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF22C55E).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.circle,
                        size: 8,
                        color: Color(0xFF22C55E),
                      ),
                      SizedBox(width: 0.5.w),
                      Text(
                        'Live',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: const Color(0xFF4ADE80),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 1.5.h),
            _StatusRow(label: 'Backend', value: 'Supabase · OK'),
            _StatusRow(label: 'Realtime', value: 'WebSocket / Socket.io · OK'),
            _StatusRow(label: 'Calls', value: 'Twilio sandbox'),
            SizedBox(height: 1.h),
            Text(
              'Environment',
              style: TextStyle(fontSize: 12.sp, color: Colors.white60),
            ),
            SizedBox(height: 0.2.h),
            Text(
              'Flutter · Dart · WebRTC (later) · Supabase',
              style: TextStyle(fontSize: 11.sp, color: Colors.white54),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  final String label;
  final String value;

  const _StatusRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.3.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13.sp, color: Colors.white70)),
          Text(
            value,
            style: TextStyle(fontSize: 12.sp, color: const Color(0xFF4ADE80)),
          ),
        ],
      ),
    );
  }
}

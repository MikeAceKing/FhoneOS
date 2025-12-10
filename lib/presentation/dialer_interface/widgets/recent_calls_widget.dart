import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// Recent Calls Widget
/// Displays chronological history of recent calls
class RecentCallsWidget extends StatelessWidget {
  const RecentCallsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Mock recent calls data
    final List<Map<String, dynamic>> recentCalls = [
      {
        'name': 'John Smith',
        'number': '+1 (555) 123-4567',
        'type': 'incoming',
        'duration': '5:42',
        'time': '2 hours ago',
      },
      {
        'name': 'Sarah Wilson',
        'number': '+1 (555) 987-6543',
        'type': 'outgoing',
        'duration': '12:05',
        'time': '5 hours ago',
      },
      {
        'name': 'Mike Johnson',
        'number': '+1 (555) 456-7890',
        'type': 'missed',
        'duration': '0:00',
        'time': 'Yesterday',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(16.w),
          child: Text(
            'Recent',
            style: GoogleFonts.inter(
              fontSize: 16.h,
              fontWeight: FontWeight.w600,
              color: theme.textTheme.bodyLarge?.color,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: recentCalls.length,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemBuilder: (context, index) {
              final call = recentCalls[index];
              return _buildCallItem(context, call);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCallItem(BuildContext context, Map<String, dynamic> call) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    IconData callTypeIcon;
    Color callTypeColor;

    switch (call['type']) {
      case 'incoming':
        callTypeIcon = Icons.call_received;
        callTypeColor = const Color(0xFF00D4AA);
        break;
      case 'outgoing':
        callTypeIcon = Icons.call_made;
        callTypeColor = const Color(0xFF4A9EFF);
        break;
      case 'missed':
        callTypeIcon = Icons.call_missed;
        callTypeColor = const Color(0xFFFF4757);
        break;
      default:
        callTypeIcon = Icons.call;
        callTypeColor = Colors.grey;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF2D2D3A).withValues(alpha: 0.5)
            : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Call type icon
          Container(
            width: 40.w,
            height: 40.h,
            decoration: BoxDecoration(
              color: callTypeColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              callTypeIcon,
              color: callTypeColor,
              size: 20.h,
            ),
          ),
          SizedBox(width: 12.w),

          // Call details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  call['name'],
                  style: GoogleFonts.inter(
                    fontSize: 14.h,
                    fontWeight: FontWeight.w500,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  call['number'],
                  style: GoogleFonts.inter(
                    fontSize: 12.h,
                    color: theme.textTheme.bodySmall?.color,
                  ),
                ),
              ],
            ),
          ),

          // Duration and time
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                call['duration'],
                style: GoogleFonts.inter(
                  fontSize: 12.h,
                  fontWeight: FontWeight.w500,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                call['time'],
                style: GoogleFonts.inter(
                  fontSize: 11.h,
                  color: theme.textTheme.bodySmall?.color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
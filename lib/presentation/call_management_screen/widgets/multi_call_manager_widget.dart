import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// Multi-Call Manager Widget
/// Displays and manages multiple active calls with participant controls
class MultiCallManagerWidget extends StatelessWidget {
  final List<Map<String, dynamic>> activeCalls;
  final Function(int) onSwitchCall;

  const MultiCallManagerWidget({
    super.key,
    required this.activeCalls,
    required this.onSwitchCall,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180.w,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.people,
                color: Colors.white,
                size: 18.h,
              ),
              SizedBox(width: 6.w),
              Text(
                'Active Calls',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 14.h,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          ...List.generate(
            activeCalls.length,
            (index) => _buildCallItem(
              activeCalls[index]['name'] ?? 'Unknown',
              activeCalls[index]['duration'] ?? '00:00',
              index,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCallItem(String name, String duration, int index) {
    return GestureDetector(
      onTap: () => onSwitchCall(index),
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              height: 32.h,
              width: 32.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.2),
              ),
              child: Center(
                child: Text(
                  name[0].toUpperCase(),
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 14.h,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 12.h,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    duration,
                    style: GoogleFonts.inter(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 11.h,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
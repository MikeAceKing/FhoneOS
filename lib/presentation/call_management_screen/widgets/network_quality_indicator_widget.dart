import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// Network Quality Indicator Widget
/// Real-time display of connection quality and signal strength
class NetworkQualityIndicatorWidget extends StatelessWidget {
  final String quality;
  final int strength;

  const NetworkQualityIndicatorWidget({
    super.key,
    required this.quality,
    required this.strength,
  });

  Color _getQualityColor() {
    if (strength >= 80) return Colors.green;
    if (strength >= 50) return Colors.orange;
    return Colors.red;
  }

  IconData _getQualityIcon() {
    if (strength >= 80) return Icons.signal_cellular_alt;
    if (strength >= 50) return Icons.signal_cellular_alt_2_bar;
    if (strength > 0) return Icons.signal_cellular_alt_1_bar;
    return Icons.signal_cellular_connected_no_internet_0_bar;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _getQualityColor().withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getQualityIcon(),
            color: _getQualityColor(),
            size: 16.h,
          ),
          SizedBox(width: 6.w),
          Text(
            quality,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 12.h,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 4.w),
          Text(
            '($strength%)',
            style: GoogleFonts.inter(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 11.h,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
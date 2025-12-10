import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

/// FhoneOS Branding Widget
/// Displays the app icon and branding text
class FhoneOsBrandingWidget extends StatelessWidget {
  const FhoneOsBrandingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          Icons.smartphone,
          size: 64,
          color: const Color(0xFF6366F1), // indigo-500
        ),
        SizedBox(height: 2.h),
        Text(
          'FhoneOS',
          style: TextStyle(
            fontSize: 28.sp,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 0.5.h),
        Text(
          'Virtuele smartphone omgeving',
          style: TextStyle(color: Colors.white70, fontSize: 13.sp),
        ),
      ],
    );
  }
}

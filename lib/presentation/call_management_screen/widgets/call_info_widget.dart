import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// Call Info Widget
/// Displays contact information and call status during active call
class CallInfoWidget extends StatelessWidget {
  final String contactName;
  final String contactNumber;
  final String contactAvatar;
  final String callDuration;
  final bool isOnHold;

  const CallInfoWidget({
    super.key,
    required this.contactName,
    required this.contactNumber,
    required this.contactAvatar,
    required this.callDuration,
    this.isOnHold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Contact avatar
          Container(
            height: 50.h,
            width: 50.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: ClipOval(
              child: CustomImageWidget(
                imageUrl: contactAvatar,
                fit: BoxFit.cover,
                semanticLabel: 'Contact avatar showing profile picture',
              ),
            ),
          ),

          SizedBox(width: 12.w),

          // Contact info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  contactName,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 16.h,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                Text(
                  contactNumber,
                  style: GoogleFonts.inter(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 13.h,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    if (isOnHold) ...[
                      Icon(
                        Icons.pause_circle_filled,
                        color: Colors.orange,
                        size: 14.h,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'On Hold',
                        style: GoogleFonts.inter(
                          color: Colors.orange,
                          fontSize: 12.h,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ] else ...[
                      Icon(
                        Icons.access_time,
                        color: Colors.green,
                        size: 14.h,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        callDuration,
                        style: GoogleFonts.inter(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 13.h,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // TTY indicator (accessibility)
          Icon(
            Icons.hearing,
            color: Colors.white.withValues(alpha: 0.5),
            size: 20.h,
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// Profile header widget displaying user avatar and edit functionality
class ProfileHeaderWidget extends StatelessWidget {
  final String? profileImageUrl;
  final VoidCallback? onEditTap;

  const ProfileHeaderWidget({
    super.key,
    this.profileImageUrl,
    this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(vertical: 3.h),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Profile Avatar
          Container(
            width: 30.w,
            height: 30.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: theme.colorScheme.primary,
                width: 3,
              ),
            ),
            child: ClipOval(
              child: profileImageUrl != null
                  ? CustomImageWidget(
                      imageUrl: profileImageUrl!,
                      width: 30.w,
                      height: 30.w,
                      fit: BoxFit.cover,
                      semanticLabel:
                          "User profile avatar showing current profile picture",
                    )
                  : Container(
                      color: theme.colorScheme.primaryContainer,
                      child: CustomIconWidget(
                        iconName: 'person',
                        size: 15.w,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
            ),
          ),
          // Edit Button
          Positioned(
            bottom: 0,
            right: 28.w,
            child: GestureDetector(
              onTap: onEditTap,
              child: Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: CustomIconWidget(
                  iconName: 'edit',
                  size: 4.w,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

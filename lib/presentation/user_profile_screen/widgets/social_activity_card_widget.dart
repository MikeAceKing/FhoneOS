import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Social activity card widget displaying recent interactions and engagement
class SocialActivityCardWidget extends StatelessWidget {
  final List<Map<String, dynamic>> activities;

  const SocialActivityCardWidget({
    super.key,
    required this.activities,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(3.w),
        border: Border.all(
          color: theme.colorScheme.outline,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: const Color(0xFF4A9EFF).withValues(alpha: 0.1),
              borderRadius: BorderRadius.vertical(top: Radius.circular(3.w)),
            ),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'trending_up',
                  size: 6.w,
                  color: const Color(0xFF4A9EFF),
                ),
                SizedBox(width: 3.w),
                Text(
                  'Recent Activity',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: const Color(0xFF4A9EFF),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.all(4.w),
            itemCount: activities.length > 5 ? 5 : activities.length,
            separatorBuilder: (context, index) => Divider(
              height: 2.h,
              color: theme.colorScheme.outline,
            ),
            itemBuilder: (context, index) {
              final activity = activities[index];
              return _buildActivityItem(context, activity, theme);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(
    BuildContext context,
    Map<String, dynamic> activity,
    ThemeData theme,
  ) {
    return Row(
      children: [
        Container(
          width: 10.w,
          height: 10.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _getActivityColor(activity['type'] as String)
                .withValues(alpha: 0.2),
          ),
          child: Center(
            child: CustomIconWidget(
              iconName: _getActivityIcon(activity['type'] as String),
              size: 5.w,
              color: _getActivityColor(activity['type'] as String),
            ),
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                activity['title'] as String,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 0.5.h),
              Text(
                activity['description'] as String,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        SizedBox(width: 2.w),
        Text(
          _formatTime(activity['timestamp'] as DateTime),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  String _getActivityIcon(String type) {
    switch (type) {
      case 'like':
        return 'favorite';
      case 'comment':
        return 'chat_bubble';
      case 'share':
        return 'share';
      case 'follow':
        return 'person_add';
      default:
        return 'notifications';
    }
  }

  Color _getActivityColor(String type) {
    switch (type) {
      case 'like':
        return Colors.red;
      case 'comment':
        return const Color(0xFF4A9EFF);
      case 'share':
        return const Color(0xFF00D4AA);
      case 'follow':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return '${(difference.inDays / 7).floor()}w';
    }
  }
}

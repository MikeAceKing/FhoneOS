import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

/// User statistics widget displaying followers, following, and posts count
class UserStatsWidget extends StatelessWidget {
  final int followersCount;
  final int followingCount;
  final int postsCount;

  const UserStatsWidget({
    super.key,
    required this.followersCount,
    required this.followingCount,
    required this.postsCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem(
            context: context,
            label: 'Followers',
            count: followersCount,
            theme: theme,
          ),
          Container(
            width: 1,
            height: 6.h,
            color: theme.colorScheme.outline,
          ),
          _buildStatItem(
            context: context,
            label: 'Following',
            count: followingCount,
            theme: theme,
          ),
          Container(
            width: 1,
            height: 6.h,
            color: theme.colorScheme.outline,
          ),
          _buildStatItem(
            context: context,
            label: 'Posts',
            count: postsCount,
            theme: theme,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required BuildContext context,
    required String label,
    required int count,
    required ThemeData theme,
  }) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _formatCount(count),
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 0.5.h),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }
}

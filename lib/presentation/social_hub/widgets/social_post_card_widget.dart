import 'package:flutter/material.dart';

import '../../../core/app_export.dart';

/// Widget for displaying individual social media post card
class SocialPostCardWidget extends StatelessWidget {
  final Map<String, dynamic> post;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onShare;

  const SocialPostCardWidget({
    super.key,
    required this.post,
    required this.onLike,
    required this.onComment,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post header with user info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                ClipOval(
                  child: CustomImageWidget(
                    imageUrl: post["userAvatar"] as String,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    semanticLabel: post["semanticLabel"] as String,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post["userName"] as String,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        post["timestamp"] as String,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: CustomIconWidget(
                    iconName: 'more_vert',
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                  onPressed: () {
                    _showPostOptions(context);
                  },
                ),
              ],
            ),
          ),

          // Post content
          if (post["content"] != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                post["content"] as String,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ),

          // Post image
          if (post["image"] != null) ...[
            const SizedBox(height: 12),
            CustomImageWidget(
              imageUrl: post["image"] as String,
              width: double.infinity,
              height: 250,
              fit: BoxFit.cover,
              semanticLabel: post["imageSemanticLabel"] as String,
            ),
          ],

          // Post stats
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildStatItem(
                  context,
                  CustomIconWidget(
                    iconName: 'favorite_border',
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 18,
                  ),
                  '${post["likes"]}',
                ),
                const SizedBox(width: 24),
                _buildStatItem(
                  context,
                  CustomIconWidget(
                    iconName: 'chat_bubble_outline',
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 18,
                  ),
                  '${post["comments"]}',
                ),
                const SizedBox(width: 24),
                _buildStatItem(
                  context,
                  CustomIconWidget(
                    iconName: 'share',
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 18,
                  ),
                  '${post["shares"]}',
                ),
              ],
            ),
          ),

          // Action buttons
          Divider(
            height: 1,
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActionButton(
                  context,
                  CustomIconWidget(
                    iconName: 'favorite_border',
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                  'Like',
                  onLike,
                ),
                _buildActionButton(
                  context,
                  CustomIconWidget(
                    iconName: 'chat_bubble_outline',
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                  'Comment',
                  onComment,
                ),
                _buildActionButton(
                  context,
                  CustomIconWidget(
                    iconName: 'share',
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                  'Share',
                  onShare,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, Widget icon, String count) {
    final theme = Theme.of(context);
    return Row(
      children: [
        icon,
        const SizedBox(width: 4),
        Text(
          count,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    Widget icon,
    String label,
    VoidCallback onPressed,
  ) {
    final theme = Theme.of(context);
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                icon,
                const SizedBox(width: 8),
                Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showPostOptions(BuildContext context) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: CustomIconWidget(
                  iconName: 'bookmark_border',
                  color: theme.colorScheme.onSurface,
                  size: 24,
                ),
                title: Text(
                  'Save post',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Post saved'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
              ListTile(
                leading: CustomIconWidget(
                  iconName: 'link',
                  color: theme.colorScheme.onSurface,
                  size: 24,
                ),
                title: Text(
                  'Copy link',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Link copied to clipboard'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
              ListTile(
                leading: CustomIconWidget(
                  iconName: 'report',
                  color: theme.colorScheme.error,
                  size: 24,
                ),
                title: Text(
                  'Report post',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Post reported'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

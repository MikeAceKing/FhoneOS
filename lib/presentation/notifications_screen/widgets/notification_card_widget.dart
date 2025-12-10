import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../core/app_export.dart';

/// Individual notification card with swipe-to-delete and long-press context menu
class NotificationCardWidget extends StatelessWidget {
  final Map<String, dynamic> notification;
  final VoidCallback onDelete;
  final VoidCallback onBlockUser;
  final VoidCallback onViewProfile;

  const NotificationCardWidget({
    super.key,
    required this.notification,
    required this.onDelete,
    required this.onBlockUser,
    required this.onViewProfile,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRead = notification["isRead"] as bool;
    final timestamp = notification["timestamp"] as DateTime;
    final timeAgo = _formatTimeAgo(timestamp);

    return Slidable(
      key: ValueKey(notification["id"]),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => onDelete(),
            backgroundColor: theme.colorScheme.error,
            foregroundColor: theme.colorScheme.onError,
            icon: Icons.delete,
            label: 'Delete',
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          // Mark as read and navigate
          onViewProfile();
        },
        onLongPress: () => _showContextMenu(context, theme),
        child: Container(
          color: isRead
              ? Colors.transparent
              : theme.colorScheme.primary.withValues(alpha: 0.05),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              GestureDetector(
                onTap: onViewProfile,
                child: CircleAvatar(
                  radius: 24,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: ClipOval(
                    child: CustomImageWidget(
                      imageUrl: notification["userAvatar"] as String,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      semanticLabel: notification["semanticLabel"] as String,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: theme.textTheme.bodyMedium,
                              children: [
                                TextSpan(
                                  text: notification["userName"] as String,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                TextSpan(
                                  text: ' ${notification["action"]}',
                                  style: TextStyle(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (!isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    if ((notification["preview"] as String).isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        notification["preview"] as String,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      timeAgo,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              // Type icon
              const SizedBox(width: 8),
              _buildTypeIcon(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeIcon(ThemeData theme) {
    final type = notification["type"] as String;
    IconData iconData;
    Color iconColor;

    switch (type) {
      case 'like':
        iconData = Icons.favorite;
        iconColor = Colors.red;
        break;
      case 'comment':
        iconData = Icons.chat_bubble;
        iconColor = theme.colorScheme.primary;
        break;
      case 'follow':
        iconData = Icons.person_add;
        iconColor = Colors.green;
        break;
      case 'mention':
        iconData = Icons.alternate_email;
        iconColor = Colors.orange;
        break;
      case 'share':
        iconData = Icons.share;
        iconColor = Colors.blue;
        break;
      default:
        iconData = Icons.notifications;
        iconColor = theme.colorScheme.onSurfaceVariant;
    }

    return CustomIconWidget(
      iconName: iconData.codePoint.toString(),
      color: iconColor,
      size: 20,
    );
  }

  String _formatTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${(difference.inDays / 7).floor()}w ago';
    }
  }

  void _showContextMenu(BuildContext context, ThemeData theme) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: CustomIconWidget(
                iconName: 'check',
                color: theme.colorScheme.onSurface,
                size: 24,
              ),
              title: const Text('Mark as Read'),
              onTap: () {
                Navigator.pop(context);
                // Handle mark as read
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'block',
                color: theme.colorScheme.error,
                size: 24,
              ),
              title: Text(
                'Block User',
                style: TextStyle(color: theme.colorScheme.error),
              ),
              onTap: () {
                Navigator.pop(context);
                onBlockUser();
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'person',
                color: theme.colorScheme.onSurface,
                size: 24,
              ),
              title: const Text('View Profile'),
              onTap: () {
                Navigator.pop(context);
                onViewProfile();
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'delete',
                color: theme.colorScheme.error,
                size: 24,
              ),
              title: Text(
                'Delete',
                style: TextStyle(color: theme.colorScheme.error),
              ),
              onTap: () {
                Navigator.pop(context);
                onDelete();
              },
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class ConversationListWidget extends StatelessWidget {
  final List<Map<String, dynamic>> conversations;
  final Function(Map<String, dynamic>) onConversationTap;

  const ConversationListWidget({
    super.key,
    required this.conversations,
    required this.onConversationTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView.builder(
      itemCount: conversations.length,
      itemBuilder: (context, index) {
        final conversation = conversations[index];
        return _buildConversationTile(theme, conversation);
      },
    );
  }

  Widget _buildConversationTile(
      ThemeData theme, Map<String, dynamic> conversation) {
    final unreadCount = conversation['unread_count'] ?? 0;
    final isPinned = conversation['is_pinned'] ?? false;
    final isMuted = conversation['is_muted'] ?? false;

    return ListTile(
      leading: Stack(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFF25D366),
            radius: 28,
            child: const Icon(
              Icons.person,
              color: Colors.white,
              size: 28,
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: const Color(0xFF25D366),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
        ],
      ),
      title: Row(
        children: [
          if (isPinned)
            Icon(
              Icons.push_pin,
              size: 14,
              color: theme.colorScheme.primary,
            ),
          if (isPinned) SizedBox(width: 1.w),
          Expanded(
            child: Text(
              conversation['conversation_name'] ?? 'Unknown Contact',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: unreadCount > 0 ? FontWeight.w600 : FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (isMuted)
            Icon(
              Icons.volume_off,
              size: 16,
              color: theme.colorScheme.onSurfaceVariant,
            ),
        ],
      ),
      subtitle: Row(
        children: [
          if (conversation['platform'] == 'whatsapp')
            Icon(
              Icons.help_outline,
              size: 14,
              color: const Color(0xFF25D366),
            ),
          if (conversation['platform'] == 'whatsapp') SizedBox(width: 1.w),
          Expanded(
            child: Text(
              conversation['last_message_text'] ?? 'No messages yet',
              style: theme.textTheme.bodySmall?.copyWith(
                color: unreadCount > 0
                    ? theme.colorScheme.onSurface
                    : theme.colorScheme.onSurfaceVariant,
                fontWeight: unreadCount > 0 ? FontWeight.w500 : FontWeight.w400,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            _formatTime(conversation['last_message_at']),
            style: theme.textTheme.bodySmall?.copyWith(
              color: unreadCount > 0
                  ? const Color(0xFF25D366)
                  : theme.colorScheme.onSurfaceVariant,
              fontSize: 10.sp,
            ),
          ),
          if (unreadCount > 0) ...[
            SizedBox(height: 0.5.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 1.5.w, vertical: 0.3.h),
              decoration: const BoxDecoration(
                color: Color(0xFF25D366),
                shape: BoxShape.circle,
              ),
              constraints: BoxConstraints(
                minWidth: 5.w,
                minHeight: 2.h,
              ),
              child: Center(
                child: Text(
                  unreadCount > 99 ? '99+' : unreadCount.toString(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 10.sp,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
      onTap: () => onConversationTap(conversation),
      onLongPress: () {
        // Show conversation options
      },
    );
  }

  String _formatTime(String? timestamp) {
    if (timestamp == null) return '';
    try {
      final dateTime = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays == 0) {
        return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return _getDayName(dateTime.weekday);
      } else {
        return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
      }
    } catch (e) {
      return '';
    }
  }

  String _getDayName(int weekday) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    return days[weekday - 1];
  }
}

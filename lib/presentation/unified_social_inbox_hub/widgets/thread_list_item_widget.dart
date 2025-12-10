import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../models/message_thread.dart';

class ThreadListItemWidget extends StatelessWidget {
  final MessageThread thread;
  final VoidCallback onTap;

  const ThreadListItemWidget({
    super.key,
    required this.thread,
    required this.onTap,
  });

  IconData _getPlatformIcon() {
    switch (thread.platform) {
      case 'whatsapp':
        return Icons.chat_bubble;
      case 'telegram':
        return Icons.telegram;
      case 'facebook':
        return Icons.facebook;
      case 'instagram':
        return Icons.camera_alt;
      case 'twitter':
        return Icons.alternate_email;
      case 'email':
        return Icons.email;
      case 'sms':
        return Icons.sms;
      default:
        return Icons.message;
    }
  }

  Color _getPlatformColor() {
    switch (thread.platform) {
      case 'whatsapp':
        return const Color(0xFF25D366);
      case 'telegram':
        return const Color(0xFF0088CC);
      case 'facebook':
        return const Color(0xFF1877F2);
      case 'instagram':
        return const Color(0xFFE4405F);
      case 'twitter':
        return const Color(0xFF1DA1F2);
      case 'email':
        return const Color(0xFFEA4335);
      case 'sms':
        return const Color(0xFF01C38D);
      default:
        return const Color(0xFF4D9FFF);
    }
  }

  @override
  Widget build(BuildContext context) {
    final platformColor = _getPlatformColor();

    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Platform icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: platformColor.withAlpha(26),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                _getPlatformIcon(),
                color: platformColor,
                size: 24,
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
                        child: Text(
                          thread.participantName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: thread.unreadCount > 0
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: const Color(0xFF2D3142),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (thread.lastMessageAt != null)
                        Text(
                          timeago.format(thread.lastMessageAt!),
                          style: TextStyle(
                            fontSize: 12,
                            color: thread.unreadCount > 0
                                ? platformColor
                                : Colors.grey.shade600,
                            fontWeight: thread.unreadCount > 0
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          thread.lastMessagePreview ?? 'No messages yet',
                          style: TextStyle(
                            fontSize: 14,
                            color: thread.unreadCount > 0
                                ? const Color(0xFF2D3142)
                                : Colors.grey.shade600,
                            fontWeight: thread.unreadCount > 0
                                ? FontWeight.w500
                                : FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (thread.unreadCount > 0)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: platformColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${thread.unreadCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
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

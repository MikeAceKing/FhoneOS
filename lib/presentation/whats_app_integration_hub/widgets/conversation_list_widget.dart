import 'package:flutter/material.dart';
import '../../../models/conversation.dart';

class ConversationListWidget extends StatelessWidget {
  final List<Conversation> conversations;
  final Function(Conversation) onConversationTap;
  final Function(String) onArchive;
  final Function(String) onPin;

  const ConversationListWidget({
    Key? key,
    required this.conversations,
    required this.onConversationTap,
    required this.onArchive,
    required this.onPin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: conversations.length,
      itemBuilder: (context, index) {
        final conversation = conversations[index];
        return Dismissible(
          key: Key(conversation.id),
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          direction: DismissDirection.endToStart,
          confirmDismiss: (direction) async {
            return await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Archive conversation?'),
                content: const Text(
                  'This conversation will be moved to archive.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Archive'),
                  ),
                ],
              ),
            );
          },
          onDismissed: (direction) => onArchive(conversation.id),
          child: ListTile(
            leading: Stack(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage: null,
                  child: const Icon(Icons.person),
                ),
                if (conversation.unreadCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF25D366),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        conversation.unreadCount > 9
                            ? '9+'
                            : conversation.unreadCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    conversation.conversationName ?? 'Unknown',
                    style: TextStyle(
                      fontWeight: conversation.unreadCount > 0
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(
                  Icons.chat,
                  size: 16,
                  color: Colors.grey,
                ),
              ],
            ),
            subtitle: Row(
              children: [
                Expanded(
                  child: Text(
                    conversation.lastMessageText ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: conversation.unreadCount > 0
                          ? Colors.black87
                          : Colors.grey[600],
                    ),
                  ),
                ),
                if (conversation.isPinned)
                  const Icon(
                    Icons.push_pin,
                    size: 14,
                    color: Colors.grey,
                  ),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatTime(conversation.lastMessageAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: conversation.unreadCount > 0
                        ? const Color(0xFF25D366)
                        : Colors.grey,
                  ),
                ),
                if (conversation.isMuted)
                  const Icon(
                    Icons.volume_off,
                    size: 16,
                    color: Colors.grey,
                  ),
              ],
            ),
            onTap: () => onConversationTap(conversation),
            onLongPress: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: Icon(
                        conversation.isPinned
                            ? Icons.push_pin_outlined
                            : Icons.push_pin,
                      ),
                      title: Text(
                        conversation.isPinned ? 'Unpin' : 'Pin conversation',
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        onPin(conversation.id);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.archive),
                      title: const Text('Archive conversation'),
                      onTap: () {
                        Navigator.pop(context);
                        onArchive(conversation.id);
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return days[dateTime.weekday - 1];
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}
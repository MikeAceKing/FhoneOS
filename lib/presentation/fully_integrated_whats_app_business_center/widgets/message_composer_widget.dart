import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class MessageComposerWidget extends StatefulWidget {
  final Function(String body, List<String>? mediaUrls) onSendMessage;

  const MessageComposerWidget({
    super.key,
    required this.onSendMessage,
  });

  @override
  State<MessageComposerWidget> createState() => _MessageComposerWidgetState();
}

class _MessageComposerWidgetState extends State<MessageComposerWidget> {
  final TextEditingController _messageController = TextEditingController();
  bool _showEmojiPicker = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    widget.onSendMessage(_messageController.text.trim(), null);
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Emoji button
          IconButton(
            icon: Icon(
              _showEmojiPicker ? Icons.keyboard : Icons.emoji_emotions_outlined,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            onPressed: () {
              setState(() => _showEmojiPicker = !_showEmojiPicker);
            },
          ),
          // Text input
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 3.w),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Type a message',
                  hintStyle: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  border: InputBorder.none,
                ),
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
              ),
            ),
          ),
          SizedBox(width: 1.w),
          // Attachment button
          IconButton(
            icon: Icon(
              Icons.attach_file,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            onPressed: () {
              _showAttachmentOptions(context);
            },
          ),
          // Camera button
          IconButton(
            icon: Icon(
              Icons.camera_alt,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            onPressed: () {
              // Open camera
            },
          ),
          // Send button
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF25D366),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(
                Icons.send,
                color: Colors.white,
              ),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }

  void _showAttachmentOptions(BuildContext context) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: EdgeInsets.symmetric(vertical: 1.h),
                width: 10.w,
                height: 0.5.h,
                decoration: BoxDecoration(
                  color:
                      theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 3,
                padding: EdgeInsets.all(4.w),
                mainAxisSpacing: 2.h,
                crossAxisSpacing: 4.w,
                children: [
                  _buildAttachmentOption(
                    theme,
                    Icons.insert_drive_file,
                    'Document',
                    const Color(0xFF7F66FF),
                  ),
                  _buildAttachmentOption(
                    theme,
                    Icons.photo_library,
                    'Gallery',
                    const Color(0xFFD3396D),
                  ),
                  _buildAttachmentOption(
                    theme,
                    Icons.headset,
                    'Audio',
                    const Color(0xFFF57C00),
                  ),
                  _buildAttachmentOption(
                    theme,
                    Icons.location_on,
                    'Location',
                    const Color(0xFF1DA362),
                  ),
                  _buildAttachmentOption(
                    theme,
                    Icons.person,
                    'Contact',
                    const Color(0xFF03A9F4),
                  ),
                ],
              ),
              SizedBox(height: 2.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttachmentOption(
      ThemeData theme, IconData icon, String label, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 15.w,
          height: 15.w,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 28,
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          label,
          style: theme.textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

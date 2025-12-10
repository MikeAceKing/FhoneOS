import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:record/record.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart' as emoji;

/// Chat Screen Widget
/// Individual chat interface with message bubbles and input area
class ChatScreenWidget extends StatefulWidget {
  final Map<String, dynamic> contact;
  final VoidCallback onBack;

  const ChatScreenWidget({
    super.key,
    required this.contact,
    required this.onBack,
  });

  @override
  State<ChatScreenWidget> createState() => _ChatScreenWidgetState();
}

class _ChatScreenWidgetState extends State<ChatScreenWidget> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _imagePicker = ImagePicker();
  final AudioRecorder _audioRecorder = AudioRecorder();

  bool _showEmojiPicker = false;
  bool _isRecording = false;
  bool _isTyping = false;
  String? _recordingPath;

  // Mock messages data
  final List<Map<String, dynamic>> _messages = [
    {
      "id": "msg_1",
      "text": "Hey! How are you doing?",
      "isSent": false,
      "timestamp": DateTime.now().subtract(const Duration(hours: 2)),
      "isRead": true,
      "type": "text",
    },
    {
      "id": "msg_2",
      "text": "I'm doing great! Just finished a project.",
      "isSent": true,
      "timestamp":
          DateTime.now().subtract(const Duration(hours: 1, minutes: 55)),
      "isRead": true,
      "type": "text",
    },
    {
      "id": "msg_3",
      "text": "That's awesome! Want to celebrate?",
      "isSent": false,
      "timestamp":
          DateTime.now().subtract(const Duration(hours: 1, minutes: 50)),
      "isRead": true,
      "type": "text",
    },
    {
      "id": "msg_4",
      "imageUrl":
          "https://img.rocket.new/generatedImages/rocket_gen_img_1bbf1f19a-1764693319066.png",
      "semanticLabel":
          "Celebration photo showing colorful confetti and balloons against a bright background",
      "isSent": true,
      "timestamp":
          DateTime.now().subtract(const Duration(hours: 1, minutes: 45)),
      "isRead": true,
      "type": "image",
    },
    {
      "id": "msg_5",
      "text": "Perfect! Let's do it! 🎉",
      "isSent": false,
      "timestamp":
          DateTime.now().subtract(const Duration(hours: 1, minutes: 40)),
      "isRead": true,
      "type": "text",
    },
    {
      "id": "msg_6",
      "text": "Are you free for a video call later?",
      "isSent": false,
      "timestamp": DateTime.now().subtract(const Duration(minutes: 5)),
      "isRead": false,
      "type": "text",
    },
  ];

  @override
  void initState() {
    super.initState();
    _messageController.addListener(_onTextChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _messageController.removeListener(_onTextChanged);
    _messageController.dispose();
    _scrollController.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _isTyping = _messageController.text.isNotEmpty;
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final newMessage = {
      "id": "msg_${DateTime.now().millisecondsSinceEpoch}",
      "text": _messageController.text.trim(),
      "isSent": true,
      "timestamp": DateTime.now(),
      "isRead": false,
      "type": "text",
    };

    setState(() {
      _messages.add(newMessage);
      _messageController.clear();
      _isTyping = false;
    });

    await Future.delayed(const Duration(milliseconds: 100));
    _scrollToBottom();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(source: source);
      if (image != null) {
        final newMessage = {
          "id": "msg_${DateTime.now().millisecondsSinceEpoch}",
          "imageUrl": image.path,
          "semanticLabel":
              "User shared image from ${source == ImageSource.camera ? 'camera' : 'gallery'}",
          "isSent": true,
          "timestamp": DateTime.now(),
          "isRead": false,
          "type": "image",
        };

        setState(() {
          _messages.add(newMessage);
        });

        await Future.delayed(const Duration(milliseconds: 100));
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt'],
      );

      if (result != null) {
        final newMessage = {
          "id": "msg_${DateTime.now().millisecondsSinceEpoch}",
          "text": "📎 ${result.files.first.name}",
          "isSent": true,
          "timestamp": DateTime.now(),
          "isRead": false,
          "type": "file",
        };

        setState(() {
          _messages.add(newMessage);
        });

        await Future.delayed(const Duration(milliseconds: 100));
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick file: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        setState(() {
          _isRecording = true;
        });

        if (kIsWeb) {
          await _audioRecorder.start(
            const RecordConfig(encoder: AudioEncoder.wav),
            path: 'recording.wav',
          );
        } else {
          await _audioRecorder.start(
            const RecordConfig(),
            path: 'recording.m4a',
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Microphone permission required'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isRecording = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to start recording: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _audioRecorder.stop();
      setState(() {
        _isRecording = false;
        _recordingPath = path;
      });

      if (path != null) {
        final newMessage = {
          "id": "msg_${DateTime.now().millisecondsSinceEpoch}",
          "text": "🎤 Voice message",
          "isSent": true,
          "timestamp": DateTime.now(),
          "isRead": false,
          "type": "voice",
        };

        setState(() {
          _messages.add(newMessage);
        });

        await Future.delayed(const Duration(milliseconds: 100));
        _scrollToBottom();
      }
    } catch (e) {
      setState(() {
        _isRecording = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to stop recording: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _showMessageOptions(Map<String, dynamic> message) {
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
                  iconName: 'content_copy',
                  color: theme.colorScheme.onSurface,
                  size: 24,
                ),
                title: Text(
                  'Copy',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Message copied',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      backgroundColor: theme.colorScheme.primary,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
              ListTile(
                leading: CustomIconWidget(
                  iconName: 'reply',
                  color: theme.colorScheme.onSurface,
                  size: 24,
                ),
                title: Text(
                  'Reply',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Reply feature coming soon',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      backgroundColor: theme.colorScheme.primary,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
              ListTile(
                leading: CustomIconWidget(
                  iconName: 'forward',
                  color: theme.colorScheme.onSurface,
                  size: 24,
                ),
                title: Text(
                  'Forward',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Forward feature coming soon',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      backgroundColor: theme.colorScheme.primary,
                      duration: const Duration(seconds: 2),
                    ),
                  );
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
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _messages.removeWhere((m) => m["id"] == message["id"]);
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Message deleted',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      backgroundColor: theme.colorScheme.error,
                      duration: const Duration(seconds: 2),
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

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: _buildAppBar(theme),
      body: Column(
        children: [
          Expanded(
            child: _buildMessageList(theme),
          ),
          if (_showEmojiPicker) _buildEmojiPicker(),
          _buildInputArea(theme),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeData theme) {
    final isOnline = widget.contact["isOnline"] as bool;

    return AppBar(
      backgroundColor: theme.colorScheme.surface,
      elevation: 2,
      leading: IconButton(
        icon: CustomIconWidget(
          iconName: 'arrow_back',
          color: theme.colorScheme.onSurface,
          size: 24,
        ),
        onPressed: widget.onBack,
      ),
      title: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: theme.colorScheme.primaryContainer,
                child: ClipOval(
                  child: CustomImageWidget(
                    imageUrl: widget.contact["contactAvatar"] as String,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    semanticLabel: widget.contact["semanticLabel"] as String,
                  ),
                ),
              ),
              if (isOnline)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.tertiary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.colorScheme.surface,
                        width: 2,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.contact["contactName"] as String,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  isOnline ? 'Online' : 'Offline',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isOnline
                        ? theme.colorScheme.tertiary
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: CustomIconWidget(
            iconName: 'call',
            color: theme.colorScheme.primary,
            size: 24,
          ),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Calling ${widget.contact["contactName"]}...',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                  ),
                ),
                backgroundColor: theme.colorScheme.primary,
                duration: const Duration(seconds: 2),
              ),
            );
          },
          tooltip: 'Voice Call',
        ),
        IconButton(
          icon: CustomIconWidget(
            iconName: 'videocam',
            color: theme.colorScheme.primary,
            size: 24,
          ),
          onPressed: () {
            Navigator.pushNamed(context, '/video-calling-interface');
          },
          tooltip: 'Video Call',
        ),
        SizedBox(width: 2.w),
      ],
    );
  }

  Widget _buildMessageList(ThemeData theme) {
    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        final isSent = message["isSent"] as bool;
        final type = message["type"] as String;

        return GestureDetector(
          onLongPress: () => _showMessageOptions(message),
          child: Align(
            alignment: isSent ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              margin: EdgeInsets.only(bottom: 1.h),
              constraints: BoxConstraints(maxWidth: 75.w),
              child: Column(
                crossAxisAlignment:
                    isSent ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
                    decoration: BoxDecoration(
                      color: isSent
                          ? theme.colorScheme.primary
                          : theme.colorScheme.surface,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(isSent ? 16 : 4),
                        bottomRight: Radius.circular(isSent ? 4 : 16),
                      ),
                      border: !isSent
                          ? Border.all(
                              color: theme.colorScheme.outline
                                  .withValues(alpha: 0.3),
                            )
                          : null,
                    ),
                    child: type == "image"
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CustomImageWidget(
                              imageUrl: message["imageUrl"] as String,
                              width: 60.w,
                              height: 30.h,
                              fit: BoxFit.cover,
                              semanticLabel: message["semanticLabel"] as String,
                            ),
                          )
                        : Text(
                            message["text"] as String,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: isSent
                                  ? Colors.white
                                  : theme.colorScheme.onSurface,
                            ),
                          ),
                  ),
                  SizedBox(height: 0.5.h),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatTimestamp(message["timestamp"] as DateTime),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 10.sp,
                        ),
                      ),
                      if (isSent) ...[
                        SizedBox(width: 1.w),
                        CustomIconWidget(
                          iconName:
                              message["isRead"] as bool ? 'done_all' : 'done',
                          color: message["isRead"] as bool
                              ? theme.colorScheme.tertiary
                              : theme.colorScheme.onSurfaceVariant,
                          size: 14,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmojiPicker() {
    return SizedBox(
      height: 30.h,
      child: EmojiPicker(
        onEmojiSelected: (category, emoji) {
          _messageController.text += emoji.emoji;
        },
        config: emoji.Config(
          height: 30.h,
          checkPlatformCompatibility: true,
          emojiViewConfig: emoji.EmojiViewConfig(
            emojiSizeMax: 28,
            backgroundColor: Theme.of(context).colorScheme.surface,
          ),
          skinToneConfig: const emoji.SkinToneConfig(),
          categoryViewConfig: emoji.CategoryViewConfig(
            backgroundColor: Theme.of(context).colorScheme.surface,
            iconColorSelected: Theme.of(context).colorScheme.primary,
          ),
          bottomActionBarConfig: emoji.BottomActionBarConfig(
            backgroundColor: Theme.of(context).colorScheme.surface,
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea(ThemeData theme) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            IconButton(
              icon: CustomIconWidget(
                iconName: _showEmojiPicker ? 'keyboard' : 'emoji_emotions',
                color: theme.colorScheme.primary,
                size: 24,
              ),
              onPressed: () {
                setState(() {
                  _showEmojiPicker = !_showEmojiPicker;
                });
              },
              tooltip: _showEmojiPicker ? 'Show Keyboard' : 'Show Emoji',
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _messageController,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    hintStyle: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 1.5.h),
                  ),
                  maxLines: null,
                  textInputAction: TextInputAction.newline,
                ),
              ),
            ),
            IconButton(
              icon: CustomIconWidget(
                iconName: 'attach_file',
                color: theme.colorScheme.primary,
                size: 24,
              ),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  backgroundColor: theme.colorScheme.surface,
                  shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  builder: (context) {
                    return SafeArea(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            leading: CustomIconWidget(
                              iconName: 'camera_alt',
                              color: theme.colorScheme.primary,
                              size: 24,
                            ),
                            title: Text(
                              'Camera',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            onTap: () {
                              Navigator.pop(context);
                              _pickImage(ImageSource.camera);
                            },
                          ),
                          ListTile(
                            leading: CustomIconWidget(
                              iconName: 'photo_library',
                              color: theme.colorScheme.primary,
                              size: 24,
                            ),
                            title: Text(
                              'Gallery',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            onTap: () {
                              Navigator.pop(context);
                              _pickImage(ImageSource.gallery);
                            },
                          ),
                          ListTile(
                            leading: CustomIconWidget(
                              iconName: 'insert_drive_file',
                              color: theme.colorScheme.primary,
                              size: 24,
                            ),
                            title: Text(
                              'Document',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            onTap: () {
                              Navigator.pop(context);
                              _pickFile();
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              tooltip: 'Attach',
            ),
            _isTyping
                ? IconButton(
                    icon: CustomIconWidget(
                      iconName: 'send',
                      color: theme.colorScheme.primary,
                      size: 24,
                    ),
                    onPressed: _sendMessage,
                    tooltip: 'Send',
                  )
                : GestureDetector(
                    onLongPressStart: (_) => _startRecording(),
                    onLongPressEnd: (_) => _stopRecording(),
                    child: Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        color: _isRecording
                            ? theme.colorScheme.error
                            : theme.colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: CustomIconWidget(
                        iconName: 'mic',
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
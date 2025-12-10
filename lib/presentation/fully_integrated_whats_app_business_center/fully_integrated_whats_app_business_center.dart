import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../services/messaging_service.dart';
import '../../widgets/custom_bottom_bar.dart';
import './widgets/conversation_list_widget.dart';
import './widgets/message_composer_widget.dart';
import './widgets/platform_filter_widget.dart';

/// Fully Integrated WhatsApp Business Center with Twilio Conversations API
class FullyIntegratedWhatsAppBusinessCenter extends StatefulWidget {
  const FullyIntegratedWhatsAppBusinessCenter({super.key});

  @override
  State<FullyIntegratedWhatsAppBusinessCenter> createState() =>
      _FullyIntegratedWhatsAppBusinessCenterState();
}

class _FullyIntegratedWhatsAppBusinessCenterState
    extends State<FullyIntegratedWhatsAppBusinessCenter> {
  final MessagingService _messagingService = MessagingService();
  int _currentBottomNavIndex = 1;
  List<Map<String, dynamic>> _conversations = [];
  Map<String, dynamic>? _selectedConversation;
  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = true;
  String _selectedPlatform = 'all';

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    setState(() => _isLoading = true);
    try {
      final conversations = await _messagingService.getConversations(
        platform: _selectedPlatform == 'all' ? null : _selectedPlatform,
      );
      setState(() {
        _conversations = conversations;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading conversations: $e')),
        );
      }
    }
  }

  Future<void> _loadMessages(String conversationId) async {
    try {
      final messages = await _messagingService.getMessages(conversationId);
      setState(() {
        _messages = messages;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading messages: $e')),
        );
      }
    }
  }

  Future<void> _sendMessage(String body, List<String>? mediaUrls) async {
    if (_selectedConversation == null) return;

    try {
      await _messagingService.sendMessage(
        conversationId: _selectedConversation!['id'],
        body: body,
        mediaUrls: mediaUrls,
      );
      await _loadMessages(_selectedConversation!['id']);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sending message: $e')),
        );
      }
    }
  }

  void _handleBottomNavTap(int index) {
    if (index == _currentBottomNavIndex) return;

    setState(() => _currentBottomNavIndex = index);

    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/unified-social-inbox-hub');
        break;
      case 1:
        break;
      case 2:
        Navigator.pushNamed(context, '/enhanced-app-launcher-desktop');
        break;
      case 3:
        Navigator.pushNamed(context, '/user-profile-screen');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFF25D366),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(1.w),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.help_outline,
                color: Colors.white,
                size: 24,
              ),
            ),
            SizedBox(width: 2.w),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'WhatsApp Business',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Twilio Integration',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              // Search functionality
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {
              // More options
            },
          ),
        ],
      ),
      body: _selectedConversation == null
          ? _buildConversationList(theme)
          : _buildChatView(theme),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: _currentBottomNavIndex,
        onTap: _handleBottomNavTap,
        items: const [
          CustomBottomBarItem(
            label: 'Social',
            icon: Icons.groups_outlined,
            activeIcon: Icons.groups,
            route: '/unified-social-inbox-hub',
          ),
          CustomBottomBarItem(
            label: 'WhatsApp',
            icon: Icons.chat_bubble_outline,
            activeIcon: Icons.chat_bubble,
            route: '/fully-integrated-whats-app-business-center',
          ),
          CustomBottomBarItem(
            label: 'Desktop',
            icon: Icons.apps_outlined,
            activeIcon: Icons.apps,
            route: '/enhanced-app-launcher-desktop',
          ),
          CustomBottomBarItem(
            label: 'Profile',
            icon: Icons.person_outline,
            activeIcon: Icons.person,
            route: '/user-profile-screen',
          ),
        ],
      ),
    );
  }

  Widget _buildConversationList(ThemeData theme) {
    return Column(
      children: [
        // Platform filter
        PlatformFilterWidget(
          selectedPlatform: _selectedPlatform,
          onPlatformChanged: (platform) {
            setState(() => _selectedPlatform = platform);
            _loadConversations();
          },
        ),
        // Conversation list
        Expanded(
          child: _isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    color: const Color(0xFF25D366),
                  ),
                )
              : _conversations.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 64,
                            color: theme.colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.3),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'No conversations yet',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ConversationListWidget(
                      conversations: _conversations,
                      onConversationTap: (conversation) {
                        setState(() => _selectedConversation = conversation);
                        _loadMessages(conversation['id']);
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildChatView(ThemeData theme) {
    return Column(
      children: [
        // Chat header
        Container(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            border: Border(
              bottom: BorderSide(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    _selectedConversation = null;
                    _messages = [];
                  });
                },
              ),
              CircleAvatar(
                backgroundColor: const Color(0xFF25D366),
                child: const Icon(Icons.person, color: Colors.white),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedConversation!['conversation_name'] ?? 'Contact',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      _selectedConversation!['whatsapp_contact_id'] ?? '',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.videocam),
                onPressed: () {
                  // Video call
                },
              ),
              IconButton(
                icon: const Icon(Icons.call),
                onPressed: () {
                  // Voice call
                },
              ),
            ],
          ),
        ),
        // Messages
        Expanded(
          child: _messages.isEmpty
              ? Center(
                  child: Text(
                    'No messages yet',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              : ListView.builder(
                  reverse: true,
                  padding: EdgeInsets.all(2.h),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[index];
                    final isOutgoing = message['direction'] == 'outgoing';
                    return _buildMessageBubble(theme, message, isOutgoing);
                  },
                ),
        ),
        // Message composer
        MessageComposerWidget(
          onSendMessage: _sendMessage,
        ),
      ],
    );
  }

  Widget _buildMessageBubble(
      ThemeData theme, Map<String, dynamic> message, bool isOutgoing) {
    return Align(
      alignment: isOutgoing ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 0.5.h),
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
        constraints: BoxConstraints(maxWidth: 75.w),
        decoration: BoxDecoration(
          color: isOutgoing
              ? const Color(0xFFDCF8C6)
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message['body'] ?? '',
              style: theme.textTheme.bodyMedium,
            ),
            SizedBox(height: 0.5.h),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatTime(message['sent_at']),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 10.sp,
                  ),
                ),
                if (isOutgoing) ...[
                  SizedBox(width: 1.w),
                  Icon(
                    message['status'] == 'read'
                        ? Icons.done_all
                        : message['status'] == 'delivered'
                            ? Icons.done_all
                            : Icons.done,
                    size: 16,
                    color: message['status'] == 'read'
                        ? const Color(0xFF34B7F1)
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(String? timestamp) {
    if (timestamp == null) return '';
    try {
      final dateTime = DateTime.parse(timestamp);
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '';
    }
  }
}

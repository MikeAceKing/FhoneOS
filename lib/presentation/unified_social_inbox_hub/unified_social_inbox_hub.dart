import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import '../../models/message_thread.dart';
import '../../routes/app_routes.dart';
import '../../services/messaging_service.dart';
import './widgets/compose_message_widget.dart';
import './widgets/platform_filter_widget.dart';
import './widgets/thread_list_item_widget.dart';

class UnifiedSocialInboxHub extends StatefulWidget {
  const UnifiedSocialInboxHub({super.key});

  @override
  State<UnifiedSocialInboxHub> createState() => _UnifiedSocialInboxHubState();
}

class _UnifiedSocialInboxHubState extends State<UnifiedSocialInboxHub> {
  final MessagingService _messagingService = MessagingService();
  List<MessageThread> _threads = [];
  bool _isLoading = true;
  String? _selectedPlatform;
  bool _showUnreadOnly = false;
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _loadThreads();
    _loadUnreadCount();
  }

  Future<void> _loadThreads() async {
    setState(() => _isLoading = true);
    try {
      final userId = _messagingService.client.auth.currentUser?.id;
      if (userId == null) {
        setState(() {
          _threads = [];
          _isLoading = false;
        });
        return;
      }
      final threadsData = await _messagingService.getUserConversations(
        userId,
        platform: _selectedPlatform,
        unreadOnly: _showUnreadOnly,
      );
      final threads =
          threadsData.map((data) => MessageThread.fromJson(data)).toList();
      setState(() {
        _threads = threads;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load messages: $e')),
        );
      }
    }
  }

  Future<void> _loadUnreadCount() async {
    final userId = _messagingService.client.auth.currentUser?.id;
    if (userId == null) {
      setState(() => _unreadCount = 0);
      return;
    }
    final count = await _messagingService.getUnreadCount(userId);
    setState(() => _unreadCount = count);
  }

  void _onPlatformSelected(String? platform) {
    setState(() => _selectedPlatform = platform);
    _loadThreads();
  }

  void _onUnreadFilterToggle(bool value) {
    setState(() => _showUnreadOnly = value);
    _loadThreads();
  }

  void _onThreadTap(MessageThread thread) {
    Navigator.pushNamed(
      context,
      AppRoutes.messagingInterface,
      arguments: {'threadId': thread.id, 'thread': thread},
    ).then((_) {
      _loadThreads();
      _loadUnreadCount();
    });
  }

  void _showComposeDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ComposeMessageWidget(
        onMessageSent: () {
          _loadThreads();
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Social Inbox',
          style: TextStyle(
            color: Color(0xFF2D3142),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          if (_unreadCount > 0)
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF01C38D),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$_unreadCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          IconButton(
            icon: Icon(
              _showUnreadOnly ? Icons.mark_email_read : Icons.filter_list,
              color: const Color(0xFF2D3142),
            ),
            onPressed: () => _onUnreadFilterToggle(!_showUnreadOnly),
          ),
        ],
      ),
      body: Column(
        children: [
          PlatformFilterWidget(
            selectedPlatform: _selectedPlatform,
            onPlatformSelected: _onPlatformSelected,
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _threads.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadThreads,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: _threads.length,
                          itemBuilder: (context, index) {
                            return ThreadListItemWidget(
                              thread: _threads[index],
                              onTap: () => _onThreadTap(_threads[index]),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showComposeDialog,
        backgroundColor: const Color(0xFF4D9FFF),
        child: const Icon(Icons.edit, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            _showUnreadOnly ? 'No unread messages' : 'No messages yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _showUnreadOnly
                ? 'All caught up!'
                : 'Connect your platforms to start messaging',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}

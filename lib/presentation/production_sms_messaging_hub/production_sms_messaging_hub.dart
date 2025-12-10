import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../services/messaging_service.dart';

class ProductionSmsMessagingHub extends StatefulWidget {
  const ProductionSmsMessagingHub({super.key});

  @override
  State<ProductionSmsMessagingHub> createState() =>
      _ProductionSmsMessagingHubState();
}

class _ProductionSmsMessagingHubState extends State<ProductionSmsMessagingHub>
    with SingleTickerProviderStateMixin {
  final _messagingService = MessagingService();
  late TabController _tabController;

  List<Map<String, dynamic>> _conversations = [];
  Map<String, dynamic>? _selectedConversation;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (!mounted) return;

    setState(() => _isLoading = true);
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId != null) {
        // Now using conversations table instead of message_threads
        final conversations =
            await _messagingService.getUserConversations(userId);

        if (mounted) {
          setState(() {
            _conversations = conversations;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      // Silent fail - show empty state instead of error
      if (mounted) {
        setState(() {
          _conversations = [];
          _isLoading = false;
        });
      }
    }
  }

  void _onConversationSelected(Map<String, dynamic> conversation) {
    setState(() => _selectedConversation = conversation);
    _messagingService.markConversationAsRead(conversation['id']);
  }

  Future<void> _onNewMessage() async {
    // Show compose dialog (implementation depends on UI requirements)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Compose new message')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF01C38D),
        title: const Text(
          'Messages',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {},
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Conversations'),
            Tab(text: 'Contacts'),
            Tab(text: 'Archived'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildConversationsTab(),
                _buildContactsTab(),
                _buildArchivedTab(),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF01C38D),
        onPressed: _onNewMessage,
        child: const Icon(Icons.message, color: Colors.white),
      ),
    );
  }

  Widget _buildConversationsTab() {
    // Gracefully handle empty conversations list
    if (_conversations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No conversations yet',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Start a new conversation',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _conversations.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final conversation = _conversations[index];
          return ListTile(
            leading: CircleAvatar(
              child: Text(
                (conversation['conversation_name'] ?? 'U')[0].toUpperCase(),
              ),
            ),
            title: Text(
              conversation['conversation_name'] ?? 'Unknown',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              conversation['last_message_text'] ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: conversation['unread_count'] != null &&
                    conversation['unread_count'] > 0
                ? CircleAvatar(
                    radius: 12,
                    backgroundColor: const Color(0xFF01C38D),
                    child: Text(
                      '${conversation['unread_count']}',
                      style: const TextStyle(fontSize: 10, color: Colors.white),
                    ),
                  )
                : null,
            onTap: () => _onConversationSelected(conversation),
          );
        },
      ),
    );
  }

  Widget _buildContactsTab() {
    return const Center(
      child: Text('Contacts feature coming soon'),
    );
  }

  Widget _buildArchivedTab() {
    final archived =
        _conversations.where((c) => c['is_archived'] == true).toList();

    if (archived.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.archive_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No archived conversations',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: archived.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final conversation = archived[index];
        return ListTile(
          leading: CircleAvatar(
            child: Text(
              (conversation['conversation_name'] ?? 'U')[0].toUpperCase(),
            ),
          ),
          title: Text(conversation['conversation_name'] ?? 'Unknown'),
          subtitle: Text(conversation['last_message_text'] ?? ''),
          onTap: () => _onConversationSelected(conversation),
        );
      },
    );
  }
}

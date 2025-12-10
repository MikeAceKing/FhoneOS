import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/conversation.dart';
import '../../services/twilio_messaging_service.dart';
import './widgets/conversation_list_widget.dart';
import './widgets/message_composer_widget.dart';
import './widgets/platform_filter_widget.dart';

/// WhatsApp Integration Hub screen with Twilio Conversations API
class WhatsAppIntegrationHub extends StatefulWidget {
  const WhatsAppIntegrationHub({Key? key}) : super(key: key);

  @override
  State<WhatsAppIntegrationHub> createState() => _WhatsAppIntegrationHubState();
}

class _WhatsAppIntegrationHubState extends State<WhatsAppIntegrationHub> {
  final TwilioMessagingService _messagingService = TwilioMessagingService();
  List<Conversation> _conversations = [];
  bool _isLoading = true;
  String _selectedPlatform = 'all';
  String _searchQuery = '';
  RealtimeChannel? _conversationsChannel;

  @override
  void initState() {
    super.initState();
    _loadConversations();
    _setupRealtimeSubscription();
  }

  Future<void> _loadConversations() async {
    setState(() => _isLoading = true);
    try {
      final conversations = await _messagingService.getConversations(
        platform: _selectedPlatform == 'all' ? null : _selectedPlatform,
      );
      if (mounted) {
        setState(() {
          _conversations = conversations;
          _isLoading = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading conversations: $error')),
        );
      }
    }
  }

  void _setupRealtimeSubscription() {
    _conversationsChannel = _messagingService.subscribeToConversations((data) {
      _loadConversations();
    });
  }

  Future<void> _searchConversations(String query) async {
    if (query.isEmpty) {
      _loadConversations();
      return;
    }

    setState(() => _isLoading = true);
    try {
      final results = await _messagingService.searchConversations(query);
      if (mounted) {
        setState(() {
          _conversations = results;
          _isLoading = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _conversationsChannel?.unsubscribe();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'WhatsApp Integration Hub',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xFF25D366),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: _ConversationSearchDelegate(
                  onSearch: _searchConversations,
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          PlatformFilterWidget(
            selectedPlatform: _selectedPlatform,
            onPlatformChanged: (platform) {
              setState(() => _selectedPlatform = platform);
              _loadConversations();
            },
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _conversations.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No conversations yet',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ConversationListWidget(
                        conversations: _conversations,
                        onConversationTap: (conversation) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => _ChatScreen(
                                conversation: conversation,
                                messagingService: _messagingService,
                              ),
                            ),
                          );
                        },
                        onArchive: (conversationId) async {
                          await _messagingService.toggleArchive(
                            conversationId,
                            true,
                          );
                          _loadConversations();
                        },
                        onPin: (conversationId) async {
                          final conversation = _conversations.firstWhere(
                            (c) => c.id == conversationId,
                          );
                          await _messagingService.togglePin(
                            conversationId,
                            !conversation.isPinned,
                          );
                          _loadConversations();
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF25D366),
        child: const Icon(Icons.message),
      ),
    );
  }
}

class _ChatScreen extends StatelessWidget {
  final Conversation conversation;
  final TwilioMessagingService messagingService;

  const _ChatScreen({
    required this.conversation,
    required this.messagingService,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: null,
              child: const Icon(Icons.person),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    conversation.conversationName ?? 'Unknown',
                    style: const TextStyle(fontSize: 16),
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.help_outline,
                        size: 14,
                        color: const Color(0xFF25D366),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'SMS',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF075E54),
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.call),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: const Color(0xFFECE5DD),
              child: const Center(
                child: Text('Messages will appear here'),
              ),
            ),
          ),
          MessageComposerWidget(
            onSendMessage: (message, mediaUrls) async {
              await messagingService.sendMessage(
                conversationId: conversation.id,
                body: message,
                platform: 'sms',
                mediaUrls: mediaUrls,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ConversationSearchDelegate extends SearchDelegate<String> {
  final Function(String) onSearch;

  _ConversationSearchDelegate({required this.onSearch});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () => query = '',
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, ''),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    onSearch(query);
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container();
  }
}
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/conversation.dart';
import '../models/message.dart';

/// Service for managing Twilio Conversations API and WhatsApp messaging
class TwilioMessagingService {
  final SupabaseClient _client = Supabase.instance.client;

  /// Get all conversations with platform filtering
  Future<List<Conversation>> getConversations({
    String? platform,
    bool? isArchived,
  }) async {
    try {
      var query = _client
          .from('conversations')
          .select('*, contacts(*), phone_numbers(*)')
          .eq('user_id', _client.auth.currentUser!.id);

      if (platform != null) {
        query = query.eq('platform', platform);
      }

      if (isArchived != null) {
        query = query.eq('is_archived', isArchived);
      }

      final response = await query
          .order('is_pinned', ascending: false)
          .order('last_message_at', ascending: false);

      return (response as List)
          .map((json) => Conversation.fromJson(json))
          .toList();
    } catch (error) {
      throw Exception('Failed to fetch conversations: $error');
    }
  }

  /// Get messages for a specific conversation
  Future<List<Message>> getMessages(
    String conversationId, {
    int limit = 50,
  }) async {
    try {
      final response = await _client
          .from('messages')
          .select('*, message_attachments(*)')
          .eq('conversation_id', conversationId)
          .order('sent_at', ascending: false)
          .limit(limit);

      return (response as List).map((json) => Message.fromJson(json)).toList();
    } catch (error) {
      throw Exception('Failed to fetch messages: $error');
    }
  }

  /// Send a new message (SMS or WhatsApp)
  Future<Message> sendMessage({
    required String conversationId,
    required String body,
    String platform = 'sms',
    List<String>? mediaUrls,
  }) async {
    try {
      final conversation = await _client
          .from('conversations')
          .select('*, phone_numbers(*)')
          .eq('id', conversationId)
          .single();

      final messageData = {
        'conversation_id': conversationId,
        'account_id': conversation['account_id'],
        'user_id': _client.auth.currentUser!.id,
        'from_number': conversation['phone_numbers']['e164_number'],
        'to_number': conversation['contact_id'],
        'body': body,
        'platform': platform,
        'direction': 'outgoing',
        'status': 'sending',
        'media_urls': mediaUrls,
      };

      final response =
          await _client.from('messages').insert(messageData).select().single();

      return Message.fromJson(response);
    } catch (error) {
      throw Exception('Failed to send message: $error');
    }
  }

  /// Mark conversation as read
  Future<void> markConversationAsRead(String conversationId) async {
    try {
      await _client
          .from('conversations')
          .update({'unread_count': 0})
          .eq('id', conversationId)
          .eq('user_id', _client.auth.currentUser!.id);
    } catch (error) {
      throw Exception('Failed to mark conversation as read: $error');
    }
  }

  /// Subscribe to real-time conversation updates
  RealtimeChannel subscribeToConversations(
    Function(Map<String, dynamic>) onUpdate,
  ) {
    return _client
        .channel('conversations_channel')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'conversations',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: _client.auth.currentUser!.id,
          ),
          callback: (payload) => onUpdate(payload.newRecord),
        )
        .subscribe();
  }

  /// Subscribe to real-time message updates
  RealtimeChannel subscribeToMessages(
    String conversationId,
    Function(Map<String, dynamic>) onNewMessage,
  ) {
    return _client
        .channel('messages_channel_$conversationId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'conversation_id',
            value: conversationId,
          ),
          callback: (payload) => onNewMessage(payload.newRecord),
        )
        .subscribe();
  }

  /// Sync conversation state across devices using Twilio Sync
  Future<Map<String, dynamic>> syncConversationState({
    required String conversationId,
    required String deviceId,
  }) async {
    try {
      final response = await _client.rpc('sync_conversation_state', params: {
        'conversation_uuid': conversationId,
        'device_uuid': deviceId,
      });

      return response as Map<String, dynamic>;
    } catch (error) {
      throw Exception('Failed to sync conversation: $error');
    }
  }

  /// Search conversations
  Future<List<Conversation>> searchConversations(String query) async {
    try {
      final response = await _client
          .from('conversations')
          .select('*, contacts(*)')
          .eq('user_id', _client.auth.currentUser!.id)
          .or('conversation_name.ilike.%$query%,contacts.full_name.ilike.%$query%')
          .order('last_message_at', ascending: false);

      return (response as List)
          .map((json) => Conversation.fromJson(json))
          .toList();
    } catch (error) {
      throw Exception('Failed to search conversations: $error');
    }
  }

  /// Toggle conversation archive status
  Future<void> toggleArchive(String conversationId, bool isArchived) async {
    try {
      await _client
          .from('conversations')
          .update({'is_archived': isArchived})
          .eq('id', conversationId)
          .eq('user_id', _client.auth.currentUser!.id);
    } catch (error) {
      throw Exception('Failed to toggle archive: $error');
    }
  }

  /// Toggle conversation pin status
  Future<void> togglePin(String conversationId, bool isPinned) async {
    try {
      await _client
          .from('conversations')
          .update({'is_pinned': isPinned})
          .eq('id', conversationId)
          .eq('user_id', _client.auth.currentUser!.id);
    } catch (error) {
      throw Exception('Failed to toggle pin: $error');
    }
  }
}

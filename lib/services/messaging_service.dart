import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/contact.dart';

class MessagingService {
  final _client = Supabase.instance.client;

  // Public getter for Supabase client to allow external access
  SupabaseClient get client => _client;

  /// Fetch all conversations for current user (using conversations table)
  Future<List<Map<String, dynamic>>> getUserConversations(
    String userId, {
    String? platform,
    bool? unreadOnly,
  }) async {
    try {
      // Use conversations table instead of message_threads
      var query = _client.from('conversations').select().eq('user_id', userId);

      if (platform != null) {
        query = query.eq('platform', platform);
      }

      if (unreadOnly == true) {
        query = query.gt('unread_count', 0);
      }

      // Use maybeSingle pattern - return empty list if no data
      final response = await query.order('last_message_at', ascending: false);

      // Handle empty results gracefully
      if ((response.isEmpty)) {
        return [];
      }

      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      // Return empty list on error instead of throwing
      return [];
    }
  }

  /// Fetch messages for specific conversation
  Future<List<Map<String, dynamic>>> getConversationMessages(
      String conversationId) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return [];

      final response = await _client
          .from('messages')
          .select()
          .eq('conversation_id', conversationId)
          .eq('user_id', userId)
          .order('sent_at', ascending: true);

      // Handle empty results gracefully
      if ((response.isEmpty)) {
        return [];
      }

      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      return [];
    }
  }

  /// Send new message
  Future<Map<String, dynamic>?> sendMessage({
    required String userId,
    required String accountId,
    required String to,
    required String body,
    String? conversationId,
  }) async {
    try {
      final messageData = {
        'user_id': userId,
        'account_id': accountId,
        'to_number': to,
        'from_number': 'system', // Replace with actual phone number
        'body': body,
        'direction': 'outgoing',
        'status': 'sent',
        'sent_at': DateTime.now().toIso8601String(),
        if (conversationId != null) 'conversation_id': conversationId,
      };

      final response =
          await _client.from('messages').insert(messageData).select();

      if ((response.isEmpty)) {
        return null;
      }

      return (response as List).first as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  /// Mark conversation as read
  Future<void> markConversationAsRead(String conversationId) async {
    try {
      await _client
          .from('conversations')
          .update({'unread_count': 0}).eq('id', conversationId);

      await _client
          .from('messages')
          .update({'read_at': DateTime.now().toIso8601String()})
          .eq('conversation_id', conversationId)
          .isFilter('read_at', null);
    } catch (e) {
      // Silent fail - non-critical operation
    }
  }

  /// Get unread message count
  Future<int> getUnreadCount(String userId) async {
    try {
      final response = await _client
          .from('conversations')
          .select('unread_count')
          .eq('user_id', userId);

      if ((response.isEmpty)) {
        return 0;
      }

      final conversations = response as List;
      return conversations.fold<int>(
        0,
        (sum, conv) => sum + ((conv['unread_count'] as int?) ?? 0),
      );
    } catch (e) {
      return 0;
    }
  }

  /// Get contacts
  Future<List<Contact>> getContacts(String userId) async {
    try {
      final response = await _client
          .from('contacts')
          .select()
          .eq('user_id', userId)
          .order('full_name', ascending: true);

      if ((response.isEmpty)) {
        return [];
      }

      return (response as List).map((json) => Contact.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }
}

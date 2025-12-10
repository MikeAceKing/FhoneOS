import '../models/call.dart';
import './supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CallService {
  static final CallService _instance = CallService._internal();
  factory CallService() => _instance;
  CallService._internal();

  final _supabase = SupabaseService.instance.client;

  // ==================== CALLS ====================

  Future<List<Call>> getCallHistory({int limit = 100, int offset = 0}) async {
    try {
      final response = await _supabase
          .from('calls')
          .select()
          .order('started_at', ascending: false)
          .range(offset, offset + limit - 1);

      return (response as List).map((json) => Call.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch call history: $e');
    }
  }

  Future<Call> createCall({
    required CallType callType,
    required String fromNumber,
    required String toNumber,
    String? phoneNumberId,
    String? contactId,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final callData = {
        'user_id': user.id,
        'account_id': user.userMetadata?['account_id'],
        'phone_number_id': phoneNumberId,
        'contact_id': contactId,
        'call_type': callType.name,
        'call_status': 'ringing',
        'from_number': fromNumber,
        'to_number': toNumber,
      };

      final response =
          await _supabase.from('calls').insert(callData).select().single();

      // TODO: Initiate actual call via Twilio Voice API
      // This would be handled by your backend/Edge Function

      return Call.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create call: $e');
    }
  }

  Future<Call> updateCall(String callId, Map<String, dynamic> updates) async {
    try {
      final response = await _supabase
          .from('calls')
          .update(updates)
          .eq('id', callId)
          .select()
          .single();

      return Call.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update call: $e');
    }
  }

  Future<Call> updateCallStatus(String callId, CallStatus status,
      {int? durationSeconds}) async {
    try {
      final updates = <String, dynamic>{
        'call_status':
            status == CallStatus.inProgress ? 'in_progress' : status.name,
      };

      if (status == CallStatus.inProgress && durationSeconds == null) {
        updates['answered_at'] = DateTime.now().toIso8601String();
      }

      if (status == CallStatus.completed ||
          status == CallStatus.declined ||
          status == CallStatus.failed) {
        updates['ended_at'] = DateTime.now().toIso8601String();
        if (durationSeconds != null) {
          updates['duration_seconds'] = durationSeconds;
        }
      }

      final response = await _supabase
          .from('calls')
          .update(updates)
          .eq('id', callId)
          .select()
          .single();

      return Call.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update call status: $e');
    }
  }

  Future<Call?> getActiveCall() async {
    try {
      final response = await _supabase
          .from('calls')
          .select()
          .inFilter('call_status', ['ringing', 'in_progress'])
          .order('started_at', ascending: false)
          .limit(1)
          .maybeSingle();

      return response != null ? Call.fromJson(response) : null;
    } catch (e) {
      throw Exception('Failed to fetch active call: $e');
    }
  }

  Future<List<Call>> getCallsByContact(String contactId) async {
    try {
      final response = await _supabase
          .from('calls')
          .select()
          .eq('contact_id', contactId)
          .order('started_at', ascending: false)
          .limit(50);

      return (response as List).map((json) => Call.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch calls by contact: $e');
    }
  }

  Future<Map<String, int>> getCallStatistics() async {
    try {
      final allCalls = await getCallHistory(limit: 1000);

      final stats = {
        'total': allCalls.length,
        'incoming':
            allCalls.where((c) => c.callType == CallType.incoming).length,
        'outgoing':
            allCalls.where((c) => c.callType == CallType.outgoing).length,
        'missed':
            allCalls.where((c) => c.callStatus == CallStatus.missed).length,
        'completed':
            allCalls.where((c) => c.callStatus == CallStatus.completed).length,
        'totalDuration':
            allCalls.fold<int>(0, (sum, call) => sum + call.durationSeconds),
      };

      return stats;
    } catch (e) {
      throw Exception('Failed to calculate call statistics: $e');
    }
  }

  // ==================== VOICEMAILS ====================

  Future<List<Map<String, dynamic>>> getVoicemails(
      {bool unreadOnly = false}) async {
    try {
      var query = _supabase.from('voicemails').select();

      if (unreadOnly) {
        query = query.eq('is_read', false);
      }

      final response =
          await query.order('received_at', ascending: false).limit(50);

      return (response as List).cast<Map<String, dynamic>>();
    } catch (e) {
      throw Exception('Failed to fetch voicemails: $e');
    }
  }

  Future<void> markVoicemailAsRead(String voicemailId) async {
    try {
      await _supabase
          .from('voicemails')
          .update({'is_read': true}).eq('id', voicemailId);
    } catch (e) {
      throw Exception('Failed to mark voicemail as read: $e');
    }
  }

  // ==================== REAL-TIME SUBSCRIPTIONS ====================

  RealtimeChannel subscribeToCallUpdates(Function(Call) onCallUpdate) {
    return _supabase
        .channel('calls-changes')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'calls',
          callback: (payload) {
            if (payload.newRecord.isNotEmpty) {
              final call = Call.fromJson(payload.newRecord);
              onCallUpdate(call);
            }
          },
        )
        .subscribe();
  }

  RealtimeChannel subscribeToIncomingCalls(Function(Call) onIncomingCall) {
    return _supabase
        .channel('incoming-calls')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'calls',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'call_type',
            value: 'incoming',
          ),
          callback: (payload) {
            final call = Call.fromJson(payload.newRecord);
            onIncomingCall(call);
          },
        )
        .subscribe();
  }

  // ==================== CALL ACTIONS ====================

  Future<void> answerCall(String callId) async {
    try {
      await updateCallStatus(callId, CallStatus.inProgress);
      // TODO: Answer call via Twilio Voice API
    } catch (e) {
      throw Exception('Failed to answer call: $e');
    }
  }

  Future<void> declineCall(String callId) async {
    try {
      await updateCallStatus(callId, CallStatus.declined);
      // TODO: Decline call via Twilio Voice API
    } catch (e) {
      throw Exception('Failed to decline call: $e');
    }
  }

  Future<void> endCall(String callId, int durationSeconds) async {
    try {
      await updateCallStatus(callId, CallStatus.completed,
          durationSeconds: durationSeconds);
      // TODO: End call via Twilio Voice API
    } catch (e) {
      throw Exception('Failed to end call: $e');
    }
  }
}
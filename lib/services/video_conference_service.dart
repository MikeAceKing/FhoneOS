import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

/// Service for managing video conferencing using flutter_webrtc
class VideoConferenceService {
  final SupabaseClient _client = Supabase.instance.client;
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;

  /// Create a new video session
  Future<Map<String, dynamic>> createVideoSession({
    required String roomName,
    DateTime? scheduledAt,
    int maxParticipants = 10,
    bool isRecording = false,
  }) async {
    try {
      final sessionData = {
        'account_id': (await _client
            .from('user_profiles')
            .select('account_id')
            .eq('id', _client.auth.currentUser!.id)
            .single())['account_id'],
        'room_name': roomName,
        'host_id': _client.auth.currentUser!.id,
        'status': scheduledAt != null ? 'scheduled' : 'active',
        'scheduled_at': scheduledAt?.toIso8601String(),
        'max_participants': maxParticipants,
        'is_recording': isRecording,
      };

      final response = await _client
          .from('video_sessions')
          .insert(sessionData)
          .select()
          .single();

      return response;
    } catch (error) {
      throw Exception('Failed to create video session: $error');
    }
  }

  /// Initialize local media stream (camera and microphone)
  Future<MediaStream> initializeLocalStream({
    bool audio = true,
    bool video = true,
  }) async {
    try {
      final Map<String, dynamic> mediaConstraints = {
        'audio': audio,
        'video': video
            ? {
                'facingMode': 'user',
                'width': {'ideal': 1280},
                'height': {'ideal': 720},
              }
            : false,
      };

      _localStream =
          await navigator.mediaDevices.getUserMedia(mediaConstraints);
      return _localStream!;
    } catch (error) {
      throw Exception('Failed to initialize media stream: $error');
    }
  }

  /// Join an existing video session
  Future<void> joinVideoSession(String sessionId) async {
    try {
      // Add participant to session
      await _client.from('video_participants').insert({
        'session_id': sessionId,
        'user_id': _client.auth.currentUser!.id,
        'display_name': (await _client
            .from('user_profiles')
            .select('full_name')
            .eq('id', _client.auth.currentUser!.id)
            .single())['full_name'],
      });

      // Update session status to active if not already
      await _client
          .from('video_sessions')
          .update({
            'status': 'active',
            'started_at': DateTime.now().toIso8601String(),
          })
          .eq('id', sessionId)
          .eq('status', 'scheduled');
    } catch (error) {
      throw Exception('Failed to join video session: $error');
    }
  }

  /// Leave video session
  Future<void> leaveVideoSession(String sessionId) async {
    try {
      // Stop local media tracks
      _localStream?.getTracks().forEach((track) {
        track.stop();
      });

      // Update participant record
      await _client
          .from('video_participants')
          .update({'left_at': DateTime.now().toIso8601String()})
          .eq('session_id', sessionId)
          .eq('user_id', _client.auth.currentUser!.id)
          .isFilter('left_at', null);

      // Clean up
      await _peerConnection?.close();
      _peerConnection = null;
      _localStream = null;
    } catch (error) {
      throw Exception('Failed to leave video session: $error');
    }
  }

  /// Toggle audio (mute/unmute)
  Future<void> toggleAudio(String sessionId, bool enabled) async {
    try {
      _localStream?.getAudioTracks().forEach((track) {
        track.enabled = enabled;
      });

      await _client
          .from('video_participants')
          .update({'is_audio_enabled': enabled})
          .eq('session_id', sessionId)
          .eq('user_id', _client.auth.currentUser!.id);
    } catch (error) {
      throw Exception('Failed to toggle audio: $error');
    }
  }

  /// Toggle video (camera on/off)
  Future<void> toggleVideo(String sessionId, bool enabled) async {
    try {
      _localStream?.getVideoTracks().forEach((track) {
        track.enabled = enabled;
      });

      await _client
          .from('video_participants')
          .update({'is_video_enabled': enabled})
          .eq('session_id', sessionId)
          .eq('user_id', _client.auth.currentUser!.id);
    } catch (error) {
      throw Exception('Failed to toggle video: $error');
    }
  }

  /// Get active video sessions
  Future<List<Map<String, dynamic>>> getActiveVideoSessions() async {
    try {
      final response = await _client.rpc('get_active_video_sessions', params: {
        'user_uuid': _client.auth.currentUser!.id,
      });

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to fetch active sessions: $error');
    }
  }

  /// Get session participants
  Future<List<Map<String, dynamic>>> getSessionParticipants(
    String sessionId,
  ) async {
    try {
      final response = await _client
          .from('video_participants')
          .select('*, user_profiles(full_name, avatar_url)')
          .eq('session_id', sessionId)
          .isFilter('left_at', null)
          .order('joined_at');

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to fetch participants: $error');
    }
  }

  /// Subscribe to session updates
  RealtimeChannel subscribeToSession(
    String sessionId,
    Function(Map<String, dynamic>) onUpdate,
  ) {
    return _client
        .channel('video_session_$sessionId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'video_participants',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'session_id',
            value: sessionId,
          ),
          callback: (payload) => onUpdate(payload.newRecord),
        )
        .subscribe();
  }

  /// End video session (host only)
  Future<void> endVideoSession(String sessionId) async {
    try {
      await _client
          .from('video_sessions')
          .update({
            'status': 'completed',
            'ended_at': DateTime.now().toIso8601String(),
          })
          .eq('id', sessionId)
          .eq('host_id', _client.auth.currentUser!.id);
    } catch (error) {
      throw Exception('Failed to end session: $error');
    }
  }

  /// Cleanup resources
  void dispose() {
    _localStream?.getTracks().forEach((track) => track.stop());
    _peerConnection?.close();
  }
}

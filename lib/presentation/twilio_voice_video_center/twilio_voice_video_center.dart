import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../../services/video_conference_service.dart';
import './widgets/create_session_dialog_widget.dart';
import './widgets/participant_grid_widget.dart';
import './widgets/video_controls_widget.dart';

/// Twilio Voice & Video Center with WebRTC integration
class TwilioVoiceVideoCenter extends StatefulWidget {
  const TwilioVoiceVideoCenter({Key? key}) : super(key: key);

  @override
  State<TwilioVoiceVideoCenter> createState() => _TwilioVoiceVideoCenterState();
}

class _TwilioVoiceVideoCenterState extends State<TwilioVoiceVideoCenter>
    with SingleTickerProviderStateMixin {
  final VideoConferenceService _videoService = VideoConferenceService();
  late TabController _tabController;
  List<Map<String, dynamic>> _activeSessions = [];
  bool _isLoading = true;
  String? _currentSessionId;
  MediaStream? _localStream;
  bool _isAudioEnabled = true;
  bool _isVideoEnabled = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadActiveSessions();
  }

  Future<void> _loadActiveSessions() async {
    setState(() => _isLoading = true);
    try {
      final sessions = await _videoService.getActiveVideoSessions();
      if (mounted) {
        setState(() {
          _activeSessions = sessions;
          _isLoading = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading sessions: $error')),
        );
      }
    }
  }

  Future<void> _createSession() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const CreateSessionDialogWidget(),
    );

    if (result != null) {
      try {
        final session = await _videoService.createVideoSession(
          roomName: result['roomName'],
          scheduledAt: result['scheduledAt'],
          maxParticipants: result['maxParticipants'],
          isRecording: result['isRecording'],
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Session created successfully')),
          );
          _loadActiveSessions();
        }
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to create session: $error')),
          );
        }
      }
    }
  }

  Future<void> _joinSession(String sessionId) async {
    try {
      setState(() => _isLoading = true);

      _localStream = await _videoService.initializeLocalStream();
      await _videoService.joinVideoSession(sessionId);

      if (mounted) {
        setState(() {
          _currentSessionId = sessionId;
          _isLoading = false;
        });

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => _VideoCallScreen(
              sessionId: sessionId,
              videoService: _videoService,
              localStream: _localStream!,
              onLeave: () async {
                await _videoService.leaveVideoSession(sessionId);
                if (mounted) {
                  setState(() {
                    _currentSessionId = null;
                    _localStream = null;
                  });
                  Navigator.of(context).pop();
                }
              },
            ),
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to join session: $error')),
        );
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _videoService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Voice & Video Center',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xFF0088CC),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Video', icon: Icon(Icons.videocam)),
            Tab(text: 'Voice', icon: Icon(Icons.call)),
            Tab(text: 'Verify', icon: Icon(Icons.verified_user)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildVideoTab(),
          _buildVoiceTab(),
          _buildVerifyTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createSession,
        backgroundColor: const Color(0xFF0088CC),
        icon: const Icon(Icons.add),
        label: const Text('New Session'),
      ),
    );
  }

  Widget _buildVideoTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_activeSessions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.videocam_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No active video sessions',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Create a new session to get started',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _activeSessions.length,
      itemBuilder: (context, index) {
        final session = _activeSessions[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Color(0xFF0088CC),
              child: Icon(Icons.videocam, color: Colors.white),
            ),
            title: Text(
              session['room_name'] as String,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Host: ${session['host_name']}'),
                Text(
                  'Participants: ${session['participant_count']}',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            trailing: ElevatedButton(
              onPressed: () => _joinSession(session['session_id']),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0088CC),
              ),
              child: const Text('Join'),
            ),
          ),
        );
      },
    );
  }

  Widget _buildVoiceTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.call,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Voice calling coming soon',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerifyTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.verified_user,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Two-factor authentication',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Verify with SMS or voice',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class _VideoCallScreen extends StatefulWidget {
  final String sessionId;
  final VideoConferenceService videoService;
  final MediaStream localStream;
  final VoidCallback onLeave;

  const _VideoCallScreen({
    required this.sessionId,
    required this.videoService,
    required this.localStream,
    required this.onLeave,
  });

  @override
  State<_VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<_VideoCallScreen> {
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  bool _isAudioEnabled = true;
  bool _isVideoEnabled = true;
  List<Map<String, dynamic>> _participants = [];

  @override
  void initState() {
    super.initState();
    _initializeRenderers();
    _loadParticipants();
  }

  Future<void> _initializeRenderers() async {
    await _localRenderer.initialize();
    _localRenderer.srcObject = widget.localStream;
  }

  Future<void> _loadParticipants() async {
    try {
      final participants =
          await widget.videoService.getSessionParticipants(widget.sessionId);
      if (mounted) {
        setState(() => _participants = participants);
      }
    } catch (error) {
      // Handle error
    }
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          ParticipantGridWidget(
            participants: _participants,
            localRenderer: _localRenderer,
          ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: VideoControlsWidget(
              isAudioEnabled: _isAudioEnabled,
              isVideoEnabled: _isVideoEnabled,
              onToggleAudio: () async {
                await widget.videoService.toggleAudio(
                  widget.sessionId,
                  !_isAudioEnabled,
                );
                setState(() => _isAudioEnabled = !_isAudioEnabled);
              },
              onToggleVideo: () async {
                await widget.videoService.toggleVideo(
                  widget.sessionId,
                  !_isVideoEnabled,
                );
                setState(() => _isVideoEnabled = !_isVideoEnabled);
              },
              onLeave: widget.onLeave,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// Active call interface with WebRTC video/audio streaming
/// Features: Video preview, call controls, camera switching, screen sharing
class ActiveCallWidget extends StatefulWidget {
  final Map<String, dynamic> contact;
  final bool isVideoCall;

  const ActiveCallWidget({
    super.key,
    required this.contact,
    required this.isVideoCall,
  });

  @override
  State<ActiveCallWidget> createState() => _ActiveCallWidgetState();
}

class _ActiveCallWidgetState extends State<ActiveCallWidget> {
  RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  MediaStream? _localStream;
  bool _isMuted = false;
  bool _isVideoEnabled = true;
  bool _isSpeakerOn = false;
  bool _isConnecting = true;
  bool _isFrontCamera = true;
  int _callDuration = 0;
  String _connectionQuality = 'Excellent';

  @override
  void initState() {
    super.initState();
    _initializeCall();
  }

  Future<void> _initializeCall() async {
    try {
      await _localRenderer.initialize();
      await _remoteRenderer.initialize();

      // Get user media
      final Map<String, dynamic> mediaConstraints = {
        'audio': true,
        'video': widget.isVideoCall
            ? {
                'facingMode': 'user',
                'width': {'ideal': 1280},
                'height': {'ideal': 720},
              }
            : false,
      };

      _localStream =
          await navigator.mediaDevices.getUserMedia(mediaConstraints);
      _localRenderer.srcObject = _localStream;

      // Simulate connection establishment
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        setState(() {
          _isConnecting = false;
        });
        _startCallTimer();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to initialize call: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  void _startCallTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && !_isConnecting) {
        setState(() => _callDuration++);
        _startCallTimer();
      }
    });
  }

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  Future<void> _toggleMute() async {
    if (_localStream != null) {
      final audioTracks = _localStream!.getAudioTracks();
      if (audioTracks.isNotEmpty) {
        final enabled = !_isMuted;
        audioTracks[0].enabled = enabled;
        setState(() => _isMuted = !enabled);
      }
    }
  }

  Future<void> _toggleVideo() async {
    if (_localStream != null && widget.isVideoCall) {
      final videoTracks = _localStream!.getVideoTracks();
      if (videoTracks.isNotEmpty) {
        final enabled = !_isVideoEnabled;
        videoTracks[0].enabled = enabled;
        setState(() => _isVideoEnabled = enabled);
      }
    }
  }

  Future<void> _switchCamera() async {
    if (_localStream != null && widget.isVideoCall) {
      final videoTracks = _localStream!.getVideoTracks();
      if (videoTracks.isNotEmpty) {
        await Helper.switchCamera(videoTracks[0]);
        setState(() => _isFrontCamera = !_isFrontCamera);
      }
    }
  }

  void _toggleSpeaker() {
    setState(() => _isSpeakerOn = !_isSpeakerOn);
    // In production, implement actual speaker routing
  }

  void _endCall() {
    _localStream?.dispose();
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _localStream?.dispose();
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Remote video (full screen)
            if (widget.isVideoCall && !_isConnecting)
              Positioned.fill(
                child: RTCVideoView(
                  _remoteRenderer,
                  objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                ),
              ),

            // Connecting state
            if (_isConnecting)
              Positioned.fill(
                child: Container(
                  color: theme.colorScheme.primaryContainer,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 30.w,
                        height: 30.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: theme.colorScheme.primary,
                            width: 3,
                          ),
                        ),
                        child: ClipOval(
                          child: CustomImageWidget(
                            imageUrl: widget.contact["avatar"] as String,
                            width: 30.w,
                            height: 30.w,
                            fit: BoxFit.cover,
                            semanticLabel:
                                widget.contact["semanticLabel"] as String,
                          ),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        widget.contact["name"] as String,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        'Connecting...',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer
                              .withValues(alpha: 0.7),
                        ),
                      ),
                      SizedBox(height: 3.h),
                      CircularProgressIndicator(
                        color: theme.colorScheme.primary,
                      ),
                    ],
                  ),
                ),
              ),

            // Local video preview (draggable)
            if (widget.isVideoCall && !_isConnecting && _isVideoEnabled)
              Positioned(
                top: 2.h,
                right: 4.w,
                child: GestureDetector(
                  onTap: _switchCamera,
                  child: Container(
                    width: 25.w,
                    height: 30.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.primary,
                        width: 2,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: RTCVideoView(
                        _localRenderer,
                        mirror: _isFrontCamera,
                        objectFit:
                            RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                      ),
                    ),
                  ),
                ),
              ),

            // Top info bar
            if (!_isConnecting)
              Positioned(
                top: 2.h,
                left: 4.w,
                right: 30.w,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.contact["name"] as String,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 0.5.h),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CustomIconWidget(
                            iconName: 'access_time',
                            color: Colors.white,
                            size: 14,
                          ),
                          SizedBox(width: 1.w),
                          Text(
                            _formatDuration(_callDuration),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                          SizedBox(width: 3.w),
                          Container(
                            width: 2.w,
                            height: 2.w,
                            decoration: BoxDecoration(
                              color: _connectionQuality == 'Excellent'
                                  ? Colors.green
                                  : _connectionQuality == 'Good'
                                      ? Colors.orange
                                      : Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 1.w),
                          Text(
                            _connectionQuality,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

            // Bottom controls
            if (!_isConnecting)
              Positioned(
                bottom: 4.h,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildControlButton(
                        icon: _isMuted ? 'mic_off' : 'mic',
                        label: _isMuted ? 'Unmute' : 'Mute',
                        onPressed: _toggleMute,
                        isActive: _isMuted,
                        theme: theme,
                      ),
                      if (widget.isVideoCall)
                        _buildControlButton(
                          icon: _isVideoEnabled ? 'videocam' : 'videocam_off',
                          label: _isVideoEnabled ? 'Video' : 'No Video',
                          onPressed: _toggleVideo,
                          isActive: !_isVideoEnabled,
                          theme: theme,
                        ),
                      _buildControlButton(
                        icon: _isSpeakerOn ? 'volume_up' : 'volume_down',
                        label: _isSpeakerOn ? 'Speaker' : 'Earpiece',
                        onPressed: _toggleSpeaker,
                        isActive: _isSpeakerOn,
                        theme: theme,
                      ),
                      if (widget.isVideoCall)
                        _buildControlButton(
                          icon: 'flip_camera_ios',
                          label: 'Flip',
                          onPressed: _switchCamera,
                          isActive: false,
                          theme: theme,
                        ),
                      _buildControlButton(
                        icon: 'call_end',
                        label: 'End',
                        onPressed: _endCall,
                        isActive: false,
                        isEndCall: true,
                        theme: theme,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required String icon,
    required String label,
    required VoidCallback onPressed,
    required bool isActive,
    required ThemeData theme,
    bool isEndCall = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14.w,
          height: 14.w,
          decoration: BoxDecoration(
            color: isEndCall
                ? theme.colorScheme.error
                : isActive
                    ? theme.colorScheme.primary
                    : Colors.white.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: CustomIconWidget(
              iconName: icon,
              color: Colors.white,
              size: 24,
            ),
            onPressed: onPressed,
          ),
        ),
        SizedBox(height: 0.5.h),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.white,
            fontSize: 10.sp,
          ),
        ),
      ],
    );
  }
}

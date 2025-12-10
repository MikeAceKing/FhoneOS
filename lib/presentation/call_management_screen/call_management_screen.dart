import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/call_controls_widget.dart';
import './widgets/call_info_widget.dart';
import './widgets/call_waiting_widget.dart';
import './widgets/multi_call_manager_widget.dart';
import './widgets/network_quality_indicator_widget.dart';
import './widgets/video_renderer_widget.dart';

/// Call Management Screen
/// Comprehensive call control interface for voice and video sessions with advanced features
class CallManagementScreen extends StatefulWidget {
  const CallManagementScreen({super.key});

  @override
  State<CallManagementScreen> createState() => _CallManagementScreenState();
}

class _CallManagementScreenState extends State<CallManagementScreen> {
  // WebRTC components
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  MediaStream? _remoteStream;
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();

  // Call state
  bool _isMuted = false;
  bool _isSpeakerOn = false;
  bool _isOnHold = false;
  bool _isVideoCall = false;
  bool _isCameraOn = true;
  bool _isRecording = false;
  bool _hasIncomingCall = false;
  Duration _callDuration = Duration.zero;
  Timer? _callTimer;
  String _networkQuality = 'Excellent';
  int _connectionStrength = 100;

  // Contact info
  final String _contactName = 'John Doe';
  final String _contactNumber = '+1 234 567 8900';
  final String _contactAvatar =
      'https://images.pexels.com/photos/220453/pexels-photo-220453.jpeg';

  // Multi-call management
  final List<Map<String, dynamic>> _activeCalls = [];
  final List<Map<String, dynamic>> _waitingCalls = [];

  @override
  void initState() {
    super.initState();
    _initializeRenderers();
    _startCall();
  }

  Future<void> _initializeRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  Future<void> _startCall() async {
    _startCallTimer();
    await _setupWebRTC();
  }

  void _startCallTimer() {
    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _callDuration = Duration(seconds: _callDuration.inSeconds + 1);
        });
      }
    });
  }

  Future<void> _setupWebRTC() async {
    try {
      // Initialize WebRTC peer connection
      final Map<String, dynamic> configuration = {
        'iceServers': [
          {'urls': 'stun:stun.l.google.com:19302'},
        ]
      };

      _peerConnection = await createPeerConnection(configuration);

      // Get local media stream
      final Map<String, dynamic> mediaConstraints = {
        'audio': true,
        'video': _isVideoCall
            ? {
                'facingMode': 'user',
                'width': 1280,
                'height': 720,
              }
            : false,
      };

      _localStream =
          await navigator.mediaDevices.getUserMedia(mediaConstraints);
      _localRenderer.srcObject = _localStream;

      // Add tracks to peer connection
      _localStream?.getTracks().forEach((track) {
        _peerConnection?.addTrack(track, _localStream!);
      });

      // Listen for remote stream
      _peerConnection?.onTrack = (RTCTrackEvent event) {
        if (event.streams.isNotEmpty) {
          setState(() {
            _remoteStream = event.streams[0];
            _remoteRenderer.srcObject = _remoteStream;
          });
        }
      };

      // Monitor connection state
      _peerConnection?.onConnectionState = (RTCPeerConnectionState state) {
        _updateNetworkQuality(state);
      };

      setState(() {});
    } catch (e) {
      debugPrint('Error setting up WebRTC: $e');
    }
  }

  void _updateNetworkQuality(RTCPeerConnectionState state) {
    setState(() {
      switch (state) {
        case RTCPeerConnectionState.RTCPeerConnectionStateConnected:
          _networkQuality = 'Excellent';
          _connectionStrength = 100;
          break;
        case RTCPeerConnectionState.RTCPeerConnectionStateConnecting:
          _networkQuality = 'Good';
          _connectionStrength = 75;
          break;
        case RTCPeerConnectionState.RTCPeerConnectionStateDisconnected:
          _networkQuality = 'Poor';
          _connectionStrength = 25;
          break;
        case RTCPeerConnectionState.RTCPeerConnectionStateFailed:
          _networkQuality = 'Reconnecting';
          _connectionStrength = 0;
          break;
        default:
          _networkQuality = 'Good';
          _connectionStrength = 50;
      }
    });
  }

  void _toggleMute() {
    if (_localStream != null) {
      final audioTrack = _localStream!.getAudioTracks()[0];
      audioTrack.enabled = !audioTrack.enabled;
      setState(() {
        _isMuted = !_isMuted;
      });
    }
  }

  void _toggleSpeaker() {
    setState(() {
      _isSpeakerOn = !_isSpeakerOn;
    });
  }

  void _toggleHold() {
    setState(() {
      _isOnHold = !_isOnHold;
    });
    if (_isOnHold) {
      _localStream?.getAudioTracks().forEach((track) {
        track.enabled = false;
      });
    } else {
      _localStream?.getAudioTracks().forEach((track) {
        track.enabled = !_isMuted;
      });
    }
  }

  void _toggleVideo() {
    if (_isVideoCall && _localStream != null) {
      final videoTrack = _localStream!.getVideoTracks()[0];
      videoTrack.enabled = !videoTrack.enabled;
      setState(() {
        _isCameraOn = !_isCameraOn;
      });
    }
  }

  void _toggleRecording() {
    setState(() {
      _isRecording = !_isRecording;
    });
  }

  void _switchCamera() async {
    if (_isVideoCall && _localStream != null) {
      _localStream!.getVideoTracks()[0].switchCamera();
    }
  }

  void _endCall() {
    _callTimer?.cancel();
    _localStream?.dispose();
    _remoteStream?.dispose();
    _peerConnection?.close();
    Navigator.pop(context);
  }

  void _handleTransfer() {
    // Show transfer dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Transfer Call'),
        content: const Text('Call transfer feature coming soon'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return hours == '00' ? '$minutes:$seconds' : '$hours:$minutes:$seconds';
  }

  @override
  void dispose() {
    _callTimer?.cancel();
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    _localStream?.dispose();
    _remoteStream?.dispose();
    _peerConnection?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0D0D1E) : const Color(0xFF1A1A2E),
      body: SafeArea(
        child: Stack(
          children: [
            // Background gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    isDark ? const Color(0xFF0D0D1E) : const Color(0xFF1A1A2E),
                    isDark ? const Color(0xFF1A1A2E) : const Color(0xFF16213E),
                  ],
                ),
              ),
            ),

            // Video renderers
            if (_isVideoCall) ...[
              // Remote video (full screen)
              Positioned.fill(
                child: VideoRendererWidget(
                  renderer: _remoteRenderer,
                  isMirrored: false,
                ),
              ),

              // Local video (picture-in-picture)
              Positioned(
                top: 16.h,
                right: 16.w,
                child: Container(
                  width: 120.w,
                  height: 160.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: VideoRendererWidget(
                      renderer: _localRenderer,
                      isMirrored: true,
                    ),
                  ),
                ),
              ),
            ],

            // Call info overlay
            Positioned(
              top: 16.h,
              left: 16.w,
              right: _isVideoCall ? 150.w : 16.w,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CallInfoWidget(
                    contactName: _contactName,
                    contactNumber: _contactNumber,
                    contactAvatar: _contactAvatar,
                    callDuration: _formatDuration(_callDuration),
                    isOnHold: _isOnHold,
                  ),
                  SizedBox(height: 8.h),
                  NetworkQualityIndicatorWidget(
                    quality: _networkQuality,
                    strength: _connectionStrength,
                  ),
                ],
              ),
            ),

            // Recording indicator
            if (_isRecording)
              Positioned(
                top: 100.h,
                left: 16.w,
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.fiber_manual_record,
                        color: Colors.white,
                        size: 12.h,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        'Recording',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 12.h,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Call waiting notification
            if (_hasIncomingCall)
              Positioned(
                top: 140.h,
                left: 16.w,
                right: 16.w,
                child: CallWaitingWidget(
                  onAccept: () {
                    setState(() => _hasIncomingCall = false);
                  },
                  onDecline: () {
                    setState(() => _hasIncomingCall = false);
                  },
                ),
              ),

            // Multi-call manager
            if (_activeCalls.isNotEmpty)
              Positioned(
                top: 200.h,
                right: 16.w,
                child: MultiCallManagerWidget(
                  activeCalls: _activeCalls,
                  onSwitchCall: (index) {},
                ),
              ),

            // Call controls
            Positioned(
              bottom: 40.h,
              left: 0,
              right: 0,
              child: CallControlsWidget(
                isMuted: _isMuted,
                isSpeakerOn: _isSpeakerOn,
                isOnHold: _isOnHold,
                isVideoCall: _isVideoCall,
                isCameraOn: _isCameraOn,
                isRecording: _isRecording,
                onMuteToggle: _toggleMute,
                onSpeakerToggle: _toggleSpeaker,
                onHoldToggle: _toggleHold,
                onVideoToggle: _toggleVideo,
                onRecordToggle: _toggleRecording,
                onSwitchCamera: _switchCamera,
                onEndCall: _endCall,
                onTransfer: _handleTransfer,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
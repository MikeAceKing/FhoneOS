import 'dart:async';
import 'package:flutter/material.dart';
import '../../../models/call.dart';
import '../../../services/call_service.dart';

class ActiveCallControlsWidget extends StatefulWidget {
  final Call call;
  final VoidCallback onCallEnded;

  const ActiveCallControlsWidget({
    super.key,
    required this.call,
    required this.onCallEnded,
  });

  @override
  State<ActiveCallControlsWidget> createState() =>
      _ActiveCallControlsWidgetState();
}

class _ActiveCallControlsWidgetState extends State<ActiveCallControlsWidget> {
  final _callService = CallService();
  late Timer _timer;
  int _durationSeconds = 0;

  bool _isMuted = false;
  bool _isSpeakerOn = false;
  bool _isOnHold = false;

  @override
  void initState() {
    super.initState();
    _startCallTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startCallTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _durationSeconds++);
    });
  }

  Future<void> _endCall() async {
    _timer.cancel();

    try {
      await _callService.endCall(widget.call.id, _durationSeconds);
      widget.onCallEnded();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to end call: $e')),
        );
      }
    }
  }

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final phoneNumber = widget.call.callType == CallType.incoming
        ? widget.call.fromNumber
        : widget.call.toNumber;

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 60),

            // Call status
            Text(
              widget.call.callStatus == CallStatus.ringing
                  ? 'Ringing...'
                  : 'Call in progress',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 20),

            // Caller info
            CircleAvatar(
              radius: 60,
              backgroundColor: const Color(0xFF4CAF50),
              child: Text(
                phoneNumber.substring(0, 1),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: 24),

            Text(
              phoneNumber,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 12),

            // Call duration
            Text(
              _formatDuration(_durationSeconds),
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 18,
              ),
            ),

            const Spacer(),

            // Call controls
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildControlButton(
                        icon: _isMuted ? Icons.mic_off : Icons.mic,
                        label: 'Mute',
                        isActive: _isMuted,
                        onTap: () => setState(() => _isMuted = !_isMuted),
                      ),
                      _buildControlButton(
                        icon: Icons.dialpad,
                        label: 'Keypad',
                        onTap: () {},
                      ),
                      _buildControlButton(
                        icon: _isSpeakerOn ? Icons.volume_up : Icons.volume_off,
                        label: 'Speaker',
                        isActive: _isSpeakerOn,
                        onTap: () =>
                            setState(() => _isSpeakerOn = !_isSpeakerOn),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildControlButton(
                        icon: Icons.add_call,
                        label: 'Add call',
                        onTap: () {},
                      ),
                      _buildControlButton(
                        icon: Icons.videocam,
                        label: 'Video',
                        onTap: () {},
                      ),
                      _buildControlButton(
                        icon: _isOnHold ? Icons.play_arrow : Icons.pause,
                        label: 'Hold',
                        isActive: _isOnHold,
                        onTap: () => setState(() => _isOnHold = !_isOnHold),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 60),

            // End call button
            FloatingActionButton.extended(
              backgroundColor: Colors.red,
              onPressed: _endCall,
              icon: const Icon(Icons.call_end, color: Colors.white),
              label: const Text(
                'End Call',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    bool isActive = false,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(30),
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: isActive
                  ? const Color(0xFF4CAF50)
                  : Colors.white.withAlpha(51),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// Call Controls Widget
/// Primary control buttons for call management with Material Design 3 styling
class CallControlsWidget extends StatelessWidget {
  final bool isMuted;
  final bool isSpeakerOn;
  final bool isOnHold;
  final bool isVideoCall;
  final bool isCameraOn;
  final bool isRecording;
  final VoidCallback onMuteToggle;
  final VoidCallback onSpeakerToggle;
  final VoidCallback onHoldToggle;
  final VoidCallback onVideoToggle;
  final VoidCallback onRecordToggle;
  final VoidCallback onSwitchCamera;
  final VoidCallback onEndCall;
  final VoidCallback onTransfer;

  const CallControlsWidget({
    super.key,
    required this.isMuted,
    required this.isSpeakerOn,
    required this.isOnHold,
    required this.isVideoCall,
    required this.isCameraOn,
    required this.isRecording,
    required this.onMuteToggle,
    required this.onSpeakerToggle,
    required this.onHoldToggle,
    required this.onVideoToggle,
    required this.onRecordToggle,
    required this.onSwitchCamera,
    required this.onEndCall,
    required this.onTransfer,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0),
            Colors.black.withValues(alpha: 0.7),
            Colors.black.withValues(alpha: 0.9),
          ],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Primary controls row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildControlButton(
                icon: isMuted ? Icons.mic_off : Icons.mic,
                label: 'Mute',
                isActive: isMuted,
                onPressed: onMuteToggle,
              ),
              _buildControlButton(
                icon: isSpeakerOn ? Icons.volume_up : Icons.volume_down,
                label: 'Speaker',
                isActive: isSpeakerOn,
                onPressed: onSpeakerToggle,
              ),
              _buildControlButton(
                icon: isOnHold ? Icons.play_arrow : Icons.pause,
                label: 'Hold',
                isActive: isOnHold,
                onPressed: onHoldToggle,
              ),
              if (isVideoCall)
                _buildControlButton(
                  icon: isCameraOn ? Icons.videocam : Icons.videocam_off,
                  label: 'Video',
                  isActive: !isCameraOn,
                  onPressed: onVideoToggle,
                ),
            ],
          ),

          SizedBox(height: 16.h),

          // Secondary controls row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildControlButton(
                icon:
                    isRecording ? Icons.stop_circle : Icons.fiber_manual_record,
                label: 'Record',
                isActive: isRecording,
                onPressed: onRecordToggle,
                color: isRecording ? Colors.red : null,
              ),
              if (isVideoCall)
                _buildControlButton(
                  icon: Icons.flip_camera_ios,
                  label: 'Switch',
                  onPressed: onSwitchCamera,
                ),
              _buildControlButton(
                icon: Icons.phone_forwarded,
                label: 'Transfer',
                onPressed: onTransfer,
              ),
              _buildControlButton(
                icon: Icons.dialpad,
                label: 'Keypad',
                onPressed: () {},
              ),
            ],
          ),

          SizedBox(height: 24.h),

          // End call button
          GestureDetector(
            onTap: onEndCall,
            child: Container(
              height: 60.h,
              width: 60.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red,
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withValues(alpha: 0.4),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(
                Icons.call_end,
                color: Colors.white,
                size: 32.h,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    bool isActive = false,
    VoidCallback? onPressed,
    Color? color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onPressed,
          child: Container(
            height: 56.h,
            width: 56.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive
                  ? (color ?? Colors.white.withValues(alpha: 0.3))
                  : Colors.white.withValues(alpha: 0.15),
              border: Border.all(
                color: isActive
                    ? Colors.white.withValues(alpha: 0.5)
                    : Colors.white.withValues(alpha: 0.2),
                width: 1.5,
              ),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24.h,
            ),
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          label,
          style: GoogleFonts.inter(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: 11.h,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

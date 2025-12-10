import 'package:flutter/material.dart';

class VideoControlsWidget extends StatelessWidget {
  final bool isAudioEnabled;
  final bool isVideoEnabled;
  final VoidCallback onToggleAudio;
  final VoidCallback onToggleVideo;
  final VoidCallback onLeave;

  const VideoControlsWidget({
    Key? key,
    required this.isAudioEnabled,
    required this.isVideoEnabled,
    required this.onToggleAudio,
    required this.onToggleVideo,
    required this.onLeave,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildControlButton(
            icon: isAudioEnabled ? Icons.mic : Icons.mic_off,
            label: isAudioEnabled ? 'Mute' : 'Unmute',
            color: isAudioEnabled ? Colors.white : Colors.red,
            onPressed: onToggleAudio,
          ),
          _buildControlButton(
            icon: isVideoEnabled ? Icons.videocam : Icons.videocam_off,
            label: isVideoEnabled ? 'Stop Video' : 'Start Video',
            color: isVideoEnabled ? Colors.white : Colors.red,
            onPressed: onToggleVideo,
          ),
          _buildControlButton(
            icon: Icons.call_end,
            label: 'Leave',
            color: Colors.red,
            onPressed: onLeave,
            isPrimary: true,
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
    bool isPrimary = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          onPressed: onPressed,
          backgroundColor: isPrimary ? color : Colors.grey[800],
          child: Icon(icon, color: Colors.white),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

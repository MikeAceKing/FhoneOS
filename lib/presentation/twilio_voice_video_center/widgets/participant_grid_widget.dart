import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class ParticipantGridWidget extends StatelessWidget {
  final List<Map<String, dynamic>> participants;
  final RTCVideoRenderer localRenderer;

  const ParticipantGridWidget({
    Key? key,
    required this.participants,
    required this.localRenderer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final totalParticipants = participants.length + 1; // +1 for local user

    if (totalParticipants == 1) {
      return _buildFullScreenVideo();
    } else if (totalParticipants == 2) {
      return _buildTwoParticipantLayout();
    } else {
      return _buildGridLayout();
    }
  }

  Widget _buildFullScreenVideo() {
    return Stack(
      children: [
        RTCVideoView(localRenderer, mirror: true),
        Positioned(
          bottom: 80,
          right: 16,
          child: Container(
            width: 100,
            height: 150,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: RTCVideoView(localRenderer, mirror: true),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTwoParticipantLayout() {
    return Column(
      children: [
        Expanded(
          child: _buildParticipantTile(participants[0]),
        ),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: RTCVideoView(localRenderer, mirror: true),
          ),
        ),
      ],
    );
  }

  Widget _buildGridLayout() {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: totalParticipants <= 4 ? 2 : 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 9 / 16,
      ),
      itemCount: totalParticipants,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: RTCVideoView(localRenderer, mirror: true),
            ),
          );
        }
        return _buildParticipantTile(participants[index - 1]);
      },
    );
  }

  Widget _buildParticipantTile(Map<String, dynamic> participant) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        border: Border.all(color: Colors.white, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          if (participant['is_video_enabled'] == true)
            Container(
              color: Colors.black,
              child: const Center(
                child: Text(
                  'Video Stream',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            )
          else
            Center(
              child: CircleAvatar(
                radius: 40,
                backgroundColor: Colors.grey[700],
                child: Text(
                  (participant['display_name'] as String)[0].toUpperCase(),
                  style: const TextStyle(fontSize: 32, color: Colors.white),
                ),
              ),
            ),
          Positioned(
            bottom: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    participant['is_audio_enabled'] == true
                        ? Icons.mic
                        : Icons.mic_off,
                    size: 16,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    participant['display_name'] as String,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  int get totalParticipants => participants.length + 1;
}

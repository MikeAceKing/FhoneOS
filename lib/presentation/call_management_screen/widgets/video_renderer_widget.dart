import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

/// Video Renderer Widget
/// Displays WebRTC video stream with proper scaling and mirroring options
class VideoRendererWidget extends StatelessWidget {
  final RTCVideoRenderer renderer;
  final bool isMirrored;

  const VideoRendererWidget({
    super.key,
    required this.renderer,
    this.isMirrored = false,
  });

  @override
  Widget build(BuildContext context) {
    return Transform(
      alignment: Alignment.center,
      transform: isMirrored
          ? (Matrix4.identity()..scale(-1.0, 1.0, 1.0))
          : Matrix4.identity(),
      child: RTCVideoView(
        renderer,
        objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
        mirror: false,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../camera_interface.dart';

/// Capture button widget
/// Large button for photo capture and video recording
class CaptureButtonWidget extends StatelessWidget {
  final CaptureMode captureMode;
  final bool isRecording;
  final VoidCallback onCapture;
  final VoidCallback onStartRecording;
  final VoidCallback onStopRecording;
  final AnimationController recordingAnimation;

  const CaptureButtonWidget({
    super.key,
    required this.captureMode,
    required this.isRecording,
    required this.onCapture,
    required this.onStartRecording,
    required this.onStopRecording,
    required this.recordingAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: captureMode == CaptureMode.photo ? onCapture : null,
      onLongPressStart: captureMode == CaptureMode.video && !isRecording
          ? (_) => onStartRecording()
          : null,
      onLongPressEnd: captureMode == CaptureMode.video && isRecording
          ? (_) => onStopRecording()
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white,
            width: 4,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: AnimatedBuilder(
            animation: recordingAnimation,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  color: isRecording
                      ? Colors.red.withValues(
                          alpha: 0.7 + (recordingAnimation.value * 0.3),
                        )
                      : Colors.white,
                  shape: isRecording ? BoxShape.rectangle : BoxShape.circle,
                  borderRadius: isRecording ? BorderRadius.circular(8) : null,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

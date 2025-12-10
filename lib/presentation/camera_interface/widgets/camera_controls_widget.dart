import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Top camera controls widget
/// Displays flash, camera switch, grid, and QR scanner controls
class CameraControlsWidget extends StatelessWidget {
  final FlashMode flashMode;
  final VoidCallback onFlashToggle;
  final VoidCallback onSwitchCamera;
  final VoidCallback onToggleGrid;
  final VoidCallback onToggleQRScanner;
  final bool showGrid;
  final bool showQRScanner;
  final bool isWeb;

  const CameraControlsWidget({
    super.key,
    required this.flashMode,
    required this.onFlashToggle,
    required this.onSwitchCamera,
    required this.onToggleGrid,
    required this.onToggleQRScanner,
    required this.showGrid,
    required this.showQRScanner,
    required this.isWeb,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.6),
            Colors.transparent,
          ],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Flash control (not available on web)
          if (!isWeb)
            _buildControlButton(
              icon: _getFlashIcon(),
              onTap: onFlashToggle,
              isActive: flashMode != FlashMode.off,
            )
          else
            const SizedBox(width: 48),

          // Grid toggle
          _buildControlButton(
            icon: 'grid_on',
            onTap: onToggleGrid,
            isActive: showGrid,
          ),

          // QR Scanner toggle
          _buildControlButton(
            icon: 'qr_code_scanner',
            onTap: onToggleQRScanner,
            isActive: showQRScanner,
          ),

          // Camera switch
          _buildControlButton(
            icon: 'flip_camera_ios',
            onTap: onSwitchCamera,
            isActive: false,
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required String icon,
    required VoidCallback onTap,
    required bool isActive,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isActive
              ? Colors.white.withValues(alpha: 0.3)
              : Colors.black.withValues(alpha: 0.3),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: CustomIconWidget(
            iconName: icon,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }

  String _getFlashIcon() {
    switch (flashMode) {
      case FlashMode.off:
        return 'flash_off';
      case FlashMode.auto:
        return 'flash_auto';
      case FlashMode.always:
        return 'flash_on';
      case FlashMode.torch:
        return 'flashlight_on';
    }
  }
}

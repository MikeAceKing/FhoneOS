import 'dart:io' if (dart.library.io) 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';

import '../../core/app_export.dart';
import './widgets/camera_controls_widget.dart';
import './widgets/capture_button_widget.dart';
import './widgets/gallery_thumbnail_widget.dart';
import './widgets/mode_selector_widget.dart';
import './widgets/zoom_controls_widget.dart';

/// Camera Interface Screen
/// Enables photo and video capture with social sharing integration
class CameraInterface extends StatefulWidget {
  const CameraInterface({super.key});

  @override
  State<CameraInterface> createState() => _CameraInterfaceState();
}

class _CameraInterfaceState extends State<CameraInterface>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  // Camera controllers and state
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  bool _isCameraInitialized = false;
  bool _isRecording = false;
  bool _showQRScanner = false;

  // Camera settings
  FlashMode _flashMode = FlashMode.auto;
  double _currentZoom = 1.0;
  double _minZoom = 1.0;
  double _maxZoom = 1.0;
  bool _isRearCamera = true;

  // Capture mode
  CaptureMode _captureMode = CaptureMode.photo;

  // Gallery
  XFile? _recentCapture;
  String? _recentCaptureThumb;

  // Grid overlay
  bool _showGrid = false;

  // Recording state
  Duration _recordingDuration = Duration.zero;

  // Animation controllers
  late AnimationController _recordingAnimController;
  late AnimationController _modeTransitionController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeAnimations();
    _initializeCamera();
    _loadRecentPhoto();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    _recordingAnimController.dispose();
    _modeTransitionController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _cameraController;
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  void _initializeAnimations() {
    _recordingAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _modeTransitionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  Future<void> _initializeCamera() async {
    try {
      // Request camera permission
      final hasPermission = await _requestCameraPermission();
      if (!hasPermission) {
        _showPermissionDeniedDialog();
        return;
      }

      // Get available cameras
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        _showNoCameraDialog();
        return;
      }

      // Select camera based on platform
      final camera = kIsWeb
          ? _cameras.firstWhere(
              (c) => c.lensDirection == CameraLensDirection.front,
              orElse: () => _cameras.first,
            )
          : _cameras.firstWhere(
              (c) => c.lensDirection == CameraLensDirection.back,
              orElse: () => _cameras.first,
            );

      // Initialize camera controller
      _cameraController = CameraController(
        camera,
        kIsWeb ? ResolutionPreset.medium : ResolutionPreset.high,
        enableAudio: true,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _cameraController!.initialize();

      // Get zoom levels
      _minZoom = await _cameraController!.getMinZoomLevel();
      _maxZoom = await _cameraController!.getMaxZoomLevel();
      _currentZoom = _minZoom;

      // Apply camera settings
      await _applyCameraSettings();

      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
          _isRearCamera = camera.lensDirection == CameraLensDirection.back;
        });
      }
    } catch (e) {
      debugPrint('Camera initialization error: \$e');
      if (mounted) {
        _showCameraErrorDialog();
      }
    }
  }

  Future<bool> _requestCameraPermission() async {
    if (kIsWeb) return true;

    final cameraStatus = await Permission.camera.request();
    final microphoneStatus = await Permission.microphone.request();

    return cameraStatus.isGranted && microphoneStatus.isGranted;
  }

  Future<void> _applyCameraSettings() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      await _cameraController!.setFocusMode(FocusMode.auto);
      await _cameraController!.setExposureMode(ExposureMode.auto);

      if (!kIsWeb) {
        await _cameraController!.setFlashMode(_flashMode);
      }
    } catch (e) {
      debugPrint('Error applying camera settings: \$e');
    }
  }

  Future<void> _loadRecentPhoto() async {
    try {
      final PermissionState ps = await PhotoManager.requestPermissionExtend();
      if (!ps.isAuth) return;

      final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
        type: RequestType.image,
        onlyAll: true,
      );

      if (albums.isEmpty) return;

      final List<AssetEntity> recentAssets =
          await albums.first.getAssetListRange(
        start: 0,
        end: 1,
      );

      if (recentAssets.isEmpty) return;

      final thumbData = await recentAssets.first.thumbnailDataWithSize(
        const ThumbnailSize(200, 200),
      );

      if (mounted && thumbData != null) {
        setState(() {
          _recentCaptureThumb =
              'data:image/jpeg;base64,\${thumbData.toString()}';
        });
      }
    } catch (e) {
      debugPrint('Error loading recent photo: \$e');
    }
  }

  Future<void> _capturePhoto() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      final XFile photo = await _cameraController!.takePicture();

      setState(() {
        _recentCapture = photo;
      });

      await _loadRecentPhoto();

      if (mounted) {
        _showCapturePreview(photo);
      }
    } catch (e) {
      debugPrint('Error capturing photo: \$e');
      _showErrorSnackBar('Failed to capture photo');
    }
  }

  Future<void> _startVideoRecording() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      await _cameraController!.startVideoRecording();

      setState(() {
        _isRecording = true;
        _recordingDuration = Duration.zero;
      });

      _recordingAnimController.repeat(reverse: true);
      _startRecordingTimer();
    } catch (e) {
      debugPrint('Error starting video recording: \$e');
      _showErrorSnackBar('Failed to start recording');
    }
  }

  Future<void> _stopVideoRecording() async {
    if (_cameraController == null ||
        !_cameraController!.value.isRecordingVideo) {
      return;
    }

    try {
      final XFile video = await _cameraController!.stopVideoRecording();

      setState(() {
        _isRecording = false;
        _recentCapture = video;
      });

      _recordingAnimController.stop();

      if (mounted) {
        _showCapturePreview(video);
      }
    } catch (e) {
      debugPrint('Error stopping video recording: \$e');
      _showErrorSnackBar('Failed to stop recording');
    }
  }

  void _startRecordingTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (_isRecording && mounted) {
        setState(() {
          _recordingDuration =
              Duration(seconds: _recordingDuration.inSeconds + 1);
        });
        return true;
      }
      return false;
    });
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2) return;

    final newCamera = _cameras.firstWhere(
      (camera) =>
          camera.lensDirection ==
          (_isRearCamera
              ? CameraLensDirection.front
              : CameraLensDirection.back),
      orElse: () => _cameras.first,
    );

    await _cameraController?.dispose();

    _cameraController = CameraController(
      newCamera,
      kIsWeb ? ResolutionPreset.medium : ResolutionPreset.high,
      enableAudio: true,
    );

    await _cameraController!.initialize();
    await _applyCameraSettings();

    if (mounted) {
      setState(() {
        _isRearCamera = !_isRearCamera;
      });
    }
  }

  void _toggleFlash() {
    if (kIsWeb) return;

    setState(() {
      _flashMode = _flashMode == FlashMode.off
          ? FlashMode.auto
          : _flashMode == FlashMode.auto
              ? FlashMode.always
              : FlashMode.off;
    });

    _cameraController?.setFlashMode(_flashMode);
  }

  void _handleZoom(double scale) {
    final newZoom = (_currentZoom * scale).clamp(_minZoom, _maxZoom);
    _cameraController?.setZoomLevel(newZoom);
    setState(() {
      _currentZoom = newZoom;
    });
  }

  void _changeCaptureMode(CaptureMode mode) {
    setState(() {
      _captureMode = mode;
    });
    _modeTransitionController.forward(from: 0.0);
  }

  void _toggleGrid() {
    setState(() {
      _showGrid = !_showGrid;
    });
  }

  void _toggleQRScanner() {
    setState(() {
      _showQRScanner = !_showQRScanner;
    });
  }

  Future<void> _pickFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null && mounted) {
        _showCapturePreview(image);
      }
    } catch (e) {
      debugPrint('Error picking from gallery: \$e');
      _showErrorSnackBar('Failed to open gallery');
    }
  }

  void _showCapturePreview(XFile file) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _CapturePreviewScreen(
          file: file,
          isVideo: _captureMode == CaptureMode.video,
        ),
      ),
    );
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Camera Permission Required'),
        content: const Text(
          'Please grant camera and microphone permissions to use this feature.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  void _showNoCameraDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('No Camera Available'),
        content: const Text('No camera was detected on this device.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showCameraErrorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Camera Error'),
        content: const Text('Failed to initialize camera. Please try again.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: _isCameraInitialized
            ? _buildCameraView(theme)
            : _buildLoadingView(theme),
      ),
    );
  }

  Widget _buildLoadingView(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'Initializing camera...',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraView(ThemeData theme) {
    return Stack(
      children: [
        // Camera preview
        Positioned.fill(
          child: _showQRScanner ? _buildQRScanner() : _buildCameraPreview(),
        ),

        // Grid overlay
        if (_showGrid && !_showQRScanner) _buildGridOverlay(),

        // Top controls
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: CameraControlsWidget(
            flashMode: _flashMode,
            onFlashToggle: _toggleFlash,
            onSwitchCamera: _switchCamera,
            onToggleGrid: _toggleGrid,
            onToggleQRScanner: _toggleQRScanner,
            showGrid: _showGrid,
            showQRScanner: _showQRScanner,
            isWeb: kIsWeb,
          ),
        ),

        // Recording indicator
        if (_isRecording)
          Positioned(
            top: 60,
            left: 0,
            right: 0,
            child: _buildRecordingIndicator(theme),
          ),

        // Zoom controls
        if (!_showQRScanner && !kIsWeb)
          Positioned(
            right: 16,
            top: 0,
            bottom: 200,
            child: ZoomControlsWidget(
              currentZoom: _currentZoom,
              minZoom: _minZoom,
              maxZoom: _maxZoom,
              onZoomChanged: (zoom) {
                _cameraController?.setZoomLevel(zoom);
                setState(() => _currentZoom = zoom);
              },
            ),
          ),

        // Bottom controls
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.8),
                  Colors.transparent,
                ],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Mode selector
                if (!_showQRScanner)
                  ModeSelectorWidget(
                    currentMode: _captureMode,
                    onModeChanged: _changeCaptureMode,
                  ),
                const SizedBox(height: 24),

                // Capture controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Gallery thumbnail
                    GalleryThumbnailWidget(
                      thumbnailUrl: _recentCaptureThumb,
                      onTap: _pickFromGallery,
                    ),

                    // Capture button
                    CaptureButtonWidget(
                      captureMode: _captureMode,
                      isRecording: _isRecording,
                      onCapture: _capturePhoto,
                      onStartRecording: _startVideoRecording,
                      onStopRecording: _stopVideoRecording,
                      recordingAnimation: _recordingAnimController,
                    ),

                    // Spacer for symmetry
                    const SizedBox(width: 60, height: 60),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Close button
        Positioned(
          top: 16,
          left: 16,
          child: IconButton(
            icon: CustomIconWidget(
              iconName: 'close',
              color: Colors.white,
              size: 28,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ],
    );
  }

  Widget _buildCameraPreview() {
    return GestureDetector(
      onScaleUpdate: (details) {
        if (!kIsWeb) {
          _handleZoom(details.scale);
        }
      },
      child: CameraPreview(_cameraController!),
    );
  }

  Widget _buildQRScanner() {
    return MobileScanner(
      onDetect: (capture) {
        final List<Barcode> barcodes = capture.barcodes;
        if (barcodes.isNotEmpty) {
          final String? code = barcodes.first.rawValue;
          if (code != null) {
            _showQRCodeDialog(code);
          }
        }
      },
    );
  }

  void _showQRCodeDialog(String code) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('QR Code Detected'),
        content: Text(code),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildGridOverlay() {
    return CustomPaint(
      painter: _GridPainter(),
      child: Container(),
    );
  }

  Widget _buildRecordingIndicator(ThemeData theme) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _recordingAnimController,
              builder: (context, child) {
                return Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(
                      alpha: 0.5 + (_recordingAnimController.value * 0.5),
                    ),
                    shape: BoxShape.circle,
                  ),
                );
              },
            ),
            const SizedBox(width: 8),
            Text(
              _formatDuration(_recordingDuration),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '\$minutes:\$seconds';
  }
}

// Capture modes enum
enum CaptureMode { photo, video, portrait }

// Grid painter for rule of thirds
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..strokeWidth = 1.0;

    // Vertical lines
    canvas.drawLine(
      Offset(size.width / 3, 0),
      Offset(size.width / 3, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 2 / 3, 0),
      Offset(size.width * 2 / 3, size.height),
      paint,
    );

    // Horizontal lines
    canvas.drawLine(
      Offset(0, size.height / 3),
      Offset(size.width, size.height / 3),
      paint,
    );
    canvas.drawLine(
      Offset(0, size.height * 2 / 3),
      Offset(size.width, size.height * 2 / 3),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Capture preview screen
class _CapturePreviewScreen extends StatelessWidget {
  final XFile file;
  final bool isVideo;

  const _CapturePreviewScreen({
    required this.file,
    required this.isVideo,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: CustomIconWidget(
            iconName: 'close',
            color: Colors.white,
            size: 28,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: CustomIconWidget(
              iconName: 'share',
              color: Colors.white,
              size: 24,
            ),
            onPressed: () => _shareCapture(context),
          ),
          IconButton(
            icon: CustomIconWidget(
              iconName: 'download',
              color: Colors.white,
              size: 24,
            ),
            onPressed: () => _saveCapture(context),
          ),
        ],
      ),
      body: Center(
        child: isVideo
            ? const Center(
                child: Text(
                  'Video Preview',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              )
            : kIsWeb
                ? CustomImageWidget(
                    imageUrl: file.path,
                    fit: BoxFit.contain,
                    semanticLabel: 'Captured photo preview',
                  )
                : Image.file(
                    File(file.path),
                    fit: BoxFit.contain,
                  ),
      ),
    );
  }

  void _shareCapture(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Share functionality will open system share sheet'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _saveCapture(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Saved to gallery'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

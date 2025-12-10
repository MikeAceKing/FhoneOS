import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// QR Scanner Widget
/// Scans eSIM activation QR codes from carriers
class QrScannerWidget extends StatefulWidget {
  final VoidCallback onClose;

  const QrScannerWidget({
    super.key,
    required this.onClose,
  });

  @override
  State<QrScannerWidget> createState() => _QrScannerWidgetState();
}

class _QrScannerWidgetState extends State<QrScannerWidget> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );
  bool _isProcessing = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onQrDetected(BarcodeCapture capture) async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final String? code = barcodes.first.rawValue;

      if (code != null && mounted) {
        // Show success dialog
        await showDialog(
          context: context,
          builder: (context) => _buildSuccessDialog(code),
        );

        widget.onClose();
      }
    }

    if (mounted) {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Widget _buildSuccessDialog(String code) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.check_circle, color: Color(0xFF00D4AA)),
          SizedBox(width: 12.w),
          Text(
            'QR Code Detected',
            style: GoogleFonts.inter(fontSize: 18.h),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'eSIM activation code found:',
            style: GoogleFonts.inter(fontSize: 14.h),
          ),
          SizedBox(height: 8.h),
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              code.length > 40 ? '${code.substring(0, 40)}...' : code,
              style: GoogleFonts.inter(
                fontSize: 12.h,
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            // Process eSIM activation
          },
          child: const Text('Activate'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      children: [
        // QR Scanner
        MobileScanner(
          controller: _controller,
          onDetect: _onQrDetected,
        ),

        // Overlay with instructions
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.7),
                Colors.transparent,
                Colors.transparent,
                Colors.black.withValues(alpha: 0.7),
              ],
              stops: const [0.0, 0.3, 0.7, 1.0],
            ),
          ),
        ),

        // Top instructions
        Positioned(
          top: 60.h,
          left: 0,
          right: 0,
          child: Column(
            children: [
              Text(
                'Scan eSIM QR Code',
                style: GoogleFonts.inter(
                  fontSize: 24.h,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Position the QR code within the frame',
                style: GoogleFonts.inter(
                  fontSize: 14.h,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),

        // Scanning frame
        Center(
          child: Container(
            width: 280.w,
            height: 280.h,
            decoration: BoxDecoration(
              border: Border.all(
                color: const Color(0xFF00D4AA),
                width: 3,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              children: [
                // Corner brackets
                _buildCornerBracket(Alignment.topLeft),
                _buildCornerBracket(Alignment.topRight),
                _buildCornerBracket(Alignment.bottomLeft),
                _buildCornerBracket(Alignment.bottomRight),
              ],
            ),
          ),
        ),

        // Close button
        Positioned(
          top: 40.h,
          right: 16.w,
          child: IconButton(
            onPressed: widget.onClose,
            icon: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close,
                color: Colors.white,
                size: 24.h,
              ),
            ),
          ),
        ),

        // Manual entry option
        Positioned(
          bottom: 80.h,
          left: 0,
          right: 0,
          child: Center(
            child: TextButton(
              onPressed: () {
                // Show manual entry dialog
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.black.withValues(alpha: 0.5),
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              ),
              child: Text(
                'Enter Code Manually',
                style: GoogleFonts.inter(
                  fontSize: 14.h,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),

        // Loading indicator
        if (_isProcessing)
          Container(
            color: Colors.black.withValues(alpha: 0.5),
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00D4AA)),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCornerBracket(Alignment alignment) {
    return Align(
      alignment: alignment,
      child: Container(
        width: 40.w,
        height: 40.h,
        decoration: BoxDecoration(
          border: Border(
            top: alignment == Alignment.topLeft ||
                    alignment == Alignment.topRight
                ? const BorderSide(color: Color(0xFF00D4AA), width: 4)
                : BorderSide.none,
            bottom: alignment == Alignment.bottomLeft ||
                    alignment == Alignment.bottomRight
                ? const BorderSide(color: Color(0xFF00D4AA), width: 4)
                : BorderSide.none,
            left: alignment == Alignment.topLeft ||
                    alignment == Alignment.bottomLeft
                ? const BorderSide(color: Color(0xFF00D4AA), width: 4)
                : BorderSide.none,
            right: alignment == Alignment.topRight ||
                    alignment == Alignment.bottomRight
                ? const BorderSide(color: Color(0xFF00D4AA), width: 4)
                : BorderSide.none,
          ),
        ),
      ),
    );
  }
}
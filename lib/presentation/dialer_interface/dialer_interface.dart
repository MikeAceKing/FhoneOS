import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/call_button_widget.dart';
import './widgets/dialpad_widget.dart';
import './widgets/recent_calls_widget.dart';

/// Dialer Interface Screen
/// Provides traditional phone dialing experience with WebRTC calling capabilities
class DialerInterface extends StatefulWidget {
  const DialerInterface({super.key});

  @override
  State<DialerInterface> createState() => _DialerInterfaceState();
}

class _DialerInterfaceState extends State<DialerInterface> {
  String _phoneNumber = '';
  bool _isCallActive = false;

  void _onDigitPressed(String digit) {
    setState(() {
      _phoneNumber += digit;
    });
  }

  void _onBackspacePressed() {
    if (_phoneNumber.isNotEmpty) {
      setState(() {
        _phoneNumber = _phoneNumber.substring(0, _phoneNumber.length - 1);
      });
    }
  }

  void _onCallPressed() async {
    if (_phoneNumber.isEmpty) return;

    setState(() {
      _isCallActive = true;
    });

    // WebRTC call will be handled here
    // For now, simulate call initiation
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isCallActive = false;
      });
    }
  }

  String _formatPhoneNumber(String number) {
    if (number.isEmpty) return 'Enter number';

    // Basic formatting for display
    if (number.length <= 3) return number;
    if (number.length <= 6) {
      return '${number.substring(0, 3)}-${number.substring(3)}';
    }
    return '${number.substring(0, 3)}-${number.substring(3, 6)}-${number.substring(6)}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Phone',
          style: GoogleFonts.inter(
            fontSize: 20.h,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
        backgroundColor: theme.appBarTheme.backgroundColor,
      ),
      body: Column(
        children: [
          // Phone number display
          Container(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
            child: Column(
              children: [
                Text(
                  _formatPhoneNumber(_phoneNumber),
                  style: GoogleFonts.inter(
                    fontSize: 32.h,
                    fontWeight: FontWeight.w400,
                    color: _phoneNumber.isEmpty
                        ? theme.textTheme.bodySmall?.color
                        : theme.textTheme.bodyLarge?.color,
                  ),
                ),
                if (_isCallActive) ...[
                  SizedBox(height: 16.h),
                  Text(
                    'Calling...',
                    style: GoogleFonts.inter(
                      fontSize: 14.h,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Dialpad
          Expanded(
            child: DialpadWidget(
              onDigitPressed: _onDigitPressed,
              onBackspacePressed: _onBackspacePressed,
            ),
          ),

          // Call button
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
            child: CallButtonWidget(
              onPressed: _onCallPressed,
              isEnabled: _phoneNumber.isNotEmpty && !_isCallActive,
              isLoading: _isCallActive,
            ),
          ),

          // Recent calls section
          Container(
            height: 200.h,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.sp)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: const RecentCallsWidget(),
          ),
        ],
      ),
    );
  }
}
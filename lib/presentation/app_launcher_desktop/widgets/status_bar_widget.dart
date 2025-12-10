import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Status bar widget displaying system information (time, battery, network)
class StatusBarWidget extends StatefulWidget {
  final VoidCallback onPullDown;

  const StatusBarWidget({
    super.key,
    required this.onPullDown,
  });

  @override
  State<StatusBarWidget> createState() => _StatusBarWidgetState();
}

class _StatusBarWidgetState extends State<StatusBarWidget> {
  late Timer _timer;
  String _currentTime = '';
  int _batteryLevel = 85;
  bool _isCharging = false;
  String _networkType = 'WiFi';
  int _signalStrength = 4;

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateTime());
    _initializeSystemInfo();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _updateTime() {
    final now = DateTime.now();
    setState(() {
      _currentTime =
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    });
  }

  void _initializeSystemInfo() {
    // Mock system information - in production, use platform channels
    setState(() {
      _batteryLevel = 85;
      _isCharging = false;
      _networkType = 'WiFi';
      _signalStrength = 4;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onVerticalDragEnd: (details) {
        if (details.primaryVelocity != null && details.primaryVelocity! > 0) {
          widget.onPullDown();
        }
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: SafeArea(
          bottom: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Time
              Text(
                _currentTime,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 14.sp,
                ),
              ),
              // System indicators
              Row(
                children: [
                  // Network indicator
                  _buildNetworkIndicator(theme),
                  SizedBox(width: 2.w),
                  // Battery indicator
                  _buildBatteryIndicator(theme),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNetworkIndicator(ThemeData theme) {
    return Row(
      children: [
        CustomIconWidget(
          iconName: _networkType == 'WiFi' ? 'wifi' : 'signal_cellular_alt',
          color: theme.colorScheme.onSurface,
          size: 16,
        ),
        SizedBox(width: 1.w),
        // Signal strength bars
        Row(
          children: List.generate(
            4,
            (index) => Container(
              margin: EdgeInsets.only(left: 0.5.w),
              width: 0.5.w,
              height: (index + 1) * 0.3.h,
              decoration: BoxDecoration(
                color: index < _signalStrength
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBatteryIndicator(ThemeData theme) {
    final batteryColor = _batteryLevel > 20
        ? theme.colorScheme.onSurface
        : theme.colorScheme.error;

    return Row(
      children: [
        // Battery icon
        Stack(
          alignment: Alignment.center,
          children: [
            CustomIconWidget(
              iconName: _isCharging ? 'battery_charging_full' : 'battery_std',
              color: batteryColor,
              size: 20,
            ),
          ],
        ),
        SizedBox(width: 1.w),
        // Battery percentage
        Text(
          '$_batteryLevel%',
          style: theme.textTheme.bodySmall?.copyWith(
            color: batteryColor,
            fontWeight: FontWeight.w500,
            fontSize: 11.sp,
          ),
        ),
      ],
    );
  }
}

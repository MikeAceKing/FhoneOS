import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Notification center widget displaying recent alerts and quick settings
class NotificationCenterWidget extends StatefulWidget {
  final bool isVisible;
  final VoidCallback onClose;

  const NotificationCenterWidget({
    super.key,
    required this.isVisible,
    required this.onClose,
  });

  @override
  State<NotificationCenterWidget> createState() =>
      _NotificationCenterWidgetState();
}

class _NotificationCenterWidgetState extends State<NotificationCenterWidget> {
  bool _wifiEnabled = true;
  bool _bluetoothEnabled = false;
  bool _airplaneModeEnabled = false;
  int _brightnessLevel = 70;

  final List<Map<String, dynamic>> _notifications = [
    {
      'title': 'New Message',
      'subtitle': 'Sarah: Hey, are you free for a call?',
      'time': '2 min ago',
      'icon': 'chat_bubble',
      'color': const Color(0xFF00D4AA),
      'avatar':
          'https://img.rocket.new/generatedImages/rocket_gen_img_176e07230-1763293461602.png',
      'semanticLabel':
          'Profile photo of a woman with long brown hair wearing a white top',
    },
    {
      'title': 'Video Call Missed',
      'subtitle': 'John tried to call you',
      'time': '15 min ago',
      'icon': 'videocam',
      'color': const Color(0xFFF5A623),
      'avatar':
          'https://img.rocket.new/generatedImages/rocket_gen_img_1137886c8-1763293866701.png',
      'semanticLabel':
          'Profile photo of a man with short dark hair wearing a blue shirt',
    },
    {
      'title': 'Social Hub',
      'subtitle': '3 new posts from your friends',
      'time': '1 hour ago',
      'icon': 'explore',
      'color': const Color(0xFF4A9EFF),
      'avatar':
          'https://images.unsplash.com/photo-1574809903713-20ca50005b71',
      'semanticLabel':
          'Profile photo of a woman with blonde hair wearing a black top',
    },
  ];

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible) return const SizedBox.shrink();

    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(maxHeight: 70.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            _buildHeader(theme),
            // Quick settings
            _buildQuickSettings(theme),
            const Divider(height: 1),
            // Notifications list
            Flexible(
              child: _buildNotificationsList(theme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Notifications',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          IconButton(
            icon: CustomIconWidget(
              iconName: 'close',
              color: theme.colorScheme.onSurface,
              size: 24,
            ),
            onPressed: widget.onClose,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickSettings(ThemeData theme) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Settings',
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 1.h),
          // Toggle buttons row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildQuickSettingButton(
                theme: theme,
                icon: 'wifi',
                label: 'WiFi',
                isEnabled: _wifiEnabled,
                onTap: () => setState(() => _wifiEnabled = !_wifiEnabled),
              ),
              _buildQuickSettingButton(
                theme: theme,
                icon: 'bluetooth',
                label: 'Bluetooth',
                isEnabled: _bluetoothEnabled,
                onTap: () =>
                    setState(() => _bluetoothEnabled = !_bluetoothEnabled),
              ),
              _buildQuickSettingButton(
                theme: theme,
                icon: 'airplanemode_active',
                label: 'Airplane',
                isEnabled: _airplaneModeEnabled,
                onTap: () => setState(
                    () => _airplaneModeEnabled = !_airplaneModeEnabled),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          // Brightness slider
          Row(
            children: [
              CustomIconWidget(
                iconName: 'brightness_low',
                color: theme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
              Expanded(
                child: Slider(
                  value: _brightnessLevel.toDouble(),
                  min: 0,
                  max: 100,
                  onChanged: (value) {
                    setState(() => _brightnessLevel = value.toInt());
                  },
                ),
              ),
              CustomIconWidget(
                iconName: 'brightness_high',
                color: theme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickSettingButton({
    required ThemeData theme,
    required String icon,
    required String label,
    required bool isEnabled,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 20.w,
        padding: EdgeInsets.symmetric(vertical: 1.5.h),
        decoration: BoxDecoration(
          color: isEnabled
              ? theme.colorScheme.primary.withValues(alpha: 0.2)
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            CustomIconWidget(
              iconName: icon,
              color: isEnabled
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
              size: 24,
            ),
            SizedBox(height: 0.5.h),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 10.sp,
                color: isEnabled
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsList(ThemeData theme) {
    return ListView.separated(
      shrinkWrap: true,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      itemCount: _notifications.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final notification = _notifications[index];
        return _buildNotificationItem(theme, notification);
      },
    );
  }

  Widget _buildNotificationItem(
      ThemeData theme, Map<String, dynamic> notification) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(vertical: 1.h),
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor:
                (notification['color'] as Color).withValues(alpha: 0.2),
            backgroundImage: notification['avatar'] != null
                ? NetworkImage(notification['avatar'] as String)
                : null,
            child: notification['avatar'] == null
                ? CustomIconWidget(
                    iconName: notification['icon'] as String,
                    color: notification['color'] as Color,
                    size: 24,
                  )
                : null,
          ),
          if (notification['avatar'] != null)
            Semantics(
              label: notification['semanticLabel'] as String,
              child: const SizedBox.shrink(),
            ),
        ],
      ),
      title: Text(
        notification['title'] as String,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        notification['subtitle'] as String,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        notification['time'] as String,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          fontSize: 10.sp,
        ),
      ),
    );
  }
}

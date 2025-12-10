import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/app_grid_widget.dart';
import './widgets/notification_center_widget.dart';
import './widgets/status_bar_widget.dart';

/// App Launcher Desktop - Primary home screen providing unified Cloud OS experience
/// with grid-based app access and system status monitoring
class AppLauncherDesktop extends StatefulWidget {
  const AppLauncherDesktop({super.key});

  @override
  State<AppLauncherDesktop> createState() => _AppLauncherDesktopState();
}

class _AppLauncherDesktopState extends State<AppLauncherDesktop>
    with SingleTickerProviderStateMixin {
  int _currentBottomNavIndex = 2; // Desktop is the 3rd tab (index 2)
  bool _showNotificationCenter = false;
  late AnimationController _notificationAnimationController;
  late Animation<Offset> _notificationSlideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _notificationAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _notificationSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _notificationAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _notificationAnimationController.dispose();
    super.dispose();
  }

  void _toggleNotificationCenter() {
    setState(() {
      _showNotificationCenter = !_showNotificationCenter;
      if (_showNotificationCenter) {
        _notificationAnimationController.forward();
      } else {
        _notificationAnimationController.reverse();
      }
    });
  }

  void _handleBottomNavTap(int index) {
    if (index == _currentBottomNavIndex) return;

    setState(() {
      _currentBottomNavIndex = index;
    });

    // Navigate to corresponding screen based on index
    switch (index) {
      case 0: // Social Hub
        Navigator.pushNamed(context, '/social-hub');
        break;
      case 1: // Messaging
        Navigator.pushNamed(context, '/messaging-interface');
        break;
      case 2: // Desktop (current screen)
        // Already on desktop, do nothing
        break;
      case 3: // Profile
        Navigator.pushNamed(context, '/user-profile-screen');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Main content area
          Column(
            children: [
              // Status bar
              StatusBarWidget(
                onPullDown: _toggleNotificationCenter,
              ),
              // App grid
              Expanded(
                child: AppGridWidget(
                  onAppTap: _handleAppTap,
                  onAppLongPress: _handleAppLongPress,
                ),
              ),
            ],
          ),
          // Notification center overlay
          if (_showNotificationCenter)
            GestureDetector(
              onTap: _toggleNotificationCenter,
              child: Container(
                color: Colors.black.withValues(alpha: 0.5),
              ),
            ),
          // Notification center panel
          SlideTransition(
            position: _notificationSlideAnimation,
            child: NotificationCenterWidget(
              isVisible: _showNotificationCenter,
              onClose: _toggleNotificationCenter,
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: _currentBottomNavIndex,
        onTap: _handleBottomNavTap,
        items: const [
          CustomBottomBarItem(
            label: 'Social',
            icon: Icons.explore_outlined,
            activeIcon: Icons.explore,
            route: '/social-hub',
          ),
          CustomBottomBarItem(
            label: 'Messages',
            icon: Icons.chat_bubble_outline,
            activeIcon: Icons.chat_bubble,
            route: '/messaging-interface',
          ),
          CustomBottomBarItem(
            label: 'Desktop',
            icon: Icons.apps_outlined,
            activeIcon: Icons.apps,
            route: '/app-launcher-desktop',
          ),
          CustomBottomBarItem(
            label: 'Profile',
            icon: Icons.person_outline,
            activeIcon: Icons.person,
            route: '/user-profile-screen',
          ),
        ],
      ),
    );
  }

  void _handleAppTap(String appRoute) {
    Navigator.pushNamed(context, appRoute);
  }

  void _handleAppLongPress(String appName, String appRoute) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildAppContextMenu(appName, appRoute),
    );
  }

  Widget _buildAppContextMenu(String appName, String appRoute) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: EdgeInsets.symmetric(vertical: 1.h),
              width: 10.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color:
                    theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // App name
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
              child: Text(
                appName,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Divider(height: 1),
            // Menu options
            ListTile(
              leading: CustomIconWidget(
                iconName: 'open_in_new',
                color: theme.colorScheme.primary,
                size: 24,
              ),
              title: Text(
                'Open',
                style: theme.textTheme.bodyLarge,
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, appRoute);
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'info_outline',
                color: theme.colorScheme.onSurfaceVariant,
                size: 24,
              ),
              title: Text(
                'App Info',
                style: theme.textTheme.bodyLarge,
              ),
              onTap: () {
                Navigator.pop(context);
                _showAppInfo(appName);
              },
            ),
            SizedBox(height: 1.h),
          ],
        ),
      ),
    );
  }

  void _showAppInfo(String appName) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Text(
          'App Info',
          style: theme.textTheme.titleLarge,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Name: $appName',
              style: theme.textTheme.bodyMedium,
            ),
            SizedBox(height: 1.h),
            Text(
              'Version: 1.0.0',
              style: theme.textTheme.bodyMedium,
            ),
            SizedBox(height: 1.h),
            Text(
              'Last Updated: December 10, 2025',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../widgets/custom_icon_widget.dart';

/// Enhanced App Launcher Desktop with corrected app names and proper Social Hub integration
class EnhancedAppLauncherDesktop extends StatefulWidget {
  const EnhancedAppLauncherDesktop({super.key});

  @override
  State<EnhancedAppLauncherDesktop> createState() =>
      _EnhancedAppLauncherDesktopState();
}

class _EnhancedAppLauncherDesktopState
    extends State<EnhancedAppLauncherDesktop> {
  int _currentBottomNavIndex = 2;
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<List<Map<String, dynamic>>> _appPages = [
    [
      {
        'name': 'SMS',
        'icon': Icons.chat_bubble,
        'route': '/production-sms-messaging-hub',
        'color': const Color(0xFF00D4AA),
        'badge': 3,
      },
      {
        'name': 'Calls',
        'icon': Icons.phone,
        'route': '/real-time-call-management-center',
        'color': const Color(0xFF4A9EFF),
        'badge': 2,
      },
      {
        'name': 'Social Hub',
        'icon': Icons.groups,
        'route': '/unified-social-inbox-hub',
        'color': const Color(0xFFF5A623),
        'badge': 8,
      },
      {
        'name': 'Notifications',
        'icon': Icons.notifications,
        'route': '/notifications-screen',
        'color': const Color(0xFFFF4757),
        'badge': 5,
      },
      {
        'name': 'Backups',
        'icon': Icons.backup,
        'route': '/cross-device-sync-backup-manager',
        'color': const Color(0xFF666677),
        'badge': 0,
      },
      {
        'name': 'Numbers',
        'icon': Icons.dialpad,
        'route': '/number-management-dashboard',
        'color': const Color(0xFF4A9EFF),
        'badge': 0,
      },
      {
        'name': 'AI Helper',
        'icon': Icons.smart_toy,
        'route': '/ai-assistant-chat',
        'color': const Color(0xFFF5A623),
        'badge': 0,
      },
    ],
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _handleBottomNavTap(int index) {
    if (index == _currentBottomNavIndex) return;

    setState(() {
      _currentBottomNavIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/unified-social-inbox-hub');
        break;
      case 1:
        Navigator.pushNamed(context, '/production-sms-messaging-hub');
        break;
      case 2:
        break;
      case 3:
        Navigator.pushNamed(context, '/user-profile-screen');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        title: Row(
          children: [
            CustomIconWidget(
              iconName: 'cloud',
              color: theme.colorScheme.primary,
              size: 28,
            ),
            SizedBox(width: 2.w),
            Text(
              'FhoneOS',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: CustomIconWidget(
              iconName: 'search',
              color: theme.colorScheme.onSurface,
              size: 24,
            ),
            onPressed: () {
              // Search functionality
            },
          ),
          IconButton(
            icon: CustomIconWidget(
              iconName: 'settings',
              color: theme.colorScheme.onSurface,
              size: 24,
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/settings-screen');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Status bar with connectivity
          _buildStatusBar(theme),
          // App grid
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemCount: _appPages.length,
              itemBuilder: (context, pageIndex) {
                return _buildAppGrid(theme, _appPages[pageIndex]);
              },
            ),
          ),
          // Page indicators
          if (_appPages.length > 1) _buildPageIndicators(theme),
          SizedBox(height: 2.h),
        ],
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: _currentBottomNavIndex,
        onTap: _handleBottomNavTap,
        items: const [
          CustomBottomBarItem(
            label: 'Social',
            icon: Icons.groups_outlined,
            activeIcon: Icons.groups,
            route: '/unified-social-inbox-hub',
          ),
          CustomBottomBarItem(
            label: 'Messages',
            icon: Icons.chat_bubble_outline,
            activeIcon: Icons.chat_bubble,
            route: '/production-sms-messaging-hub',
          ),
          CustomBottomBarItem(
            label: 'Desktop',
            icon: Icons.apps_outlined,
            activeIcon: Icons.apps,
            route: '/enhanced-app-launcher-desktop',
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

  Widget _buildStatusBar(ThemeData theme) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Connection status
          Container(
            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
            decoration: BoxDecoration(
              color: const Color(0xFF00D4AA).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.cloud_done,
                  size: 16,
                  color: const Color(0xFF00D4AA),
                ),
                SizedBox(width: 1.w),
                Text(
                  'All Systems Active',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF00D4AA),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          // Sync status
          CustomIconWidget(
            iconName: 'sync',
            color: theme.colorScheme.primary,
            size: 18,
          ),
        ],
      ),
    );
  }

  Widget _buildAppGrid(ThemeData theme, List<Map<String, dynamic>> apps) {
    return GridView.builder(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 3.w,
        mainAxisSpacing: 2.h,
        childAspectRatio: 0.85,
      ),
      itemCount: apps.length,
      itemBuilder: (context, index) {
        final app = apps[index];
        return _buildAppIcon(
          theme: theme,
          name: app['name'] as String,
          icon: app['icon'] as IconData,
          route: app['route'] as String,
          color: app['color'] as Color,
          badge: app['badge'] as int,
        );
      },
    );
  }

  Widget _buildAppIcon({
    required ThemeData theme,
    required String name,
    required IconData icon,
    required String route,
    required Color color,
    required int badge,
  }) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      onLongPress: () => _showAppContextMenu(name, route),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // App icon container with badge
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 15.w,
                height: 15.w,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              // Badge
              if (badge > 0)
                Positioned(
                  right: -6,
                  top: -6,
                  child: Container(
                    padding: EdgeInsets.all(0.5.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF4757),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.scaffoldBackgroundColor,
                        width: 2,
                      ),
                    ),
                    constraints: BoxConstraints(
                      minWidth: 5.w,
                      minHeight: 5.w,
                    ),
                    child: Center(
                      child: Text(
                        badge > 99 ? '99+' : badge.toString(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 8.sp,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 1.h),
          // App name
          Text(
            name,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 10.sp,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicators(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _appPages.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: EdgeInsets.symmetric(horizontal: 1.w),
          width: _currentPage == index ? 3.w : 2.w,
          height: 1.h,
          decoration: BoxDecoration(
            color: _currentPage == index
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  void _showAppContextMenu(String appName, String appRoute) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
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
                Container(
                  margin: EdgeInsets.symmetric(vertical: 1.h),
                  width: 10.w,
                  height: 0.5.h,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurfaceVariant
                        .withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
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
                ListTile(
                  leading: Icon(
                    Icons.open_in_new,
                    color: theme.colorScheme.primary,
                  ),
                  title: const Text('Open'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, appRoute);
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.info_outline,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  title: const Text('App Info'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                SizedBox(height: 1.h),
              ],
            ),
          ),
        );
      },
    );
  }
}

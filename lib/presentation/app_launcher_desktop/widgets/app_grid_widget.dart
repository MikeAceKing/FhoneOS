import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Grid layout widget displaying integrated apps with icons
class AppGridWidget extends StatefulWidget {
  final Function(String) onAppTap;
  final Function(String, String) onAppLongPress;

  const AppGridWidget({
    super.key,
    required this.onAppTap,
    required this.onAppLongPress,
  });

  @override
  State<AppGridWidget> createState() => _AppGridWidgetState();
}

class _AppGridWidgetState extends State<AppGridWidget> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<List<Map<String, dynamic>>> _appPages = [
    [
      {
        'name': 'SMS',
        'icon': 'chat_bubble',
        'route': '/production-sms-messaging-hub',
        'color': const Color(0xFF00D4AA),
      },
      {
        'name': 'Calls',
        'icon': 'phone',
        'route': '/real-time-call-management-center',
        'color': const Color(0xFF4A9EFF),
      },
      {
        'name': 'Social Hub',
        'icon': 'groups',
        'route': '/unified-social-inbox-hub',
        'color': const Color(0xFFF5A623),
      },
      {
        'name': 'Notifications',
        'icon': 'notifications',
        'route': '/notifications-screen',
        'color': const Color(0xFFFF4757),
      },
      {
        'name': 'Backups',
        'icon': 'backup',
        'route': '/cross-device-sync-backup-manager',
        'color': const Color(0xFF666677),
      },
      {
        'name': 'Numbers',
        'icon': 'dialpad',
        'route': '/number-management-dashboard',
        'color': const Color(0xFF4A9EFF),
      },
      {
        'name': 'AI Helper',
        'icon': 'smart_toy',
        'route': '/ai-assistant-chat',
        'color': const Color(0xFFF5A623),
      },
    ],
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // App grid pages
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
          iconName: app['icon'] as String,
          route: app['route'] as String,
          color: app['color'] as Color,
        );
      },
    );
  }

  Widget _buildAppIcon({
    required ThemeData theme,
    required String name,
    required String iconName,
    required String route,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () => widget.onAppTap(route),
      onLongPress: () => widget.onAppLongPress(name, route),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // App icon container
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
            child: Center(
              child: CustomIconWidget(
                iconName: iconName,
                color: Colors.white,
                size: 28,
              ),
            ),
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
}

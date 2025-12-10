import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

/// Apps Section Widget
/// Displays installed apps grid
class AppsSectionWidget extends StatelessWidget {
  const AppsSectionWidget({super.key});

  static final List<Map<String, dynamic>> _installedApps = [
    {
      'id': 'phone',
      'name': 'Phone',
      'category': 'System',
      'icon': Icons.phone_android,
    },
    {
      'id': 'messages',
      'name': 'Messages',
      'category': 'System',
      'icon': Icons.sms,
    },
    {
      'id': 'browser',
      'name': 'Browser',
      'category': 'Productivity',
      'icon': Icons.public,
    },
    {
      'id': 'files',
      'name': 'Files',
      'category': 'System',
      'icon': Icons.folder,
    },
    {
      'id': 'calendar',
      'name': 'Calendar',
      'category': 'Productivity',
      'icon': Icons.calendar_today,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: const Color(0xFF020617),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Color(0xFF1E293B)),
      ),
      child: Padding(
        padding: EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Geïnstalleerde apps',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 0.5.h),
            TextButton(
              onPressed:
                  () => Navigator.pushNamed(context, '/app-launcher-desktop'),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                minimumSize: Size.zero,
              ),
              child: Text(
                'Open volledige launcher',
                style: TextStyle(
                  fontSize: 11.sp,
                  color: const Color(0xFF6366F1),
                ),
              ),
            ),
            SizedBox(height: 1.h),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children:
                  _installedApps.map((app) => _AppIconTile(app: app)).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppIconTile extends StatelessWidget {
  final Map<String, dynamic> app;

  const _AppIconTile({required this.app});

  @override
  Widget build(BuildContext context) {
    final width = (MediaQuery.of(context).size.width - 64) / 3;
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => _handleAppTap(context),
      child: Container(
        width: width,
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF020617),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFF1E293B)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 36,
              width: 36,
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                app['icon'] as IconData,
                size: 20,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 0.6.h),
            Text(
              app['name'] as String,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            Text(
              app['category'] as String,
              style: TextStyle(fontSize: 10.sp, color: Colors.white54),
            ),
          ],
        ),
      ),
    );
  }

  void _handleAppTap(BuildContext context) {
    switch (app['id']) {
      case 'phone':
        Navigator.pushNamed(context, '/dialer-interface');
      case 'messages':
        Navigator.pushNamed(context, '/messaging-interface');
      case 'files':
        Navigator.pushNamed(context, '/camera-interface');
      default:
    }
  }
}

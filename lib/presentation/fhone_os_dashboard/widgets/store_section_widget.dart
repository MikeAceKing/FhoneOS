import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

/// Store Section Widget
/// Displays recommended apps from store
class StoreSectionWidget extends StatelessWidget {
  const StoreSectionWidget({super.key});

  static final List<Map<String, dynamic>> _storeApps = [
    {
      'id': 'whatsapp',
      'name': 'WhatsApp (Virtual)',
      'category': 'Social',
      'icon': Icons.chat_bubble,
    },
    {
      'id': 'slack',
      'name': 'Slack (Virtual)',
      'category': 'Work',
      'icon': Icons.workspaces_outline,
    },
    {
      'id': 'drive',
      'name': 'Cloud Drive',
      'category': 'Storage',
      'icon': Icons.cloud_outlined,
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
              'Store · Aanbevolen apps',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 1.h),
            Column(
              children:
                  _storeApps
                      .map(
                        (app) => Padding(
                          padding: EdgeInsets.symmetric(vertical: 0.4.h),
                          child: _StoreAppRow(app: app),
                        ),
                      )
                      .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _StoreAppRow extends StatelessWidget {
  final Map<String, dynamic> app;

  const _StoreAppRow({required this.app});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 30,
          width: 30,
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(app['icon'] as IconData, size: 18, color: Colors.white),
        ),
        SizedBox(width: 2.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                app['name'] as String,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              Text(
                app['category'] as String,
                style: TextStyle(fontSize: 11.sp, color: Colors.white54),
              ),
            ],
          ),
        ),
        ElevatedButton(
          onPressed: () {
            // TODO: Install flow with Supabase
          },
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            minimumSize: Size.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
            ),
            backgroundColor: const Color(0xFF6366F1),
          ),
          child: Text(
            'Install',
            style: TextStyle(fontSize: 11.sp, color: Colors.white),
          ),
        ),
      ],
    );
  }
}

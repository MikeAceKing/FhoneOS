import 'package:flutter/material.dart';

import './widgets/permission_category_widget.dart';
import './widgets/permission_history_widget.dart';
import './widgets/privacy_dashboard_widget.dart';

class PermissionManagementCenter extends StatefulWidget {
  const PermissionManagementCenter({super.key});

  @override
  State<PermissionManagementCenter> createState() =>
      _PermissionManagementCenterState();
}

class _PermissionManagementCenterState extends State<PermissionManagementCenter>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Permission Management',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Permissions'),
            Tab(text: 'History'),
            Tab(text: 'Privacy'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPermissionsTab(),
          const PermissionHistoryWidget(),
          const PrivacyDashboardWidget(),
        ],
      ),
    );
  }

  Widget _buildPermissionsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        PermissionCategoryWidget(
          title: 'Essential Permissions',
          description: 'Required for core functionality',
          permissions: [
            {'name': 'Phone', 'status': 'granted', 'icon': 'phone'},
            {'name': 'SMS', 'status': 'granted', 'icon': 'message'},
            {'name': 'Contacts', 'status': 'granted', 'icon': 'contacts'},
          ],
          categoryColor: Colors.red,
        ),
        SizedBox(height: 16),
        PermissionCategoryWidget(
          title: 'Media Permissions',
          description: 'For photos, videos, and audio',
          permissions: [
            {'name': 'Camera', 'status': 'granted', 'icon': 'camera_alt'},
            {'name': 'Microphone', 'status': 'denied', 'icon': 'mic'},
            {'name': 'Storage', 'status': 'granted', 'icon': 'storage'},
          ],
          categoryColor: Colors.blue,
        ),
        SizedBox(height: 16),
        PermissionCategoryWidget(
          title: 'Location Permissions',
          description: 'Access to device location',
          permissions: [
            {
              'name': 'Precise Location',
              'status': 'granted',
              'icon': 'location_on'
            },
            {
              'name': 'Approximate Location',
              'status': 'not_requested',
              'icon': 'location_searching'
            },
            {
              'name': 'Background Location',
              'status': 'restricted',
              'icon': 'my_location'
            },
          ],
          categoryColor: Colors.green,
        ),
        SizedBox(height: 16),
        PermissionCategoryWidget(
          title: 'Optional Permissions',
          description: 'Enhanced features',
          permissions: [
            {
              'name': 'Calendar',
              'status': 'not_requested',
              'icon': 'calendar_today'
            },
            {
              'name': 'Notifications',
              'status': 'granted',
              'icon': 'notifications'
            },
            {'name': 'Biometrics', 'status': 'granted', 'icon': 'fingerprint'},
          ],
          categoryColor: Colors.orange,
        ),
      ],
    );
  }
}

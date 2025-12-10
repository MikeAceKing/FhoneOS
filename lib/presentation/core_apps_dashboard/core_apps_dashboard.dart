import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import '../../routes/app_routes.dart';
import './widgets/app_status_card_widget.dart';
import './widgets/quick_action_widget.dart';

class CoreAppsDashboard extends StatefulWidget {
  const CoreAppsDashboard({super.key});

  @override
  State<CoreAppsDashboard> createState() => _CoreAppsDashboardState();
}

class _CoreAppsDashboardState extends State<CoreAppsDashboard> {
  bool _isLoading = false;

  final List<Map<String, dynamic>> _coreApps = [
    {
      'name': 'SMS',
      'icon': Icons.message,
      'route': AppRoutes.productionSmsMessagingHub,
      'color': Colors.blue,
      'unreadCount': 5,
      'status': 'Active',
    },
    {
      'name': 'Calls',
      'icon': Icons.phone,
      'route': AppRoutes.realTimeCallManagementCenter,
      'color': Colors.green,
      'missedCount': 2,
      'status': 'Active',
    },
    {
      'name': 'Contacts',
      'icon': Icons.contacts,
      'route': '/contacts',
      'color': Colors.orange,
      'totalCount': 150,
      'status': 'Synced',
    },
    {
      'name': 'Notifications',
      'icon': Icons.notifications,
      'route': AppRoutes.notifications,
      'color': Colors.purple,
      'unreadCount': 8,
      'status': 'Active',
    },
    {
      'name': 'Backups',
      'icon': Icons.backup,
      'route': AppRoutes.cloudSyncConfiguration,
      'color': Colors.teal,
      'lastBackup': '2 hours ago',
      'status': 'Up to date',
    },
    {
      'name': 'Numbers',
      'icon': Icons.phone_android,
      'route': AppRoutes.phoneNumberPurchaseScreen,
      'color': Colors.indigo,
      'activeNumbers': 3,
      'status': 'Active',
    },
    {
      'name': 'AI Helper',
      'icon': Icons.psychology,
      'route': AppRoutes.aiAssistantChat,
      'color': Colors.deepPurple,
      'creditsRemaining': 250,
      'status': 'Ready',
    },
  ];

  Future<void> _refreshDashboard() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FhoneOS Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.settings),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshDashboard,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildQuickActions(),
                      const SizedBox(height: 24),
                      _buildStatusBar(),
                      const SizedBox(height: 24),
                      _buildAppsGrid(),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              QuickActionWidget(
                icon: Icons.message,
                label: 'Compose SMS',
                onTap: () => Navigator.pushNamed(
                    context, AppRoutes.productionSmsMessagingHub),
              ),
              const SizedBox(width: 12),
              QuickActionWidget(
                icon: Icons.call,
                label: 'Make Call',
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.dialerInterface),
              ),
              const SizedBox(width: 12),
              QuickActionWidget(
                icon: Icons.person_add,
                label: 'Add Contact',
                onTap: () {},
              ),
              const SizedBox(width: 12),
              QuickActionWidget(
                icon: Icons.chat,
                label: 'AI Chat',
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.aiAssistantChat),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatusIndicator('Twilio', Icons.phone_enabled, Colors.green),
          _buildStatusIndicator('Stripe', Icons.payment, Colors.green),
          _buildStatusIndicator('Cloud Sync', Icons.cloud_done, Colors.green),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(String label, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildAppsGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Core Apps',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.1,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: _coreApps.length,
          itemBuilder: (context, index) {
            final app = _coreApps[index];
            return AppStatusCardWidget(
              name: app['name'],
              icon: app['icon'],
              color: app['color'],
              status: app['status'],
              route: app['route'],
              badge: app['unreadCount'] ?? app['missedCount'] ?? 0,
            );
          },
        ),
      ],
    );
  }
}
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/app_export.dart';
import '../../routes/app_routes.dart';

class EnhancedAppLauncherDesktop extends StatefulWidget {
  const EnhancedAppLauncherDesktop({Key? key}) : super(key: key);

  @override
  State<EnhancedAppLauncherDesktop> createState() =>
      _EnhancedAppLauncherDesktopState();
}

class _EnhancedAppLauncherDesktopState
    extends State<EnhancedAppLauncherDesktop> {
  String _currentTime = '';

  @override
  void initState() {
    super.initState();
    _updateTime();
    Future.delayed(Duration.zero, () {
      _startClock();
    });
  }

  void _startClock() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        _updateTime();
        return true;
      }
      return false;
    });
  }

  void _updateTime() {
    if (mounted) {
      setState(() {
        _currentTime = DateFormat('HH:mm').format(DateTime.now());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).primaryColor.withAlpha(26),
              Theme.of(context).scaffoldBackgroundColor,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Status Bar
              _buildStatusBar(),

              // Main Content Area
              Expanded(
                child: _buildAppGrid(),
              ),

              // Quick Actions Bar
              _buildQuickActionsBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // FhoneOS Logo & Time
          Row(
            children: [
              Icon(Icons.phone_android, color: Theme.of(context).primaryColor),
              const SizedBox(width: 8),
              Text(
                'FhoneOS',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                _currentTime,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),

          // Status Icons
          Row(
            children: [
              Icon(Icons.wifi, size: 20, color: Colors.grey[600]),
              const SizedBox(width: 12),
              Icon(Icons.battery_full, size: 20, color: Colors.grey[600]),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.settings);
                },
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: Theme.of(context).primaryColor.withAlpha(26),
                  child: Icon(
                    Icons.person,
                    size: 18,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAppGrid() {
    final apps = [
      {
        'name': 'Dashboard',
        'icon': Icons.dashboard,
        'route': AppRoutes.dashboard
      },
      {'name': 'Social Hub', 'icon': Icons.forum, 'route': AppRoutes.socialHub},
      {
        'name': 'WhatsApp',
        'icon': Icons.chat_bubble,
        'route': AppRoutes.whatsappBusiness
      },
      {
        'name': 'Messages',
        'icon': Icons.message,
        'route': AppRoutes.messagingInterface
      },
      {
        'name': 'Dialer',
        'icon': Icons.dialpad,
        'route': AppRoutes.dialerInterface
      },
      {
        'name': 'Video Call',
        'icon': Icons.video_call,
        'route': AppRoutes.videoCall
      },
      {'name': 'Contacts', 'icon': Icons.contacts, 'route': AppRoutes.contacts},
      {'name': 'Camera', 'icon': Icons.camera_alt, 'route': AppRoutes.camera},
      {
        'name': 'Media',
        'icon': Icons.perm_media,
        'route': AppRoutes.mediaCenter
      },
      {
        'name': 'Numbers',
        'icon': Icons.phone_in_talk,
        'route': AppRoutes.numberManagement
      },
      {
        'name': 'Wallet',
        'icon': Icons.account_balance_wallet,
        'route': AppRoutes.walletBilling
      },
      {'name': 'Settings', 'icon': Icons.settings, 'route': AppRoutes.settings},
    ];

    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 1,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: apps.length,
      itemBuilder: (context, index) {
        final app = apps[index];
        return _buildAppIcon(
          app['name'] as String,
          app['icon'] as IconData,
          app['route'] as String,
        );
      },
    );
  }

  Widget _buildAppIcon(String name, IconData icon, String route) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, route);
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withAlpha(26),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              size: 32,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: const TextStyle(
              fontSize: 12,
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

  Widget _buildQuickActionsBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildQuickActionButton(
              Icons.phone, 'Call', AppRoutes.dialerInterface),
          _buildQuickActionButton(
              Icons.message, 'Message', AppRoutes.messagingInterface),
          _buildQuickActionButton(Icons.camera_alt, 'Camera', AppRoutes.camera),
          _buildQuickActionButton(Icons.dashboard, 'Home', AppRoutes.dashboard),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(IconData icon, String label, String route) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, route);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 28, color: Theme.of(context).primaryColor),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}

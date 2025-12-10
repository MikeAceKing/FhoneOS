import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/call_history_widget.dart';
import './widgets/contact_selection_widget.dart';

/// Video Calling Interface - WebRTC-powered communication screen
/// Provides contact selection, active call management, and call history
class VideoCallingInterface extends StatefulWidget {
  const VideoCallingInterface({super.key});

  @override
  State<VideoCallingInterface> createState() => _VideoCallingInterfaceState();
}

class _VideoCallingInterfaceState extends State<VideoCallingInterface>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentBottomNavIndex = 2; // Desktop tab active by default

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleBottomNavTap(int index) {
    setState(() => _currentBottomNavIndex = index);

    // Navigate to corresponding screens
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/social-hub');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/messaging-interface');
        break;
      case 2:
        // Current screen - do nothing
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/user-profile-screen');
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
        elevation: 2.0,
        leading: IconButton(
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: theme.colorScheme.onSurface,
            size: 24,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Video Calling',
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Contacts'),
            Tab(text: 'History'),
          ],
          labelColor: theme.colorScheme.primary,
          unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
          indicatorColor: theme.colorScheme.primary,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          ContactSelectionWidget(),
          CallHistoryWidget(),
        ],
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: _currentBottomNavIndex,
        onTap: _handleBottomNavTap,
      ),
    );
  }
}

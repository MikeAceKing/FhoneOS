import 'package:flutter/material.dart';

/// Profile tabs widget for Friends and Gallery navigation
class ProfileTabsWidget extends StatelessWidget {
  final TabController tabController;

  const ProfileTabsWidget({
    super.key,
    required this.tabController,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline,
            width: 1,
          ),
        ),
      ),
      child: TabBar(
        controller: tabController,
        indicatorColor: const Color(0xFF00D4AA),
        indicatorWeight: 3,
        labelColor: const Color(0xFF00D4AA),
        unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
        labelStyle: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w400,
        ),
        tabs: const [
          Tab(text: 'Friends'),
          Tab(text: 'Gallery'),
        ],
      ),
    );
  }
}

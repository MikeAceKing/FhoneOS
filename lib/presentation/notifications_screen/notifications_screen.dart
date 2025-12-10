import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/empty_state_widget.dart';
import './widgets/like_analytics_widget.dart';
import './widgets/notification_card_widget.dart';

/// Notifications Screen with dual-tab interface for activity feed management
/// Implements real-time WebSocket updates, swipe gestures, and platform-specific interactions
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isRefreshing = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // Mock notification data
  final List<Map<String, dynamic>> _notifications = [
    {
      "id": "1",
      "userId": "user_001",
      "userName": "Sarah Johnson",
      "userAvatar":
          "https://img.rocket.new/generatedImages/rocket_gen_img_122f6d06e-1764690565988.png",
      "semanticLabel":
          "Profile photo of a woman with long brown hair wearing a white blouse",
      "action": "liked your post",
      "preview": "Amazing sunset photo!",
      "timestamp": DateTime.now().subtract(const Duration(minutes: 5)),
      "isRead": false,
      "type": "like"
    },
    {
      "id": "2",
      "userId": "user_002",
      "userName": "Michael Chen",
      "userAvatar":
          "https://img.rocket.new/generatedImages/rocket_gen_img_1907e5900-1763296402708.png",
      "semanticLabel":
          "Profile photo of a man with short black hair wearing glasses and a blue shirt",
      "action": "commented on your photo",
      "preview": "This looks incredible! Where was this taken?",
      "timestamp": DateTime.now().subtract(const Duration(hours: 2)),
      "isRead": false,
      "type": "comment"
    },
    {
      "id": "3",
      "userId": "user_003",
      "userName": "Emma Williams",
      "userAvatar":
          "https://img.rocket.new/generatedImages/rocket_gen_img_14fbbc1e3-1765215925472.png",
      "semanticLabel":
          "Profile photo of a woman with blonde hair in a ponytail wearing a green sweater",
      "action": "started following you",
      "preview": "",
      "timestamp": DateTime.now().subtract(const Duration(hours: 5)),
      "isRead": true,
      "type": "follow"
    },
    {
      "id": "4",
      "userId": "user_004",
      "userName": "James Rodriguez",
      "userAvatar":
          "https://img.rocket.new/generatedImages/rocket_gen_img_1ad36cffb-1763296582563.png",
      "semanticLabel":
          "Profile photo of a man with curly brown hair and a beard wearing a gray hoodie",
      "action": "mentioned you in a comment",
      "preview": "@you Check out this amazing view!",
      "timestamp": DateTime.now().subtract(const Duration(days: 1)),
      "isRead": true,
      "type": "mention"
    },
    {
      "id": "5",
      "userId": "user_005",
      "userName": "Olivia Martinez",
      "userAvatar":
          "https://images.unsplash.com/photo-1648407429901-30af468fdc93",
      "semanticLabel":
          "Profile photo of a woman with short red hair wearing a black turtleneck",
      "action": "shared your post",
      "preview": "Travel goals! 🌍",
      "timestamp": DateTime.now().subtract(const Duration(days: 2)),
      "isRead": true,
      "type": "share"
    },
  ];

  // Mock likes analytics data
  final Map<String, dynamic> _likesAnalytics = {
    "totalLikes": 1247,
    "weeklyGrowth": 23.5,
    "topPosts": [
      {
        "postId": "post_001",
        "thumbnail":
            "https://img.rocket.new/generatedImages/rocket_gen_img_1e3f94f08-1764654668026.png",
        "semanticLabel": "Mountain landscape with snow-capped peaks at sunset",
        "likes": 342,
        "title": "Mountain Adventure"
      },
      {
        "postId": "post_002",
        "thumbnail":
            "https://img.rocket.new/generatedImages/rocket_gen_img_1bc2a0bd6-1765183713615.png",
        "semanticLabel": "Tropical beach with turquoise water and palm trees",
        "likes": 298,
        "title": "Beach Paradise"
      },
      {
        "postId": "post_003",
        "thumbnail":
            "https://images.unsplash.com/photo-1650824155060-69767f526125",
        "semanticLabel": "City skyline at night with illuminated skyscrapers",
        "likes": 267,
        "title": "City Lights"
      },
    ],
    "engagementByDay": [
      {"day": "Mon", "likes": 45},
      {"day": "Tue", "likes": 67},
      {"day": "Wed", "likes": 89},
      {"day": "Thu", "likes": 123},
      {"day": "Fri", "likes": 156},
      {"day": "Sat", "likes": 198},
      {"day": "Sun", "likes": 167},
    ]
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    setState(() => _isRefreshing = true);
    // Simulate WebSocket fetch
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isRefreshing = false);
  }

  void _markAllAsRead() {
    setState(() {
      for (var notification in _notifications) {
        notification["isRead"] = true;
      }
    });
  }

  void _deleteNotification(String id) {
    setState(() {
      _notifications.removeWhere((n) => n["id"] == id);
    });
  }

  void _blockUser(String userId) {
    setState(() {
      _notifications.removeWhere((n) => n["userId"] == userId);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('User blocked successfully')),
    );
  }

  void _viewProfile(String userId) {
    Navigator.pushNamed(context, '/user-profile-screen');
  }

  List<Map<String, dynamic>> get _filteredNotifications {
    if (_searchQuery.isEmpty) return _notifications;
    return _notifications.where((n) {
      final userName = (n["userName"] as String).toLowerCase();
      final action = (n["action"] as String).toLowerCase();
      final query = _searchQuery.toLowerCase();
      return userName.contains(query) || action.contains(query);
    }).toList();
  }

  int get _unreadCount =>
      _notifications.where((n) => n["isRead"] == false).length;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: 'Notifications',
        centerTitle: false,
        actions: [
          if (_unreadCount > 0)
            TextButton(
              onPressed: _markAllAsRead,
              child: Text(
                'Mark all read',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          IconButton(
            icon: CustomIconWidget(
              iconName: 'search',
              color: theme.colorScheme.onSurface,
              size: 24,
            ),
            onPressed: () => _showSearchDialog(context),
            tooltip: 'Search notifications',
          ),
        ],
      ),
      body: Column(
        children: [
          // Tab Bar
          Container(
            color: theme.colorScheme.surface,
            child: TabBar(
              controller: _tabController,
              labelColor: theme.colorScheme.primary,
              unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
              indicatorColor: theme.colorScheme.primary,
              indicatorWeight: 3.0,
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Notifications'),
                      if (_unreadCount > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.error,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$_unreadCount',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onError,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const Tab(text: 'Likes'),
              ],
            ),
          ),
          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildNotificationsTab(theme),
                _buildLikesTab(theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsTab(ThemeData theme) {
    if (_filteredNotifications.isEmpty) {
      return EmptyStateWidget(
        icon: 'notifications_none',
        title:
            _searchQuery.isEmpty ? 'No notifications yet' : 'No results found',
        subtitle: _searchQuery.isEmpty
            ? 'When you get notifications, they\'ll show up here'
            : 'Try adjusting your search',
        actionLabel: _searchQuery.isEmpty ? 'Invite Friends' : null,
        onActionPressed: _searchQuery.isEmpty
            ? () {
                // Handle invite friends
              }
            : null,
      );
    }

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _filteredNotifications.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          color: theme.colorScheme.outlineVariant,
        ),
        itemBuilder: (context, index) {
          final notification = _filteredNotifications[index];
          return NotificationCardWidget(
            notification: notification,
            onDelete: () => _deleteNotification(notification["id"] as String),
            onBlockUser: () => _blockUser(notification["userId"] as String),
            onViewProfile: () => _viewProfile(notification["userId"] as String),
          );
        },
      ),
    );
  }

  Widget _buildLikesTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: LikeAnalyticsWidget(analytics: _likesAnalytics),
    );
  }

  void _showSearchDialog(BuildContext context) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Search Notifications',
          style: theme.textTheme.titleLarge,
        ),
        content: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search by user or action...',
            prefixIcon: CustomIconWidget(
              iconName: 'search',
              color: theme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onChanged: (value) {
            setState(() => _searchQuery = value);
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              _searchController.clear();
              setState(() => _searchQuery = '');
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/create_post_modal_widget.dart';
import './widgets/platform_tab_widget.dart';
import './widgets/social_post_card_widget.dart';

/// Social Hub screen that consolidates multiple social media platforms
/// through embedded webview containers with OAuth integration
class SocialHub extends StatefulWidget {
  const SocialHub({super.key});

  @override
  State<SocialHub> createState() => _SocialHubState();
}

class _SocialHubState extends State<SocialHub> with TickerProviderStateMixin {
  late TabController _platformTabController;
  int _currentBottomNavIndex = 0;
  int _selectedPlatformIndex = 0;
  final ScrollController _scrollController = ScrollController();
  bool _isRefreshing = false;

  // Mock social media platforms data
  final List<Map<String, dynamic>> _platforms = [
    {
      "id": 1,
      "name": "Facebook",
      "icon": "facebook",
      "color": Color(0xFF1877F2),
      "url": "https://www.facebook.com",
    },
    {
      "id": 2,
      "name": "Snapchat",
      "icon": "snapchat",
      "color": Color(0xFFFFFC00),
      "url": "https://www.snapchat.com",
    },
    {
      "id": 3,
      "name": "Instagram",
      "icon": "camera_alt",
      "color": Color(0xFFE4405F),
      "url": "https://www.instagram.com",
    },
  ];

  // Mock social feed data
  final List<Map<String, dynamic>> _feedPosts = [
    {
      "id": 1,
      "platform": "Facebook",
      "userName": "Sarah Johnson",
      "userAvatar":
          "https://img.rocket.new/generatedImages/rocket_gen_img_176e07230-1763293461602.png",
      "semanticLabel":
          "Profile photo of a woman with long brown hair wearing a blue top",
      "timestamp": "2 hours ago",
      "content":
          "Just finished an amazing hike in the mountains! The view from the top was absolutely breathtaking. Nature never fails to inspire me. 🏔️",
      "image":
          "https://images.unsplash.com/photo-1727334579394-85c303142945",
      "imageSemanticLabel":
          "Scenic mountain landscape with snow-capped peaks under blue sky with white clouds",
      "likes": 234,
      "comments": 45,
      "shares": 12,
    },
    {
      "id": 2,
      "platform": "Instagram",
      "userName": "Alex Chen",
      "userAvatar":
          "https://img.rocket.new/generatedImages/rocket_gen_img_168fa4879-1763295787903.png",
      "semanticLabel":
          "Profile photo of a man with short black hair wearing glasses and a gray shirt",
      "timestamp": "5 hours ago",
      "content":
          "Coffee and code - the perfect combination for a productive morning! ☕💻",
      "image":
          "https://images.unsplash.com/photo-1424392904403-8e1c65a6133a",
      "imageSemanticLabel":
          "Laptop computer on wooden desk with coffee cup and notebook beside it",
      "likes": 567,
      "comments": 89,
      "shares": 23,
    },
    {
      "id": 3,
      "platform": "Snapchat",
      "userName": "Emma Wilson",
      "userAvatar":
          "https://img.rocket.new/generatedImages/rocket_gen_img_188057f3f-1764851725587.png",
      "semanticLabel":
          "Profile photo of a woman with blonde hair and bright smile wearing yellow top",
      "timestamp": "1 day ago",
      "content": "Sunset vibes at the beach 🌅 Living my best life!",
      "image":
          "https://images.unsplash.com/photo-1461650661864-2cc97fb64a1b",
      "imageSemanticLabel":
          "Beautiful orange and pink sunset over ocean with silhouette of person standing on beach",
      "likes": 892,
      "comments": 134,
      "shares": 45,
    },
    {
      "id": 4,
      "platform": "Facebook",
      "userName": "Michael Rodriguez",
      "userAvatar":
          "https://img.rocket.new/generatedImages/rocket_gen_img_1e13bc62a-1763294059113.png",
      "semanticLabel":
          "Profile photo of a man with short brown hair and beard wearing dark t-shirt",
      "timestamp": "2 days ago",
      "content":
          "New recipe alert! Just made the most delicious homemade pizza. Who wants the recipe? 🍕",
      "image":
          "https://images.unsplash.com/photo-1703219343408-02e2098c9eb9",
      "imageSemanticLabel":
          "Freshly baked pizza with melted cheese, tomatoes, and basil on wooden cutting board",
      "likes": 445,
      "comments": 78,
      "shares": 34,
    },
  ];

  @override
  void initState() {
    super.initState();
    _platformTabController = TabController(
      length: _platforms.length,
      vsync: this,
    );
    _platformTabController.addListener(_handlePlatformTabChange);
  }

  @override
  void dispose() {
    _platformTabController.removeListener(_handlePlatformTabChange);
    _platformTabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handlePlatformTabChange() {
    if (_platformTabController.indexIsChanging) {
      setState(() {
        _selectedPlatformIndex = _platformTabController.index;
      });
    }
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _isRefreshing = true;
    });

    // Simulate network refresh
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isRefreshing = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '${_platforms[_selectedPlatformIndex]["name"]} feed refreshed'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _showCreatePostModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CreatePostModalWidget(
        platforms: _platforms,
        onPost: (selectedPlatforms, content, mediaPath) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('Posted to ${selectedPlatforms.length} platform(s)'),
              duration: const Duration(seconds: 2),
            ),
          );
        },
      ),
    );
  }

  void _handlePostAction(String action, Map<String, dynamic> post) {
    String message = '';
    switch (action) {
      case 'like':
        message = 'Liked post from ${post["userName"]}';
        break;
      case 'comment':
        message = 'Opening comments for ${post["userName"]}\'s post';
        break;
      case 'share':
        message = 'Sharing ${post["userName"]}\'s post';
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredPosts() {
    final selectedPlatform = _platforms[_selectedPlatformIndex]["name"];
    return _feedPosts
        .where((post) => post["platform"] == selectedPlatform)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filteredPosts = _getFilteredPosts();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 2.0,
        title: Text(
          'Social Hub',
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        actions: [
          IconButton(
            icon: CustomIconWidget(
              iconName: 'search',
              color: theme.colorScheme.onSurface,
              size: 24,
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Search functionality coming soon'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            tooltip: 'Search',
          ),
          IconButton(
            icon: CustomIconWidget(
              iconName: 'notifications_outlined',
              color: theme.colorScheme.onSurface,
              size: 24,
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/notifications-screen');
            },
            tooltip: 'Notifications',
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Container(
            color: theme.colorScheme.surface,
            child: TabBar(
              controller: _platformTabController,
              isScrollable: true,
              indicatorColor: theme.colorScheme.primary,
              indicatorWeight: 3.0,
              labelColor: theme.colorScheme.primary,
              unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
              labelStyle: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w400,
              ),
              tabs: _platforms.map((platform) {
                return Tab(
                  child: PlatformTabWidget(
                    platform: platform,
                    isSelected:
                        _platforms.indexOf(platform) == _selectedPlatformIndex,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: theme.colorScheme.primary,
        child: _isRefreshing
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Refreshing feed...',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              )
            : filteredPosts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomIconWidget(
                          iconName: 'feed',
                          color: theme.colorScheme.onSurfaceVariant,
                          size: 64,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No posts available',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Pull down to refresh',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: filteredPosts.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      return SocialPostCardWidget(
                        post: filteredPosts[index],
                        onLike: () =>
                            _handlePostAction('like', filteredPosts[index]),
                        onComment: () =>
                            _handlePostAction('comment', filteredPosts[index]),
                        onShare: () =>
                            _handlePostAction('share', filteredPosts[index]),
                      );
                    },
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreatePostModal,
        backgroundColor: theme.colorScheme.primary,
        child: CustomIconWidget(
          iconName: 'add',
          color: Colors.white,
          size: 28,
        ),
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: _currentBottomNavIndex,
        onTap: (index) {
          setState(() {
            _currentBottomNavIndex = index;
          });

          final routes = [
            '/social-hub',
            '/messaging-interface',
            '/app-launcher-desktop',
            '/user-profile-screen',
          ];

          if (index != 0) {
            Navigator.pushNamed(context, routes[index]);
          }
        },
      ),
    );
  }
}

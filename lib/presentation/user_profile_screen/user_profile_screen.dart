import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/friends_grid_widget.dart';
import './widgets/gallery_grid_widget.dart';
import './widgets/profile_header_widget.dart';
import './widgets/profile_tabs_widget.dart';
import './widgets/social_activity_card_widget.dart';
import './widgets/user_stats_widget.dart';

/// User Profile Screen displaying comprehensive user information and social statistics
class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _currentBottomNavIndex = 3;
  bool _isRefreshing = false;
  DateTime _lastSyncTime = DateTime.now();

  // Mock user data
  final Map<String, dynamic> _userData = {
    "name": "Sarah Johnson",
    "username": "@sarahjohnson",
    "profileImage":
        "https://img.rocket.new/generatedImages/rocket_gen_img_103b528db-1763293982935.png",
    "semanticLabel":
        "Professional headshot of a woman with long brown hair wearing a white blouse against a neutral background",
    "followersCount": 12500,
    "followingCount": 850,
    "postsCount": 342,
    "bio": "Digital creator | Travel enthusiast | Coffee lover ☕",
  };

  // Mock friends data
  final List<Map<String, dynamic>> _friendsList = [
    {
      "id": 1,
      "name": "Michael Chen",
      "avatar":
          "https://img.rocket.new/generatedImages/rocket_gen_img_10e32363d-1763295001957.png",
      "semanticLabel":
          "Profile photo of an Asian man with short black hair wearing a blue shirt",
      "isOnline": true,
    },
    {
      "id": 2,
      "name": "Emma Wilson",
      "avatar":
          "https://images.unsplash.com/photo-1722837070629-f072032c4345",
      "semanticLabel":
          "Profile photo of a woman with blonde hair and glasses wearing a red top",
      "isOnline": true,
    },
    {
      "id": 3,
      "name": "James Rodriguez",
      "avatar":
          "https://img.rocket.new/generatedImages/rocket_gen_img_17de37503-1763294678728.png",
      "semanticLabel":
          "Profile photo of a Hispanic man with dark hair wearing a gray t-shirt",
      "isOnline": false,
    },
    {
      "id": 4,
      "name": "Sophia Lee",
      "avatar":
          "https://img.rocket.new/generatedImages/rocket_gen_img_1ef28082b-1763294062175.png",
      "semanticLabel":
          "Profile photo of an Asian woman with long black hair wearing a white blouse",
      "isOnline": true,
    },
    {
      "id": 5,
      "name": "David Brown",
      "avatar":
          "https://img.rocket.new/generatedImages/rocket_gen_img_17fea9682-1764690565935.png",
      "semanticLabel":
          "Profile photo of a man with brown hair and beard wearing a black shirt",
      "isOnline": false,
    },
    {
      "id": 6,
      "name": "Olivia Martinez",
      "avatar":
          "https://img.rocket.new/generatedImages/rocket_gen_img_1e3c616b4-1765003960787.png",
      "semanticLabel":
          "Profile photo of a woman with curly brown hair wearing a green top",
      "isOnline": true,
    },
  ];

  // Mock gallery data
  final List<Map<String, dynamic>> _galleryItems = [
    {
      "id": 1,
      "url":
          "https://images.unsplash.com/photo-1533094128596-e6337be6f9bf",
      "semanticLabel":
          "Scenic mountain landscape with snow-capped peaks under blue sky",
      "timestamp": DateTime.now().subtract(const Duration(days: 2)),
    },
    {
      "id": 2,
      "url":
          "https://img.rocket.new/generatedImages/rocket_gen_img_1bc2a0bd6-1765183713615.png",
      "semanticLabel": "Tropical beach with turquoise water and palm trees",
      "timestamp": DateTime.now().subtract(const Duration(days: 5)),
    },
    {
      "id": 3,
      "url": "https://img.rocket.new/generatedImages/rocket_gen_img_1b1a154f8-1764643492764.png",
      "semanticLabel": "Delicious gourmet burger with fries on wooden table",
      "timestamp": DateTime.now().subtract(const Duration(days: 7)),
    },
    {
      "id": 4,
      "url":
          "https://images.unsplash.com/photo-1578571411977-93949574a8b0",
      "semanticLabel": "Starry night sky over mountain silhouette",
      "timestamp": DateTime.now().subtract(const Duration(days: 10)),
    },
    {
      "id": 5,
      "url":
          "https://images.unsplash.com/photo-1710080500770-815de0a51d16",
      "semanticLabel": "Misty forest with tall pine trees at sunrise",
      "timestamp": DateTime.now().subtract(const Duration(days: 12)),
    },
    {
      "id": 6,
      "url":
          "https://images.unsplash.com/photo-1667146123163-d840ef114f83",
      "semanticLabel": "Urban cityscape with modern skyscrapers at sunset",
      "timestamp": DateTime.now().subtract(const Duration(days: 15)),
    },
  ];

  // Mock activity data
  final List<Map<String, dynamic>> _activityList = [
    {
      "id": 1,
      "type": "like",
      "title": "New likes received",
      "description": "Your recent post got 245 new likes",
      "timestamp": DateTime.now().subtract(const Duration(hours: 2)),
    },
    {
      "id": 2,
      "type": "comment",
      "title": "New comments",
      "description": "Emma Wilson commented on your photo",
      "timestamp": DateTime.now().subtract(const Duration(hours: 5)),
    },
    {
      "id": 3,
      "type": "follow",
      "title": "New follower",
      "description": "Michael Chen started following you",
      "timestamp": DateTime.now().subtract(const Duration(hours: 8)),
    },
    {
      "id": 4,
      "type": "share",
      "title": "Post shared",
      "description": "Your post was shared 12 times",
      "timestamp": DateTime.now().subtract(const Duration(days: 1)),
    },
    {
      "id": 5,
      "type": "like",
      "title": "Trending post",
      "description": "Your post is trending in Travel category",
      "timestamp": DateTime.now().subtract(const Duration(days: 2)),
    },
  ];

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

  Future<void> _handleRefresh() async {
    setState(() => _isRefreshing = true);

    // Simulate data refresh
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isRefreshing = false;
      _lastSyncTime = DateTime.now();
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Profile updated successfully'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(2.w),
          ),
        ),
      );
    }
  }

  void _handleEditProfile() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildEditProfileSheet(),
    );
  }

  void _handleSettings() {
    Navigator.pushNamed(context, '/settings-screen');
  }

  void _handleGalleryAction(int index, String action) {
    final theme = Theme.of(context);

    String message = '';
    switch (action) {
      case 'share':
        message = 'Sharing photo...';
        break;
      case 'delete':
        message = 'Photo deleted';
        setState(() => _galleryItems.removeAt(index));
        break;
      case 'edit':
        message = 'Opening editor...';
        break;
      case 'set_avatar':
        message = 'Avatar updated';
        setState(() {
          _userData['profileImage'] = _galleryItems[index]['url'];
          _userData['semanticLabel'] = _galleryItems[index]['semanticLabel'];
        });
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(2.w),
        ),
      ),
    );
  }

  Widget _buildEditProfileSheet() {
    final theme = Theme.of(context);

    return Container(
      height: 50.h,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(4.w)),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: theme.colorScheme.outline,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Text(
                  'Edit Profile',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Profile updated'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  child: Text(
                    'Save',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(4.w),
              child: Column(
                children: [
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Name',
                      hintText: _userData['name'] as String,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Username',
                      hintText: _userData['username'] as String,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  TextField(
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Bio',
                      hintText: _userData['bio'] as String,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 2,
        title: Text(
          'Profile',
          style: theme.textTheme.titleLarge,
        ),
        actions: [
          IconButton(
            icon: CustomIconWidget(
              iconName: 'settings',
              size: 6.w,
              color: theme.colorScheme.onSurface,
            ),
            onPressed: _handleSettings,
            tooltip: 'Settings',
          ),
          SizedBox(width: 2.w),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: theme.colorScheme.primary,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  ProfileHeaderWidget(
                    profileImageUrl: _userData['profileImage'] as String?,
                    onEditTap: _handleEditProfile,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: Column(
                      children: [
                        Text(
                          _userData['name'] as String,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          _userData['username'] as String,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          _userData['bio'] as String,
                          style: theme.textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  UserStatsWidget(
                    followersCount: _userData['followersCount'] as int,
                    followingCount: _userData['followingCount'] as int,
                    postsCount: _userData['postsCount'] as int,
                  ),
                  ProfileTabsWidget(tabController: _tabController),
                ],
              ),
            ),
            SliverFillRemaining(
              child: TabBarView(
                controller: _tabController,
                children: [
                  FriendsGridWidget(friends: _friendsList),
                  GalleryGridWidget(
                    galleryItems: _galleryItems,
                    onItemTap: (index) {
                      // Open full screen gallery view
                    },
                    onContextMenuAction: _handleGalleryAction,
                  ),
                ],
              ),
            ),
            SliverToBoxAdapter(
              child: SocialActivityCardWidget(activities: _activityList),
            ),
            SliverToBoxAdapter(
              child: Container(
                padding: EdgeInsets.all(4.w),
                child: Text(
                  'Last synced: ${_formatSyncTime(_lastSyncTime)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: _currentBottomNavIndex,
        onTap: (index) {
          setState(() => _currentBottomNavIndex = index);
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/social-hub');
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/messaging-interface');
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/app-launcher-desktop');
              break;
            case 3:
              // Already on profile screen
              break;
          }
        },
      ),
    );
  }

  String _formatSyncTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }
}

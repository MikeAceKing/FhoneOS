import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import './widgets/continue_watching_widget.dart';
import './widgets/media_player_widget.dart';
import './widgets/my_library_widget.dart';
import './widgets/streaming_services_widget.dart';

class MediaCenter extends StatefulWidget {
  const MediaCenter({super.key});

  @override
  State<MediaCenter> createState() => _MediaCenterState();
}

class _MediaCenterState extends State<MediaCenter>
    with TickerProviderStateMixin {
  int _currentBottomIndex = 2; // Media Center is at index 2
  Map<String, dynamic>? _currentPlayingMedia;
  bool _isPlayerMinimized = true;
  late TabController _tabController;

  final List<String> _tabs = ['All', 'Videos', 'Photos', 'Music'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onBottomNavTap(int index) {
    if (index != _currentBottomIndex) {
      setState(() {
        _currentBottomIndex = index;
      });

      // Navigate to different screens based on index
      switch (index) {
        case 0:
          Navigator.pushReplacementNamed(context, '/social-hub');
          break;
        case 1:
          Navigator.pushReplacementNamed(context, '/messaging-interface');
          break;
        case 2:
          // Stay on media center
          break;
        case 3:
          Navigator.pushReplacementNamed(context, '/user-profile-screen');
          break;
      }
    }
  }

  void _playMedia(Map<String, dynamic> media) {
    setState(() {
      _currentPlayingMedia = media;
      _isPlayerMinimized = false;
    });
  }

  void _minimizePlayer() {
    setState(() {
      _isPlayerMinimized = true;
    });
  }

  void _closePlayer() {
    setState(() {
      _currentPlayingMedia = null;
      _isPlayerMinimized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: 'Media Center',
        style: CustomAppBarStyle.standard,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/media-search');
            },
            icon: CustomIconWidget(
              iconName: 'search',
              color: theme.colorScheme.onSurface,
              size: 6.w,
            ),
            tooltip: 'Search Media',
          ),
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/camera-interface');
            },
            icon: CustomIconWidget(
              iconName: 'camera_alt',
              color: theme.colorScheme.onSurface,
              size: 6.w,
            ),
            tooltip: 'Camera',
          ),
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/settings-screen');
            },
            icon: CustomIconWidget(
              iconName: 'settings',
              color: theme.colorScheme.onSurface,
              size: 6.w,
            ),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Main content
          Column(
            children: [
              // Tab bar
              Container(
                color: theme.colorScheme.surface,
                child: TabBar(
                  controller: _tabController,
                  tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
                  labelColor: theme.colorScheme.primary,
                  unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
                  indicatorColor: theme.colorScheme.primary,
                  indicatorWeight: 3.0,
                  labelStyle: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  unselectedLabelStyle: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              // Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // All tab
                    _buildAllMediaContent(),
                    // Videos tab
                    _buildVideosContent(),
                    // Photos tab
                    _buildPhotosContent(),
                    // Music tab
                    _buildMusicContent(),
                  ],
                ),
              ),
            ],
          ),
          // Minimized player
          if (_currentPlayingMedia != null && _isPlayerMinimized)
            Positioned(
              bottom: 8.h,
              left: 4.w,
              right: 4.w,
              child: _buildMinimizedPlayer(),
            ),
          // Full player overlay
          if (_currentPlayingMedia != null && !_isPlayerMinimized)
            Positioned.fill(
              child: Container(
                color: Colors.black,
                child: Column(
                  children: [
                    // Player header
                    SafeArea(
                      child: Container(
                        padding: EdgeInsets.all(4.w),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: _minimizePlayer,
                              icon: CustomIconWidget(
                                iconName: 'keyboard_arrow_down',
                                color: Colors.white,
                                size: 6.w,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                _currentPlayingMedia!["title"] as String,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              onPressed: _closePlayer,
                              icon: CustomIconWidget(
                                iconName: 'close',
                                color: Colors.white,
                                size: 6.w,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Full player
                    Expanded(
                      child: MediaPlayerWidget(
                        currentMedia: _currentPlayingMedia,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: _currentBottomIndex,
        onTap: _onBottomNavTap,
      ),
    );
  }

  Widget _buildAllMediaContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 2.h),
          const ContinueWatchingWidget(),
          SizedBox(height: 4.h),
          const StreamingServicesWidget(),
          SizedBox(height: 4.h),
          const MyLibraryWidget(),
          SizedBox(height: 10.h), // Extra space for minimized player
        ],
      ),
    );
  }

  Widget _buildVideosContent() {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 2.h),
          const ContinueWatchingWidget(),
          SizedBox(height: 4.h),
          // Video-specific content
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recent Videos',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 2.h),
                // Video grid would go here
                Container(
                  height: 40.h,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomIconWidget(
                          iconName: 'video_library',
                          color: theme.colorScheme.onSurfaceVariant,
                          size: 15.w,
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'Your videos will appear here',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10.h),
        ],
      ),
    );
  }

  Widget _buildPhotosContent() {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 2.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recent Photos',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 2.h),
                Container(
                  height: 50.h,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomIconWidget(
                          iconName: 'photo_library',
                          color: theme.colorScheme.onSurfaceVariant,
                          size: 15.w,
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'Your photos will appear here',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10.h),
        ],
      ),
    );
  }

  Widget _buildMusicContent() {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 2.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Music Library',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 2.h),
                Container(
                  height: 50.h,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomIconWidget(
                          iconName: 'library_music',
                          color: theme.colorScheme.onSurfaceVariant,
                          size: 15.w,
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'Your music will appear here',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10.h),
        ],
      ),
    );
  }

  Widget _buildMinimizedPlayer() {
    final theme = Theme.of(context);

    return Container(
      height: 8.h,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8.0,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _isPlayerMinimized = false;
            });
          },
          borderRadius: BorderRadius.circular(12.0),
          child: Padding(
            padding: EdgeInsets.all(2.w),
            child: Row(
              children: [
                // Thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: CustomImageWidget(
                    imageUrl: _currentPlayingMedia!["thumbnail"] as String,
                    width: 12.w,
                    height: 12.w,
                    fit: BoxFit.cover,
                    semanticLabel:
                        _currentPlayingMedia!["semanticLabel"] as String,
                  ),
                ),
                SizedBox(width: 3.w),
                // Title and info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _currentPlayingMedia!["title"] as String,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (_currentPlayingMedia!["episode"] != null)
                        Text(
                          _currentPlayingMedia!["episode"] as String,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
                // Play/pause button
                IconButton(
                  onPressed: () {
                    // Handle play/pause
                  },
                  icon: CustomIconWidget(
                    iconName: 'pause',
                    color: theme.colorScheme.primary,
                    size: 6.w,
                  ),
                ),
                // Close button
                IconButton(
                  onPressed: _closePlayer,
                  icon: CustomIconWidget(
                    iconName: 'close',
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 5.w,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

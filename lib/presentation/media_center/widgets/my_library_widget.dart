import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class MyLibraryWidget extends StatelessWidget {
  const MyLibraryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final List<Map<String, dynamic>> libraryItems = [
      {
        "id": 1,
        "title": "Family Vacation 2024",
        "type": "video",
        "thumbnail":
            "https://images.unsplash.com/photo-1617572991869-811bd5ccfa32",
        "semanticLabel":
            "Beautiful beach vacation scene with crystal clear water and palm trees",
        "duration": "2:34",
        "date": "Dec 5, 2024",
        "size": "1.2 GB"
      },
      {
        "id": 2,
        "title": "Birthday Party",
        "type": "photo",
        "thumbnail":
            "https://img.rocket.new/generatedImages/rocket_gen_img_103f54d30-1764777109406.png",
        "semanticLabel":
            "Colorful birthday party with balloons and cake celebration",
        "duration": null,
        "date": "Nov 28, 2024",
        "size": "45 MB"
      },
      {
        "id": 3,
        "title": "Concert Recording",
        "type": "video",
        "thumbnail":
            "https://images.unsplash.com/photo-1712975836819-c2e2025cc2ad",
        "semanticLabel":
            "Live concert stage with bright lights and crowd silhouettes",
        "duration": "1:47:23",
        "date": "Nov 15, 2024",
        "size": "3.8 GB"
      },
      {
        "id": 4,
        "title": "Nature Photography",
        "type": "photo",
        "thumbnail":
            "https://images.unsplash.com/photo-1595821963941-08b265e7ae79",
        "semanticLabel":
            "Stunning mountain landscape with snow-capped peaks and forest",
        "duration": null,
        "date": "Oct 22, 2024",
        "size": "128 MB"
      },
      {
        "id": 5,
        "title": "Cooking Tutorial",
        "type": "video",
        "thumbnail":
            "https://img.rocket.new/generatedImages/rocket_gen_img_1c08394fd-1765101353847.png",
        "semanticLabel":
            "Professional kitchen setup with fresh ingredients and cooking utensils",
        "duration": "12:45",
        "date": "Oct 10, 2024",
        "size": "890 MB"
      },
      {
        "id": 6,
        "title": "Workout Session",
        "type": "video",
        "thumbnail":
            "https://img.rocket.new/generatedImages/rocket_gen_img_14e134f54-1764684036945.png",
        "semanticLabel":
            "Fitness gym environment with exercise equipment and workout area",
        "duration": "45:12",
        "date": "Sep 30, 2024",
        "size": "2.1 GB"
      }
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'My Library',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/media-search');
                    },
                    icon: CustomIconWidget(
                      iconName: 'search',
                      color: theme.colorScheme.onSurfaceVariant,
                      size: 5.w,
                    ),
                    tooltip: 'Search Library',
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/library-settings');
                    },
                    icon: CustomIconWidget(
                      iconName: 'more_vert',
                      color: theme.colorScheme.onSurfaceVariant,
                      size: 5.w,
                    ),
                    tooltip: 'Library Options',
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 2.h),
        // Storage usage indicator
        Container(
          margin: EdgeInsets.symmetric(horizontal: 4.w),
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
              width: 1.0,
            ),
          ),
          child: Row(
            children: [
              CustomIconWidget(
                iconName: 'storage',
                color: theme.colorScheme.primary,
                size: 5.w,
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Storage Used: 8.2 GB / 64 GB',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    LinearProgressIndicator(
                      value: 0.128,
                      backgroundColor:
                          theme.colorScheme.outline.withValues(alpha: 0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(
                          theme.colorScheme.primary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 3.h),
        // Library grid
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 3.w,
              mainAxisSpacing: 2.h,
              childAspectRatio: 0.8,
            ),
            itemCount: libraryItems.length,
            itemBuilder: (context, index) {
              final item = libraryItems[index];
              final isVideo = item["type"] == "video";

              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    if (isVideo) {
                      Navigator.pushNamed(context, '/video-player',
                          arguments: item);
                    } else {
                      Navigator.pushNamed(context, '/photo-viewer',
                          arguments: item);
                    }
                  },
                  onLongPress: () {
                    _showContextMenu(context, item);
                  },
                  borderRadius: BorderRadius.circular(12.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(
                        color: theme.colorScheme.outline.withValues(alpha: 0.2),
                        width: 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 8.0,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Thumbnail
                        Expanded(
                          flex: 3,
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(12.0),
                                ),
                                child: CustomImageWidget(
                                  imageUrl: item["thumbnail"] as String,
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                  semanticLabel:
                                      item["semanticLabel"] as String,
                                ),
                              ),
                              // Type indicator
                              Positioned(
                                top: 2.w,
                                right: 2.w,
                                child: Container(
                                  padding: EdgeInsets.all(1.w),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.7),
                                    borderRadius: BorderRadius.circular(4.0),
                                  ),
                                  child: CustomIconWidget(
                                    iconName: isVideo
                                        ? 'play_circle_filled'
                                        : 'photo',
                                    color: Colors.white,
                                    size: 4.w,
                                  ),
                                ),
                              ),
                              // Duration for videos
                              if (isVideo && item["duration"] != null)
                                Positioned(
                                  bottom: 2.w,
                                  right: 2.w,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 2.w,
                                      vertical: 1.w,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.black.withValues(alpha: 0.7),
                                      borderRadius: BorderRadius.circular(4.0),
                                    ),
                                    child: Text(
                                      item["duration"] as String,
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        color: Colors.white,
                                        fontSize: 10.sp,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        // Content info
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding: EdgeInsets.all(2.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  item["title"] as String,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurface,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item["date"] as String,
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        color:
                                            theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                    Text(
                                      item["size"] as String,
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        color:
                                            theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showContextMenu(BuildContext context, Map<String, dynamic> item) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color:
                    theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2.0),
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              item["title"] as String,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 3.h),
            _buildContextMenuItem(
              context: context,
              icon: 'share',
              title: 'Share',
              onTap: () {
                Navigator.pop(context);
                // Handle share
              },
            ),
            _buildContextMenuItem(
              context: context,
              icon: 'edit',
              title: 'Edit',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/media-editor', arguments: item);
              },
            ),
            _buildContextMenuItem(
              context: context,
              icon: 'playlist_add',
              title: 'Add to Playlist',
              onTap: () {
                Navigator.pop(context);
                // Handle add to playlist
              },
            ),
            _buildContextMenuItem(
              context: context,
              icon: 'delete',
              title: 'Delete',
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(context, item);
              },
              isDestructive: true,
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  Widget _buildContextMenuItem({
    required BuildContext context,
    required String icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final theme = Theme.of(context);

    return ListTile(
      leading: CustomIconWidget(
        iconName: icon,
        color: isDestructive
            ? theme.colorScheme.error
            : theme.colorScheme.onSurface,
        size: 5.w,
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: isDestructive
              ? theme.colorScheme.error
              : theme.colorScheme.onSurface,
        ),
      ),
      onTap: onTap,
    );
  }

  void _showDeleteConfirmation(
      BuildContext context, Map<String, dynamic> item) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        title: Text(
          'Delete Media',
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${item["title"]}"? This action cannot be undone.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Handle delete
            },
            child: Text(
              'Delete',
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}

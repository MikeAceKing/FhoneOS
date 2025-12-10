import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// Gallery grid widget displaying user's media with context menu
class GalleryGridWidget extends StatelessWidget {
  final List<Map<String, dynamic>> galleryItems;
  final Function(int index)? onItemTap;
  final Function(int index, String action)? onContextMenuAction;

  const GalleryGridWidget({
    super.key,
    required this.galleryItems,
    this.onItemTap,
    this.onContextMenuAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (galleryItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'photo_library_outlined',
              size: 15.w,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            SizedBox(height: 2.h),
            Text(
              'No photos yet',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: EdgeInsets.all(2.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2.w,
        mainAxisSpacing: 2.w,
        childAspectRatio: 1,
      ),
      itemCount: galleryItems.length,
      itemBuilder: (context, index) {
        final item = galleryItems[index];
        return _buildGalleryItem(context, item, index, theme);
      },
    );
  }

  Widget _buildGalleryItem(
    BuildContext context,
    Map<String, dynamic> item,
    int index,
    ThemeData theme,
  ) {
    return GestureDetector(
      onTap: () => onItemTap?.call(index),
      onLongPress: () => _showContextMenu(context, index, theme),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(2.w),
          border: Border.all(
            color: theme.colorScheme.outline,
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(2.w),
          child: CustomImageWidget(
            imageUrl: item['url'] as String,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
            semanticLabel: item['semanticLabel'] as String? ??
                "Gallery image ${index + 1}",
          ),
        ),
      ),
    );
  }

  void _showContextMenu(BuildContext context, int index, ThemeData theme) {
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(4.w)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildContextMenuItem(
                context: context,
                icon: 'share',
                label: 'Share',
                onTap: () {
                  Navigator.pop(context);
                  onContextMenuAction?.call(index, 'share');
                },
                theme: theme,
              ),
              _buildContextMenuItem(
                context: context,
                icon: 'delete',
                label: 'Delete',
                onTap: () {
                  Navigator.pop(context);
                  onContextMenuAction?.call(index, 'delete');
                },
                theme: theme,
              ),
              _buildContextMenuItem(
                context: context,
                icon: 'edit',
                label: 'Edit',
                onTap: () {
                  Navigator.pop(context);
                  onContextMenuAction?.call(index, 'edit');
                },
                theme: theme,
              ),
              _buildContextMenuItem(
                context: context,
                icon: 'account_circle',
                label: 'Set as Avatar',
                onTap: () {
                  Navigator.pop(context);
                  onContextMenuAction?.call(index, 'set_avatar');
                },
                theme: theme,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContextMenuItem({
    required BuildContext context,
    required String icon,
    required String label,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    return ListTile(
      leading: CustomIconWidget(
        iconName: icon,
        size: 6.w,
        color: theme.colorScheme.onSurface,
      ),
      title: Text(
        label,
        style: theme.textTheme.bodyLarge,
      ),
      onTap: onTap,
    );
  }
}

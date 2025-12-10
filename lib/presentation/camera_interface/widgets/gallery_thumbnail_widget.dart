import 'package:flutter/material.dart';

import '../../../core/app_export.dart';

/// Gallery thumbnail widget
/// Shows recent capture with tap to open gallery
class GalleryThumbnailWidget extends StatelessWidget {
  final String? thumbnailUrl;
  final VoidCallback onTap;

  const GalleryThumbnailWidget({
    super.key,
    this.thumbnailUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.5),
            width: 2,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: thumbnailUrl != null
              ? CustomImageWidget(
                  imageUrl: thumbnailUrl!,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  semanticLabel: 'Recent photo thumbnail from gallery',
                )
              : Center(
                  child: CustomIconWidget(
                    iconName: 'photo_library',
                    color: Colors.white.withValues(alpha: 0.7),
                    size: 28,
                  ),
                ),
        ),
      ),
    );
  }
}

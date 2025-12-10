import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class ContinueWatchingWidget extends StatelessWidget {
  const ContinueWatchingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final List<Map<String, dynamic>> continueWatchingList = [
      {
        "id": 1,
        "title": "Stranger Things",
        "episode": "S4 E7",
        "progress": 0.65,
        "duration": "52 min",
        "thumbnail":
            "https://img.rocket.new/generatedImages/rocket_gen_img_10685afe7-1764668724947.png",
        "semanticLabel":
            "Dark atmospheric scene from Stranger Things showing mysterious lights and shadows",
        "platform": "Netflix"
      },
      {
        "id": 2,
        "title": "The Mandalorian",
        "episode": "S3 E4",
        "progress": 0.23,
        "duration": "45 min",
        "thumbnail":
            "https://img.rocket.new/generatedImages/rocket_gen_img_1f76f73e6-1765098378280.png",
        "semanticLabel":
            "Futuristic space scene with metallic armor and desert landscape",
        "platform": "Disney+"
      },
      {
        "id": 3,
        "title": "The Boys",
        "episode": "S4 E2",
        "progress": 0.89,
        "duration": "58 min",
        "thumbnail":
            "https://img.rocket.new/generatedImages/rocket_gen_img_16220a722-1764695144208.png",
        "semanticLabel":
            "Urban cityscape with dramatic lighting and superhero theme elements",
        "platform": "Prime Video"
      },
      {
        "id": 4,
        "title": "House of the Dragon",
        "episode": "S2 E6",
        "progress": 0.41,
        "duration": "67 min",
        "thumbnail":
            "https://images.unsplash.com/photo-1734021046516-367412304f11",
        "semanticLabel":
            "Medieval fantasy castle with dragons flying in stormy sky",
        "platform": "HBO Max"
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
                'Continue Watching',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/continue-watching-full');
                },
                child: Text(
                  'See All',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 2.h),
        SizedBox(
          height: 25.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            itemCount: continueWatchingList.length,
            itemBuilder: (context, index) {
              final item = continueWatchingList[index];
              return Container(
                width: 70.w,
                margin: EdgeInsets.only(right: 4.w),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, '/video-player',
                          arguments: item);
                    },
                    borderRadius: BorderRadius.circular(12.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(12.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8.0,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Thumbnail with play overlay
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
                                // Play button overlay
                                Positioned.fill(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.black.withValues(alpha: 0.3),
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(12.0),
                                      ),
                                    ),
                                    child: Center(
                                      child: Container(
                                        width: 12.w,
                                        height: 12.w,
                                        decoration: BoxDecoration(
                                          color: Colors.white
                                              .withValues(alpha: 0.9),
                                          shape: BoxShape.circle,
                                        ),
                                        child: CustomIconWidget(
                                          iconName: 'play_arrow',
                                          color: Colors.black,
                                          size: 6.w,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                // Progress indicator
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    height: 4.0,
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.black.withValues(alpha: 0.3),
                                    ),
                                    child: FractionallySizedBox(
                                      alignment: Alignment.centerLeft,
                                      widthFactor: item["progress"] as double,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.primary,
                                        ),
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
                              padding: EdgeInsets.all(3.w),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item["title"] as String,
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                          color: theme.colorScheme.onSurface,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 0.5.h),
                                      Text(
                                        item["episode"] as String,
                                        style:
                                            theme.textTheme.bodySmall?.copyWith(
                                          color: theme
                                              .colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        item["platform"] as String,
                                        style:
                                            theme.textTheme.bodySmall?.copyWith(
                                          color: theme.colorScheme.primary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        item["duration"] as String,
                                        style:
                                            theme.textTheme.bodySmall?.copyWith(
                                          color: theme
                                              .colorScheme.onSurfaceVariant,
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
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

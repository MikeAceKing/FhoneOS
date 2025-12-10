import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';
import '../../../widgets/custom_image_widget.dart';

class StreamingServicesWidget extends StatelessWidget {
  const StreamingServicesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final List<Map<String, dynamic>> streamingServices = [
      {
        "id": 1,
        "name": "Netflix",
        "logo":
            "https://img.rocket.new/generatedImages/rocket_gen_img_1a52c1897-1764720017896.png",
        "semanticLabel": "Netflix logo in red text on black background",
        "color": Color(0xFFE50914),
        "route": "/netflix-webview"
      },
      {
        "id": 2,
        "name": "YouTube",
        "logo":
            "https://img.rocket.new/generatedImages/rocket_gen_img_1f28b7127-1764873748358.png",
        "semanticLabel": "YouTube play button logo in red and white colors",
        "color": Color(0xFFFF0000),
        "route": "/youtube-webview"
      },
      {
        "id": 3,
        "name": "Spotify",
        "logo":
            "https://img.rocket.new/generatedImages/rocket_gen_img_1d71ebfa2-1764751041051.png",
        "semanticLabel": "Spotify logo with green circular icon and black text",
        "color": Color(0xFF1DB954),
        "route": "/spotify-webview"
      },
      {
        "id": 4,
        "name": "Prime Video",
        "logo":
            "https://img.rocket.new/generatedImages/rocket_gen_img_12a1dab06-1765088832935.png",
        "semanticLabel": "Amazon Prime Video logo in blue and white colors",
        "color": Color(0xFF00A8E1),
        "route": "/prime-webview"
      },
      {
        "id": 5,
        "name": "Disney+",
        "logo":
            "https://img.rocket.new/generatedImages/rocket_gen_img_1829e958d-1764662431997.png",
        "semanticLabel": "Disney Plus logo with blue background and white text",
        "color": Color(0xFF113CCF),
        "route": "/disney-webview"
      },
      {
        "id": 6,
        "name": "Hulu",
        "logo":
            "https://img.rocket.new/generatedImages/rocket_gen_img_1dc2cca90-1765205567661.png",
        "semanticLabel": "Hulu logo in green text on dark background",
        "color": Color(0xFF1CE783),
        "route": "/hulu-webview"
      }
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Text(
            'Streaming Services',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        SizedBox(height: 2.h),
        SizedBox(
          height: 20.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            itemCount: streamingServices.length,
            itemBuilder: (context, index) {
              final service = streamingServices[index];
              return Container(
                width: 30.w,
                margin: EdgeInsets.only(right: 3.w),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, service["route"] as String);
                    },
                    borderRadius: BorderRadius.circular(12.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(
                          color:
                              theme.colorScheme.outline.withValues(alpha: 0.2),
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
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 15.w,
                            height: 15.w,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.0),
                              color: (service["color"] as Color)
                                  .withValues(alpha: 0.1),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: CustomImageWidget(
                                imageUrl: service["logo"] as String,
                                width: 15.w,
                                height: 15.w,
                                fit: BoxFit.cover,
                                semanticLabel:
                                    service["semanticLabel"] as String,
                              ),
                            ),
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            service["name"] as String,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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

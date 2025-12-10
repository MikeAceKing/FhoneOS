import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class MediaPlayerWidget extends StatefulWidget {
  final Map<String, dynamic>? currentMedia;

  const MediaPlayerWidget({
    super.key,
    this.currentMedia,
  });

  @override
  State<MediaPlayerWidget> createState() => _MediaPlayerWidgetState();
}

class _MediaPlayerWidgetState extends State<MediaPlayerWidget> {
  bool _isPlaying = false;
  bool _isFullscreen = false;
  double _currentPosition = 0.0;
  double _totalDuration = 100.0;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    if (widget.currentMedia != null) {
      _initializePlayer();
    }
  }

  void _initializePlayer() {
    // Initialize media player with current media
    setState(() {
      _totalDuration =
          _parseDuration(widget.currentMedia?["duration"] ?? "0:00");
    });
  }

  double _parseDuration(String duration) {
    final parts = duration.split(':');
    if (parts.length == 2) {
      return (int.tryParse(parts[0]) ?? 0) * 60.0 +
          (int.tryParse(parts[1]) ?? 0);
    } else if (parts.length == 3) {
      return (int.tryParse(parts[0]) ?? 0) * 3600.0 +
          (int.tryParse(parts[1]) ?? 0) * 60.0 +
          (int.tryParse(parts[2]) ?? 0);
    }
    return 0.0;
  }

  String _formatDuration(double seconds) {
    final int hours = (seconds / 3600).floor();
    final int minutes = ((seconds % 3600) / 60).floor();
    final int secs = (seconds % 60).floor();

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
  }

  void _togglePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
    });
    // Handle actual play/pause logic here
  }

  void _toggleFullscreen() {
    setState(() {
      _isFullscreen = !_isFullscreen;
    });
    // Handle fullscreen logic here
  }

  void _seekTo(double position) {
    setState(() {
      _currentPosition = position;
    });
    // Handle seek logic here
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (widget.currentMedia == null) {
      return _buildEmptyPlayer(theme);
    }

    return Container(
      width: double.infinity,
      height: _isFullscreen ? 100.h : 30.h,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: _isFullscreen ? null : BorderRadius.circular(12.0),
      ),
      child: Stack(
        children: [
          // Video/Media content
          Positioned.fill(
            child: ClipRRect(
              borderRadius: _isFullscreen
                  ? BorderRadius.zero
                  : BorderRadius.circular(12.0),
              child: CustomImageWidget(
                imageUrl: widget.currentMedia!["thumbnail"] as String,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                semanticLabel: widget.currentMedia!["semanticLabel"] as String,
              ),
            ),
          ),
          // Controls overlay
          if (_showControls)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.3),
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.7),
                    ],
                  ),
                  borderRadius:
                      _isFullscreen ? null : BorderRadius.circular(12.0),
                ),
                child: Column(
                  children: [
                    // Top controls
                    if (_isFullscreen)
                      Padding(
                        padding: EdgeInsets.all(4.w),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: _toggleFullscreen,
                              icon: CustomIconWidget(
                                iconName: 'fullscreen_exit',
                                color: Colors.white,
                                size: 6.w,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                widget.currentMedia!["title"] as String,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                // Handle more options
                              },
                              icon: CustomIconWidget(
                                iconName: 'more_vert',
                                color: Colors.white,
                                size: 6.w,
                              ),
                            ),
                          ],
                        ),
                      ),
                    // Center play button
                    Expanded(
                      child: Center(
                        child: GestureDetector(
                          onTap: _togglePlayPause,
                          child: Container(
                            width: 15.w,
                            height: 15.w,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.9),
                              shape: BoxShape.circle,
                            ),
                            child: CustomIconWidget(
                              iconName: _isPlaying ? 'pause' : 'play_arrow',
                              color: Colors.black,
                              size: 8.w,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Bottom controls
                    Padding(
                      padding: EdgeInsets.all(4.w),
                      child: Column(
                        children: [
                          // Progress bar
                          Row(
                            children: [
                              Text(
                                _formatDuration(_currentPosition),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 2.w),
                              Expanded(
                                child: SliderTheme(
                                  data: SliderTheme.of(context).copyWith(
                                    activeTrackColor: theme.colorScheme.primary,
                                    inactiveTrackColor:
                                        Colors.white.withValues(alpha: 0.3),
                                    thumbColor: theme.colorScheme.primary,
                                    overlayColor: theme.colorScheme.primary
                                        .withValues(alpha: 0.2),
                                    trackHeight: 2.0,
                                    thumbShape: const RoundSliderThumbShape(
                                        enabledThumbRadius: 6.0),
                                  ),
                                  child: Slider(
                                    value: _currentPosition,
                                    max: _totalDuration,
                                    onChanged: _seekTo,
                                  ),
                                ),
                              ),
                              SizedBox(width: 2.w),
                              Text(
                                _formatDuration(_totalDuration),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 2.h),
                          // Control buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              IconButton(
                                onPressed: () {
                                  // Handle previous
                                },
                                icon: CustomIconWidget(
                                  iconName: 'skip_previous',
                                  color: Colors.white,
                                  size: 6.w,
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  // Handle rewind
                                },
                                icon: CustomIconWidget(
                                  iconName: 'replay_10',
                                  color: Colors.white,
                                  size: 6.w,
                                ),
                              ),
                              IconButton(
                                onPressed: _togglePlayPause,
                                icon: CustomIconWidget(
                                  iconName: _isPlaying ? 'pause' : 'play_arrow',
                                  color: Colors.white,
                                  size: 8.w,
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  // Handle fast forward
                                },
                                icon: CustomIconWidget(
                                  iconName: 'forward_10',
                                  color: Colors.white,
                                  size: 6.w,
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  // Handle next
                                },
                                icon: CustomIconWidget(
                                  iconName: 'skip_next',
                                  color: Colors.white,
                                  size: 6.w,
                                ),
                              ),
                            ],
                          ),
                          if (!_isFullscreen) SizedBox(height: 1.h),
                          if (!_isFullscreen)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        // Handle volume
                                      },
                                      icon: CustomIconWidget(
                                        iconName: 'volume_up',
                                        color: Colors.white,
                                        size: 5.w,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        // Handle cast
                                      },
                                      icon: CustomIconWidget(
                                        iconName: 'cast',
                                        color: Colors.white,
                                        size: 5.w,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        // Handle picture in picture
                                      },
                                      icon: CustomIconWidget(
                                        iconName: 'picture_in_picture_alt',
                                        color: Colors.white,
                                        size: 5.w,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: _toggleFullscreen,
                                      icon: CustomIconWidget(
                                        iconName: 'fullscreen',
                                        color: Colors.white,
                                        size: 5.w,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          // Tap to show/hide controls
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _showControls = !_showControls;
                });
              },
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyPlayer(ThemeData theme) {
    return Container(
      width: double.infinity,
      height: 30.h,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
          width: 1.0,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'play_circle_outline',
            color: theme.colorScheme.onSurfaceVariant,
            size: 15.w,
          ),
          SizedBox(height: 2.h),
          Text(
            'Select media to play',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Choose from your library or streaming services',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

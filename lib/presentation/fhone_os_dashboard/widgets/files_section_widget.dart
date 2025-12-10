import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

/// Files Section Widget
/// Displays recent files
class FilesSectionWidget extends StatelessWidget {
  const FilesSectionWidget({super.key});

  static final List<Map<String, dynamic>> _recentFiles = [
    {
      'id': '1',
      'name': 'meeting-notes.txt',
      'size': '12 KB',
      'modified': 'Today',
      'type': 'doc',
      'icon': Icons.description_outlined,
    },
    {
      'id': '2',
      'name': 'screenshot-rocket.png',
      'size': '420 KB',
      'modified': 'Yesterday',
      'type': 'image',
      'icon': Icons.image_outlined,
    },
    {
      'id': '3',
      'name': 'demo-call-recording.mp4',
      'size': '18 MB',
      'modified': '3 days ago',
      'type': 'video',
      'icon': Icons.videocam_outlined,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: const Color(0xFF020617),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Color(0xFF1E293B)),
      ),
      child: Padding(
        padding: EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recente bestanden',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 0.5.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed:
                      () => Navigator.pushNamed(context, '/camera-interface'),
                  child: Text(
                    'Open file manager',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: const Color(0xFF6366F1),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 0.5.h),
            Column(
              children:
                  _recentFiles
                      .map(
                        (file) => Padding(
                          padding: EdgeInsets.symmetric(vertical: 0.4.h),
                          child: _FileRow(file: file),
                        ),
                      )
                      .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _FileRow extends StatelessWidget {
  final Map<String, dynamic> file;

  const _FileRow({required this.file});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(file['icon'] as IconData, size: 18, color: Colors.white70),
        SizedBox(width: 2.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                file['name'] as String,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 13.sp, color: Colors.white),
              ),
              Text(
                '${file['size']} · ${file['modified']}',
                style: TextStyle(fontSize: 11.sp, color: Colors.white54),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

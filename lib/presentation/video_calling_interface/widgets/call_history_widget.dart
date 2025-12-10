import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import './active_call_widget.dart';

/// Call history screen with chronological list and swipe actions
class CallHistoryWidget extends StatefulWidget {
  const CallHistoryWidget({super.key});

  @override
  State<CallHistoryWidget> createState() => _CallHistoryWidgetState();
}

class _CallHistoryWidgetState extends State<CallHistoryWidget> {
  // Mock call history data
  final List<Map<String, dynamic>> _callHistory = [
    {
      "id": 1,
      "contact": {
        "name": "Sarah Johnson",
        "avatar":
            "https://img.rocket.new/generatedImages/rocket_gen_img_1caec3487-1765235228493.png",
        "semanticLabel":
            "Profile photo of a woman with blonde hair and blue eyes, wearing a white blouse",
      },
      "type": "outgoing",
      "isVideo": true,
      "duration": "12:34",
      "timestamp": DateTime.now().subtract(const Duration(hours: 2)),
      "status": "completed",
    },
    {
      "id": 2,
      "contact": {
        "name": "Michael Chen",
        "avatar":
            "https://img.rocket.new/generatedImages/rocket_gen_img_1907e5900-1763296402708.png",
        "semanticLabel":
            "Profile photo of an Asian man with short black hair, wearing glasses and a blue shirt",
      },
      "type": "incoming",
      "isVideo": false,
      "duration": "05:21",
      "timestamp": DateTime.now().subtract(const Duration(hours: 5)),
      "status": "completed",
    },
    {
      "id": 3,
      "contact": {
        "name": "Emily Rodriguez",
        "avatar":
            "https://img.rocket.new/generatedImages/rocket_gen_img_1e20f0ace-1763299053725.png",
        "semanticLabel":
            "Profile photo of a Hispanic woman with long brown hair, wearing a red top",
      },
      "type": "missed",
      "isVideo": true,
      "duration": "00:00",
      "timestamp": DateTime.now().subtract(const Duration(days: 1)),
      "status": "missed",
    },
    {
      "id": 4,
      "contact": {
        "name": "David Kim",
        "avatar":
            "https://img.rocket.new/generatedImages/rocket_gen_img_17fea9682-1764690565935.png",
        "semanticLabel":
            "Profile photo of a man with short dark hair and a beard, wearing a gray hoodie",
      },
      "type": "outgoing",
      "isVideo": false,
      "duration": "23:45",
      "timestamp": DateTime.now().subtract(const Duration(days: 1, hours: 3)),
      "status": "completed",
    },
    {
      "id": 5,
      "contact": {
        "name": "Jessica Martinez",
        "avatar":
            "https://images.unsplash.com/photo-1729073723017-a9578371518b",
        "semanticLabel":
            "Profile photo of a woman with curly black hair, wearing a yellow dress",
      },
      "type": "incoming",
      "isVideo": true,
      "duration": "08:12",
      "timestamp": DateTime.now().subtract(const Duration(days: 2)),
      "status": "completed",
    },
    {
      "id": 6,
      "contact": {
        "name": "Ryan O'Connor",
        "avatar":
            "https://img.rocket.new/generatedImages/rocket_gen_img_11c451189-1764791200984.png",
        "semanticLabel":
            "Profile photo of a man with red hair and freckles, wearing a green polo shirt",
      },
      "type": "missed",
      "isVideo": false,
      "duration": "00:00",
      "timestamp": DateTime.now().subtract(const Duration(days: 3)),
      "status": "missed",
    },
  ];

  void _callBack(Map<String, dynamic> callRecord) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ActiveCallWidget(
          contact: callRecord["contact"] as Map<String, dynamic>,
          isVideoCall: callRecord["isVideo"] as bool,
        ),
      ),
    );
  }

  void _sendMessage(Map<String, dynamic> callRecord) {
    Navigator.pushNamed(context, '/messaging-interface');
  }

  void _deleteCall(int id) {
    setState(() {
      _callHistory.removeWhere((call) => call["id"] == id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Call deleted'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _blockContact(Map<String, dynamic> callRecord) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Block Contact',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
        ),
        content: Text(
          'Are you sure you want to block ${(callRecord["contact"] as Map<String, dynamic>)["name"]}?',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'Blocked ${(callRecord["contact"] as Map<String, dynamic>)["name"]}'),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
            },
            child: Text(
              'Block',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays == 0) {
      final hour = timestamp.hour;
      final minute = timestamp.minute.toString().padLeft(2, '0');
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return '$displayHour:$minute $period';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${timestamp.month}/${timestamp.day}/${timestamp.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_callHistory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'call',
              color: theme.colorScheme.onSurfaceVariant,
              size: 64,
            ),
            SizedBox(height: 2.h),
            Text(
              'No call history',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'Your call history will appear here',
              style: theme.textTheme.bodyMedium?.copyWith(
                color:
                    theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      itemCount: _callHistory.length,
      itemBuilder: (context, index) {
        final callRecord = _callHistory[index];
        return _buildCallHistoryItem(callRecord, theme);
      },
    );
  }

  Widget _buildCallHistoryItem(
      Map<String, dynamic> callRecord, ThemeData theme) {
    final contact = callRecord["contact"] as Map<String, dynamic>;
    final type = callRecord["type"] as String;
    final isVideo = callRecord["isVideo"] as bool;
    final duration = callRecord["duration"] as String;
    final timestamp = callRecord["timestamp"] as DateTime;
    final status = callRecord["status"] as String;

    final isMissed = type == "missed";
    final isIncoming = type == "incoming";
    final isOutgoing = type == "outgoing";

    return Slidable(
      key: ValueKey(callRecord["id"]),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => _callBack(callRecord),
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: Colors.white,
            icon: Icons.call,
            label: 'Call',
          ),
          SlidableAction(
            onPressed: (_) => _sendMessage(callRecord),
            backgroundColor: theme.colorScheme.tertiary,
            foregroundColor: Colors.white,
            icon: Icons.message,
            label: 'Message',
          ),
          SlidableAction(
            onPressed: (_) => _deleteCall(callRecord["id"] as int),
            backgroundColor: theme.colorScheme.error,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
          ),
          SlidableAction(
            onPressed: (_) => _blockContact(callRecord),
            backgroundColor: Colors.grey[800]!,
            foregroundColor: Colors.white,
            icon: Icons.block,
            label: 'Block',
          ),
        ],
      ),
      child: Container(
        margin: EdgeInsets.only(bottom: 1.h),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isMissed
                ? theme.colorScheme.error.withValues(alpha: 0.3)
                : theme.colorScheme.outline.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          leading: Container(
            width: 12.w,
            height: 12.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isMissed
                    ? theme.colorScheme.error
                    : theme.colorScheme.outline,
                width: 2,
              ),
            ),
            child: ClipOval(
              child: CustomImageWidget(
                imageUrl: contact["avatar"] as String,
                width: 12.w,
                height: 12.w,
                fit: BoxFit.cover,
                semanticLabel: contact["semanticLabel"] as String,
              ),
            ),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  contact["name"] as String,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              CustomIconWidget(
                iconName: isVideo ? 'videocam' : 'call',
                color: isMissed
                    ? theme.colorScheme.error
                    : theme.colorScheme.onSurfaceVariant,
                size: 18,
              ),
            ],
          ),
          subtitle: Row(
            children: [
              CustomIconWidget(
                iconName: isIncoming
                    ? 'call_received'
                    : isOutgoing
                        ? 'call_made'
                        : 'call_missed',
                color: isMissed
                    ? theme.colorScheme.error
                    : theme.colorScheme.onSurfaceVariant,
                size: 14,
              ),
              SizedBox(width: 1.w),
              Text(
                status == "missed" ? "Missed" : duration,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isMissed
                      ? theme.colorScheme.error
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(width: 2.w),
              Text(
                _formatTimestamp(timestamp),
                style: theme.textTheme.bodySmall?.copyWith(
                  color:
                      theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          trailing: IconButton(
            icon: CustomIconWidget(
              iconName: 'info_outline',
              color: theme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
            onPressed: () => _showCallDetails(callRecord),
          ),
        ),
      ),
    );
  }

  void _showCallDetails(Map<String, dynamic> callRecord) {
    final theme = Theme.of(context);
    final contact = callRecord["contact"] as Map<String, dynamic>;

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color:
                    theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 3.h),
            Container(
              width: 20.w,
              height: 20.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: theme.colorScheme.primary,
                  width: 2,
                ),
              ),
              child: ClipOval(
                child: CustomImageWidget(
                  imageUrl: contact["avatar"] as String,
                  width: 20.w,
                  height: 20.w,
                  fit: BoxFit.cover,
                  semanticLabel: contact["semanticLabel"] as String,
                ),
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              contact["name"] as String,
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              '${callRecord["type"]} ${callRecord["isVideo"] ? "video" : "audio"} call',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 3.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(
                  icon: 'videocam',
                  label: 'Video Call',
                  onPressed: () {
                    Navigator.pop(context);
                    _callBack(callRecord);
                  },
                  theme: theme,
                ),
                _buildActionButton(
                  icon: 'call',
                  label: 'Audio Call',
                  onPressed: () {
                    Navigator.pop(context);
                    _callBack(callRecord);
                  },
                  theme: theme,
                ),
                _buildActionButton(
                  icon: 'message',
                  label: 'Message',
                  onPressed: () {
                    Navigator.pop(context);
                    _sendMessage(callRecord);
                  },
                  theme: theme,
                ),
              ],
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String icon,
    required String label,
    required VoidCallback onPressed,
    required ThemeData theme,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14.w,
          height: 14.w,
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: CustomIconWidget(
              iconName: icon,
              color: theme.colorScheme.primary,
              size: 24,
            ),
            onPressed: onPressed,
          ),
        ),
        SizedBox(height: 0.5.h),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}

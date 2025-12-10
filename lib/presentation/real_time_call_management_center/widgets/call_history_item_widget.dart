import 'package:flutter/material.dart';
import '../../../models/call.dart';
import 'package:timeago/timeago.dart' as timeago;

class CallHistoryItemWidget extends StatelessWidget {
  final Call call;
  final VoidCallback onCallBack;

  const CallHistoryItemWidget({
    super.key,
    required this.call,
    required this.onCallBack,
  });

  @override
  Widget build(BuildContext context) {
    final phoneNumber =
        call.callType == CallType.incoming ? call.fromNumber : call.toNumber;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: _getCallTypeColor().withAlpha(26),
        child: Icon(
          _getCallTypeIcon(),
          color: _getCallTypeColor(),
          size: 24,
        ),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              phoneNumber,
              style: TextStyle(
                fontSize: 16,
                fontWeight: call.isMissed ? FontWeight.w700 : FontWeight.w600,
                color: call.isMissed ? Colors.red : Colors.black87,
              ),
            ),
          ),
          if (call.isRecorded)
            const Padding(
              padding: EdgeInsets.only(left: 4),
              child: Icon(
                Icons.fiber_manual_record,
                size: 12,
                color: Colors.red,
              ),
            ),
        ],
      ),
      subtitle: Row(
        children: [
          Text(
            _getCallTypeLabel(),
            style: TextStyle(
              fontSize: 13,
              color: call.isMissed ? Colors.red : Colors.grey[600],
            ),
          ),
          if (call.isCompleted) ...[
            Text(
              ' • ${call.formattedDuration}',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
          ],
          Text(
            ' • ${timeago.format(call.startedAt, locale: 'en_short')}',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
      trailing: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF4CAF50).withAlpha(26),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: const Icon(
            Icons.phone,
            color: Color(0xFF4CAF50),
          ),
          onPressed: onCallBack,
        ),
      ),
    );
  }

  IconData _getCallTypeIcon() {
    switch (call.callType) {
      case CallType.incoming:
        return Icons.call_received;
      case CallType.outgoing:
        return Icons.call_made;
      case CallType.missed:
        return Icons.call_missed;
    }
  }

  Color _getCallTypeColor() {
    if (call.isMissed) return Colors.red;

    switch (call.callType) {
      case CallType.incoming:
        return const Color(0xFF4CAF50);
      case CallType.outgoing:
        return Colors.blue;
      case CallType.missed:
        return Colors.red;
    }
  }

  String _getCallTypeLabel() {
    if (call.isMissed) return 'Missed call';

    switch (call.callType) {
      case CallType.incoming:
        return 'Incoming';
      case CallType.outgoing:
        return 'Outgoing';
      case CallType.missed:
        return 'Missed';
    }
  }
}

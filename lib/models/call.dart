enum CallType {
  incoming,
  outgoing,
  missed,
}

enum CallStatus {
  ringing,
  inProgress,
  completed,
  missed,
  declined,
  failed,
  voicemail,
}

class Call {
  final String id;
  final String userId;
  final String accountId;
  final String? phoneNumberId;
  final String? contactId;
  final CallType callType;
  final CallStatus callStatus;
  final String fromNumber;
  final String toNumber;
  final int durationSeconds;
  final double? networkQuality;
  final String? externalCallId;
  final String? conferenceSid;
  final bool isRecorded;
  final String? recordingUrl;
  final DateTime startedAt;
  final DateTime? answeredAt;
  final DateTime? endedAt;
  final DateTime createdAt;

  Call({
    required this.id,
    required this.userId,
    required this.accountId,
    this.phoneNumberId,
    this.contactId,
    required this.callType,
    this.callStatus = CallStatus.ringing,
    required this.fromNumber,
    required this.toNumber,
    this.durationSeconds = 0,
    this.networkQuality,
    this.externalCallId,
    this.conferenceSid,
    this.isRecorded = false,
    this.recordingUrl,
    required this.startedAt,
    this.answeredAt,
    this.endedAt,
    required this.createdAt,
  });

  factory Call.fromJson(Map<String, dynamic> json) {
    return Call(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      accountId: json['account_id'] as String,
      phoneNumberId: json['phone_number_id'] as String?,
      contactId: json['contact_id'] as String?,
      callType: _parseCallType(json['call_type'] as String),
      callStatus: _parseCallStatus(json['call_status'] as String),
      fromNumber: json['from_number'] as String,
      toNumber: json['to_number'] as String,
      durationSeconds: json['duration_seconds'] as int? ?? 0,
      networkQuality: json['network_quality'] != null
          ? (json['network_quality'] as num).toDouble()
          : null,
      externalCallId: json['external_call_id'] as String?,
      conferenceSid: json['conference_sid'] as String?,
      isRecorded: json['is_recorded'] as bool? ?? false,
      recordingUrl: json['recording_url'] as String?,
      startedAt: DateTime.parse(json['started_at'] as String),
      answeredAt: json['answered_at'] != null
          ? DateTime.parse(json['answered_at'] as String)
          : null,
      endedAt: json['ended_at'] != null
          ? DateTime.parse(json['ended_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  static CallType _parseCallType(String type) {
    switch (type) {
      case 'incoming':
        return CallType.incoming;
      case 'outgoing':
        return CallType.outgoing;
      case 'missed':
        return CallType.missed;
      default:
        return CallType.outgoing;
    }
  }

  static CallStatus _parseCallStatus(String status) {
    switch (status) {
      case 'ringing':
        return CallStatus.ringing;
      case 'in_progress':
        return CallStatus.inProgress;
      case 'completed':
        return CallStatus.completed;
      case 'missed':
        return CallStatus.missed;
      case 'declined':
        return CallStatus.declined;
      case 'failed':
        return CallStatus.failed;
      case 'voicemail':
        return CallStatus.voicemail;
      default:
        return CallStatus.ringing;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'account_id': accountId,
      'phone_number_id': phoneNumberId,
      'contact_id': contactId,
      'call_type': callType.name,
      'call_status': _callStatusToString(callStatus),
      'from_number': fromNumber,
      'to_number': toNumber,
      'duration_seconds': durationSeconds,
      'network_quality': networkQuality,
      'external_call_id': externalCallId,
      'conference_sid': conferenceSid,
      'is_recorded': isRecorded,
      'recording_url': recordingUrl,
      'started_at': startedAt.toIso8601String(),
      'answered_at': answeredAt?.toIso8601String(),
      'ended_at': endedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  String _callStatusToString(CallStatus status) {
    switch (status) {
      case CallStatus.inProgress:
        return 'in_progress';
      default:
        return status.name;
    }
  }

  Call copyWith({
    String? id,
    String? userId,
    String? accountId,
    String? phoneNumberId,
    String? contactId,
    CallType? callType,
    CallStatus? callStatus,
    String? fromNumber,
    String? toNumber,
    int? durationSeconds,
    double? networkQuality,
    String? externalCallId,
    String? conferenceSid,
    bool? isRecorded,
    String? recordingUrl,
    DateTime? startedAt,
    DateTime? answeredAt,
    DateTime? endedAt,
    DateTime? createdAt,
  }) {
    return Call(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      accountId: accountId ?? this.accountId,
      phoneNumberId: phoneNumberId ?? this.phoneNumberId,
      contactId: contactId ?? this.contactId,
      callType: callType ?? this.callType,
      callStatus: callStatus ?? this.callStatus,
      fromNumber: fromNumber ?? this.fromNumber,
      toNumber: toNumber ?? this.toNumber,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      networkQuality: networkQuality ?? this.networkQuality,
      externalCallId: externalCallId ?? this.externalCallId,
      conferenceSid: conferenceSid ?? this.conferenceSid,
      isRecorded: isRecorded ?? this.isRecorded,
      recordingUrl: recordingUrl ?? this.recordingUrl,
      startedAt: startedAt ?? this.startedAt,
      answeredAt: answeredAt ?? this.answeredAt,
      endedAt: endedAt ?? this.endedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String get formattedDuration {
    final hours = durationSeconds ~/ 3600;
    final minutes = (durationSeconds % 3600) ~/ 60;
    final seconds = durationSeconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  bool get isActive =>
      callStatus == CallStatus.ringing || callStatus == CallStatus.inProgress;
  bool get isCompleted => callStatus == CallStatus.completed;
  bool get isMissed => callStatus == CallStatus.missed;
}

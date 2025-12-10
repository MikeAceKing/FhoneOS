class MessageThread {
  final String id;
  final String userId;
  final String platform;
  final String platformThreadId;
  final String participantName;
  final String participantIdentifier;
  final String? lastMessagePreview;
  final DateTime? lastMessageAt;
  final int unreadCount;
  final bool isArchived;
  final bool isPinned;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MessageThread({
    required this.id,
    required this.userId,
    required this.platform,
    required this.platformThreadId,
    required this.participantName,
    required this.participantIdentifier,
    this.lastMessagePreview,
    this.lastMessageAt,
    this.unreadCount = 0,
    this.isArchived = false,
    this.isPinned = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MessageThread.fromJson(Map<String, dynamic> json) {
    return MessageThread(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      platform: json['platform'] as String,
      platformThreadId: json['platform_thread_id'] as String,
      participantName: json['participant_name'] as String,
      participantIdentifier: json['participant_identifier'] as String,
      lastMessagePreview: json['last_message_preview'] as String?,
      lastMessageAt: json['last_message_at'] != null
          ? DateTime.parse(json['last_message_at'] as String)
          : null,
      unreadCount: json['unread_count'] as int? ?? 0,
      isArchived: json['is_archived'] as bool? ?? false,
      isPinned: json['is_pinned'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'platform': platform,
      'platform_thread_id': platformThreadId,
      'participant_name': participantName,
      'participant_identifier': participantIdentifier,
      'last_message_preview': lastMessagePreview,
      'last_message_at': lastMessageAt?.toIso8601String(),
      'unread_count': unreadCount,
      'is_archived': isArchived,
      'is_pinned': isPinned,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

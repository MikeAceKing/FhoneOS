class Message {
  final String id;
  final String threadId;
  final String userId;
  final String platform;
  final String? platformMessageId;
  final String direction;
  final String senderName;
  final String senderIdentifier;
  final String? recipientName;
  final String? recipientIdentifier;
  final String content;
  final String messageStatus;
  final bool isRead;
  final DateTime sentAt;
  final DateTime? deliveredAt;
  final DateTime? readAt;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;

  const Message({
    required this.id,
    required this.threadId,
    required this.userId,
    required this.platform,
    this.platformMessageId,
    required this.direction,
    required this.senderName,
    required this.senderIdentifier,
    this.recipientName,
    this.recipientIdentifier,
    required this.content,
    required this.messageStatus,
    this.isRead = false,
    required this.sentAt,
    this.deliveredAt,
    this.readAt,
    this.metadata,
    required this.createdAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      threadId: json['thread_id'] as String,
      userId: json['user_id'] as String,
      platform: json['platform'] as String,
      platformMessageId: json['platform_message_id'] as String?,
      direction: json['direction'] as String,
      senderName: json['sender_name'] as String,
      senderIdentifier: json['sender_identifier'] as String,
      recipientName: json['recipient_name'] as String?,
      recipientIdentifier: json['recipient_identifier'] as String?,
      content: json['content'] as String,
      messageStatus: json['message_status'] as String,
      isRead: json['is_read'] as bool? ?? false,
      sentAt: DateTime.parse(json['sent_at'] as String),
      deliveredAt: json['delivered_at'] != null
          ? DateTime.parse(json['delivered_at'] as String)
          : null,
      readAt: json['read_at'] != null
          ? DateTime.parse(json['read_at'] as String)
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'thread_id': threadId,
      'user_id': userId,
      'platform': platform,
      'platform_message_id': platformMessageId,
      'direction': direction,
      'sender_name': senderName,
      'sender_identifier': senderIdentifier,
      'recipient_name': recipientName,
      'recipient_identifier': recipientIdentifier,
      'content': content,
      'message_status': messageStatus,
      'is_read': isRead,
      'sent_at': sentAt.toIso8601String(),
      'delivered_at': deliveredAt?.toIso8601String(),
      'read_at': readAt?.toIso8601String(),
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class Conversation {
  final String id;
  final String userId;
  final String accountId;
  final String? phoneNumberId;
  final String? contactId;
  final String? conversationName;
  final bool isGroup;
  final int participantCount;
  final String? lastMessageText;
  final DateTime? lastMessageAt;
  final int unreadCount;
  final bool isArchived;
  final bool isMuted;
  final bool isPinned;
  final DateTime createdAt;
  final DateTime updatedAt;

  Conversation({
    required this.id,
    required this.userId,
    required this.accountId,
    this.phoneNumberId,
    this.contactId,
    this.conversationName,
    this.isGroup = false,
    this.participantCount = 1,
    this.lastMessageText,
    this.lastMessageAt,
    this.unreadCount = 0,
    this.isArchived = false,
    this.isMuted = false,
    this.isPinned = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      accountId: json['account_id'] as String,
      phoneNumberId: json['phone_number_id'] as String?,
      contactId: json['contact_id'] as String?,
      conversationName: json['conversation_name'] as String?,
      isGroup: json['is_group'] as bool? ?? false,
      participantCount: json['participant_count'] as int? ?? 1,
      lastMessageText: json['last_message_text'] as String?,
      lastMessageAt: json['last_message_at'] != null
          ? DateTime.parse(json['last_message_at'] as String)
          : null,
      unreadCount: json['unread_count'] as int? ?? 0,
      isArchived: json['is_archived'] as bool? ?? false,
      isMuted: json['is_muted'] as bool? ?? false,
      isPinned: json['is_pinned'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'account_id': accountId,
      'phone_number_id': phoneNumberId,
      'contact_id': contactId,
      'conversation_name': conversationName,
      'is_group': isGroup,
      'participant_count': participantCount,
      'last_message_text': lastMessageText,
      'last_message_at': lastMessageAt?.toIso8601String(),
      'unread_count': unreadCount,
      'is_archived': isArchived,
      'is_muted': isMuted,
      'is_pinned': isPinned,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Conversation copyWith({
    String? id,
    String? userId,
    String? accountId,
    String? phoneNumberId,
    String? contactId,
    String? conversationName,
    bool? isGroup,
    int? participantCount,
    String? lastMessageText,
    DateTime? lastMessageAt,
    int? unreadCount,
    bool? isArchived,
    bool? isMuted,
    bool? isPinned,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Conversation(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      accountId: accountId ?? this.accountId,
      phoneNumberId: phoneNumberId ?? this.phoneNumberId,
      contactId: contactId ?? this.contactId,
      conversationName: conversationName ?? this.conversationName,
      isGroup: isGroup ?? this.isGroup,
      participantCount: participantCount ?? this.participantCount,
      lastMessageText: lastMessageText ?? this.lastMessageText,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      unreadCount: unreadCount ?? this.unreadCount,
      isArchived: isArchived ?? this.isArchived,
      isMuted: isMuted ?? this.isMuted,
      isPinned: isPinned ?? this.isPinned,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

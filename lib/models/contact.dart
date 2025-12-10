class Contact {
  final String id;
  final String userId;
  final String accountId;
  final String fullName;
  final String phoneNumber;
  final String? email;
  final String? avatarUrl;
  final bool isFavorite;
  final List<String> tags;
  final String? notes;
  final String? deviceContactId;
  final DateTime? lastSyncedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  Contact({
    required this.id,
    required this.userId,
    required this.accountId,
    required this.fullName,
    required this.phoneNumber,
    this.email,
    this.avatarUrl,
    this.isFavorite = false,
    this.tags = const [],
    this.notes,
    this.deviceContactId,
    this.lastSyncedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      accountId: json['account_id'] as String,
      fullName: json['full_name'] as String,
      phoneNumber: json['phone_number'] as String,
      email: json['email'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      isFavorite: json['is_favorite'] as bool? ?? false,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      notes: json['notes'] as String?,
      deviceContactId: json['device_contact_id'] as String?,
      lastSyncedAt: json['last_synced_at'] != null
          ? DateTime.parse(json['last_synced_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'account_id': accountId,
      'full_name': fullName,
      'phone_number': phoneNumber,
      'email': email,
      'avatar_url': avatarUrl,
      'is_favorite': isFavorite,
      'tags': tags,
      'notes': notes,
      'device_contact_id': deviceContactId,
      'last_synced_at': lastSyncedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Contact copyWith({
    String? id,
    String? userId,
    String? accountId,
    String? fullName,
    String? phoneNumber,
    String? email,
    String? avatarUrl,
    bool? isFavorite,
    List<String>? tags,
    String? notes,
    String? deviceContactId,
    DateTime? lastSyncedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Contact(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      accountId: accountId ?? this.accountId,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isFavorite: isFavorite ?? this.isFavorite,
      tags: tags ?? this.tags,
      notes: notes ?? this.notes,
      deviceContactId: deviceContactId ?? this.deviceContactId,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

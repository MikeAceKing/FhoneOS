class SyncConfiguration {
  final String id;
  final String userId;
  final String categoryId;
  final String categoryName;
  final String categoryType;
  final bool isEnabled;
  final String syncFrequency;
  final bool wifiOnly;
  final int cellularDataLimitMb;
  final bool backgroundSync;
  final DateTime? lastSyncAt;
  final DateTime? nextSyncAt;
  final double storageUsedMb;
  final DateTime createdAt;
  final DateTime updatedAt;

  SyncConfiguration({
    required this.id,
    required this.userId,
    required this.categoryId,
    required this.categoryName,
    required this.categoryType,
    required this.isEnabled,
    required this.syncFrequency,
    required this.wifiOnly,
    required this.cellularDataLimitMb,
    required this.backgroundSync,
    this.lastSyncAt,
    this.nextSyncAt,
    required this.storageUsedMb,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SyncConfiguration.fromJson(Map<String, dynamic> json) {
    return SyncConfiguration(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      categoryId: json['category_id'] as String,
      categoryName: json['sync_categories']?['name'] as String? ?? '',
      categoryType: json['sync_categories']?['category_type'] as String? ?? '',
      isEnabled: json['is_enabled'] as bool? ?? false,
      syncFrequency: json['sync_frequency'] as String? ?? 'daily',
      wifiOnly: json['wifi_only'] as bool? ?? true,
      cellularDataLimitMb: json['cellular_data_limit_mb'] as int? ?? 100,
      backgroundSync: json['background_sync'] as bool? ?? true,
      lastSyncAt: json['last_sync_at'] != null
          ? DateTime.parse(json['last_sync_at'] as String)
          : null,
      nextSyncAt: json['next_sync_at'] != null
          ? DateTime.parse(json['next_sync_at'] as String)
          : null,
      storageUsedMb: (json['storage_used_mb'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'category_id': categoryId,
      'is_enabled': isEnabled,
      'sync_frequency': syncFrequency,
      'wifi_only': wifiOnly,
      'cellular_data_limit_mb': cellularDataLimitMb,
      'background_sync': backgroundSync,
      'last_sync_at': lastSyncAt?.toIso8601String(),
      'next_sync_at': nextSyncAt?.toIso8601String(),
      'storage_used_mb': storageUsedMb,
    };
  }
}

class DeviceRegistration {
  final String id;
  final String userId;
  final String deviceId;
  final String deviceName;
  final String? deviceModel;
  final String? osVersion;
  final String? appVersion;
  final DateTime lastActiveAt;
  final bool isTrusted;
  final bool canRemoteWipe;
  final bool syncEnabled;
  final DateTime createdAt;

  DeviceRegistration({
    required this.id,
    required this.userId,
    required this.deviceId,
    required this.deviceName,
    this.deviceModel,
    this.osVersion,
    this.appVersion,
    required this.lastActiveAt,
    required this.isTrusted,
    required this.canRemoteWipe,
    required this.syncEnabled,
    required this.createdAt,
  });

  factory DeviceRegistration.fromJson(Map<String, dynamic> json) {
    return DeviceRegistration(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      deviceId: json['device_id'] as String,
      deviceName: json['device_name'] as String,
      deviceModel: json['device_model'] as String?,
      osVersion: json['os_version'] as String?,
      appVersion: json['app_version'] as String?,
      lastActiveAt: DateTime.parse(json['last_active_at'] as String),
      isTrusted: json['is_trusted'] as bool? ?? true,
      canRemoteWipe: json['can_remote_wipe'] as bool? ?? false,
      syncEnabled: json['sync_enabled'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

class SyncHistory {
  final String id;
  final String userId;
  final String deviceId;
  final String categoryId;
  final String categoryName;
  final String syncStatus;
  final int itemsSynced;
  final double dataTransferredMb;
  final DateTime startedAt;
  final DateTime? completedAt;
  final String? errorMessage;
  final String? connectionType;

  SyncHistory({
    required this.id,
    required this.userId,
    required this.deviceId,
    required this.categoryId,
    required this.categoryName,
    required this.syncStatus,
    required this.itemsSynced,
    required this.dataTransferredMb,
    required this.startedAt,
    this.completedAt,
    this.errorMessage,
    this.connectionType,
  });

  factory SyncHistory.fromJson(Map<String, dynamic> json) {
    return SyncHistory(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      deviceId: json['device_id'] as String,
      categoryId: json['category_id'] as String,
      categoryName: json['sync_categories']?['name'] as String? ?? '',
      syncStatus: json['sync_status'] as String,
      itemsSynced: json['items_synced'] as int? ?? 0,
      dataTransferredMb:
          (json['data_transferred_mb'] as num?)?.toDouble() ?? 0.0,
      startedAt: DateTime.parse(json['started_at'] as String),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      errorMessage: json['error_message'] as String?,
      connectionType: json['connection_type'] as String?,
    );
  }
}

class BackupSchedule {
  final String id;
  final String userId;
  final String frequency;
  final String? scheduledTime;
  final DateTime? lastBackupAt;
  final DateTime? nextBackupAt;
  final int storageQuotaMb;
  final double storageUsedMb;
  final bool autoCleanupEnabled;
  final int retentionDays;

  BackupSchedule({
    required this.id,
    required this.userId,
    required this.frequency,
    this.scheduledTime,
    this.lastBackupAt,
    this.nextBackupAt,
    required this.storageQuotaMb,
    required this.storageUsedMb,
    required this.autoCleanupEnabled,
    required this.retentionDays,
  });

  factory BackupSchedule.fromJson(Map<String, dynamic> json) {
    return BackupSchedule(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      frequency: json['frequency'] as String? ?? 'daily',
      scheduledTime: json['scheduled_time'] as String?,
      lastBackupAt: json['last_backup_at'] != null
          ? DateTime.parse(json['last_backup_at'] as String)
          : null,
      nextBackupAt: json['next_backup_at'] != null
          ? DateTime.parse(json['next_backup_at'] as String)
          : null,
      storageQuotaMb: json['storage_quota_mb'] as int? ?? 5000,
      storageUsedMb: (json['storage_used_mb'] as num?)?.toDouble() ?? 0.0,
      autoCleanupEnabled: json['auto_cleanup_enabled'] as bool? ?? true,
      retentionDays: json['retention_days'] as int? ?? 30,
    );
  }
}

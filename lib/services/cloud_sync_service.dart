import '../models/sync_configuration.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CloudSyncService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get all sync configurations for user
  Future<List<SyncConfiguration>> getSyncConfigurations() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _supabase
          .from('sync_configurations')
          .select('*, sync_categories(*)')
          .eq('user_id', userId)
          .order('created_at', ascending: true);

      return (response as List)
          .map((json) => SyncConfiguration.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch sync configurations: $e');
    }
  }

  // Update sync configuration
  Future<void> updateSyncConfiguration({
    required String configId,
    bool? isEnabled,
    String? syncFrequency,
    bool? wifiOnly,
    int? cellularDataLimitMb,
    bool? backgroundSync,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (isEnabled != null) updates['is_enabled'] = isEnabled;
      if (syncFrequency != null) updates['sync_frequency'] = syncFrequency;
      if (wifiOnly != null) updates['wifi_only'] = wifiOnly;
      if (cellularDataLimitMb != null)
        updates['cellular_data_limit_mb'] = cellularDataLimitMb;
      if (backgroundSync != null) updates['background_sync'] = backgroundSync;

      await _supabase
          .from('sync_configurations')
          .update(updates)
          .eq('id', configId);
    } catch (e) {
      throw Exception('Failed to update sync configuration: $e');
    }
  }

  // Get registered devices for user
  Future<List<DeviceRegistration>> getDeviceRegistrations() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _supabase
          .from('device_registrations')
          .select()
          .eq('user_id', userId)
          .order('last_active_at', ascending: false);

      return (response as List)
          .map((json) => DeviceRegistration.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch device registrations: $e');
    }
  }

  // Update device permissions
  Future<void> updateDevicePermissions({
    required String deviceId,
    bool? canRemoteWipe,
    bool? syncEnabled,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (canRemoteWipe != null) updates['can_remote_wipe'] = canRemoteWipe;
      if (syncEnabled != null) updates['sync_enabled'] = syncEnabled;

      await _supabase
          .from('device_registrations')
          .update(updates)
          .eq('id', deviceId);
    } catch (e) {
      throw Exception('Failed to update device permissions: $e');
    }
  }

  // Get sync history
  Future<List<SyncHistory>> getSyncHistory({int limit = 50}) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _supabase
          .from('sync_history')
          .select('*, sync_categories(*)')
          .eq('user_id', userId)
          .order('started_at', ascending: false)
          .limit(limit);

      return (response as List)
          .map((json) => SyncHistory.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch sync history: $e');
    }
  }

  // Get backup schedule
  Future<BackupSchedule?> getBackupSchedule() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _supabase
          .from('backup_schedules')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      return response != null ? BackupSchedule.fromJson(response) : null;
    } catch (e) {
      throw Exception('Failed to fetch backup schedule: $e');
    }
  }

  // Update backup schedule
  Future<void> updateBackupSchedule({
    String? frequency,
    String? scheduledTime,
    bool? autoCleanupEnabled,
    int? retentionDays,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final updates = <String, dynamic>{};
      if (frequency != null) updates['frequency'] = frequency;
      if (scheduledTime != null) updates['scheduled_time'] = scheduledTime;
      if (autoCleanupEnabled != null)
        updates['auto_cleanup_enabled'] = autoCleanupEnabled;
      if (retentionDays != null) updates['retention_days'] = retentionDays;

      await _supabase
          .from('backup_schedules')
          .update(updates)
          .eq('user_id', userId);
    } catch (e) {
      throw Exception('Failed to update backup schedule: $e');
    }
  }

  // Trigger manual sync
  Future<void> triggerManualSync(String categoryId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      // Update last_sync_at timestamp
      await _supabase
          .from('sync_configurations')
          .update({'last_sync_at': DateTime.now().toIso8601String()})
          .eq('user_id', userId)
          .eq('category_id', categoryId);
    } catch (e) {
      throw Exception('Failed to trigger manual sync: $e');
    }
  }

  // Update conflict resolution strategy
  Future<void> updateConflictResolution({
    required String categoryId,
    required String strategy,
    bool? autoResolve,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final updates = <String, dynamic>{
        'strategy': strategy,
      };
      if (autoResolve != null) updates['auto_resolve'] = autoResolve;

      await _supabase.from('conflict_resolutions').upsert({
        'user_id': userId,
        'category_id': categoryId,
        ...updates,
      });
    } catch (e) {
      throw Exception('Failed to update conflict resolution: $e');
    }
  }

  // Update encryption settings
  Future<void> updateEncryptionSettings({
    String? encryptionLevel,
    bool? endToEndEnabled,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final updates = <String, dynamic>{};
      if (encryptionLevel != null)
        updates['encryption_level'] = encryptionLevel;
      if (endToEndEnabled != null)
        updates['end_to_end_enabled'] = endToEndEnabled;

      await _supabase.from('encryption_settings').upsert({
        'user_id': userId,
        ...updates,
      });
    } catch (e) {
      throw Exception('Failed to update encryption settings: $e');
    }
  }
}
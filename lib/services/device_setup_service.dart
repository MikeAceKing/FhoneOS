import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/device_registration.dart';
import '../models/user_permission.dart';

class DeviceSetupService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Register a new device
  Future<DeviceRegistration> registerDevice({
    required String deviceId,
    required String deviceModel,
    required String deviceManufacturer,
    required String androidVersion,
    String? fcmToken,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final response = await _supabase
        .from('device_registrations')
        .insert({
          'user_id': userId,
          'device_id': deviceId,
          'device_model': deviceModel,
          'device_manufacturer': deviceManufacturer,
          'android_version': androidVersion,
          'fcm_token': fcmToken,
          'current_setup_step': 'device_registration',
        })
        .select()
        .single();

    return DeviceRegistration.fromJson(response);
  }

  // Update setup step
  Future<void> updateSetupStep(String deviceRegistrationId, String step) async {
    await _supabase.from('device_registrations').update({
      'current_setup_step': step,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', deviceRegistrationId);
  }

  // Mark setup as completed
  Future<void> completeSetup(String deviceRegistrationId) async {
    await _supabase.from('device_registrations').update({
      'setup_completed': true,
      'setup_completed_at': DateTime.now().toIso8601String(),
      'current_setup_step': 'completed',
    }).eq('id', deviceRegistrationId);
  }

  // Get device registration by device ID
  Future<DeviceRegistration?> getDeviceRegistration(String deviceId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return null;

    final response = await _supabase
        .from('device_registrations')
        .select()
        .eq('user_id', userId)
        .eq('device_id', deviceId)
        .maybeSingle();

    if (response == null) return null;
    return DeviceRegistration.fromJson(response);
  }

  // Update permission status
  Future<void> updatePermission({
    required String deviceRegistrationId,
    required String permissionName,
    required String status,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    // Update permission in user_permissions table
    await _supabase.from('user_permissions').upsert({
      'user_id': userId,
      'device_id': deviceRegistrationId,
      permissionName: status,
      'last_permission_request_at': DateTime.now().toIso8601String(),
      'permission_requests_count': 1, // Increment logic handled by DB
    }, onConflict: 'user_id,device_id');

    // Log to permission history
    await _supabase.from('permission_history').insert({
      'user_id': userId,
      'device_id': deviceRegistrationId,
      'permission_name': permissionName,
      'new_status': status,
      'context': 'Permission updated via app',
    });
  }

  // Get user permissions
  Future<UserPermission?> getUserPermissions(
      String deviceRegistrationId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return null;

    final response = await _supabase
        .from('user_permissions')
        .select()
        .eq('user_id', userId)
        .eq('device_id', deviceRegistrationId)
        .maybeSingle();

    if (response == null) return null;
    return UserPermission.fromJson(response);
  }

  // Get setup progress
  Future<Map<String, dynamic>?> getSetupProgress() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return null;

    final response = await _supabase
        .rpc('get_device_setup_progress', params: {'p_user_id': userId});

    if (response == null || (response as List).isEmpty) return null;
    return response[0] as Map<String, dynamic>;
  }

  // Get permission summary
  Future<Map<String, dynamic>?> getPermissionSummary(
      String deviceRegistrationId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return null;

    final response = await _supabase.rpc('get_permission_summary', params: {
      'p_user_id': userId,
      'p_device_id': deviceRegistrationId,
    });

    return response as Map<String, dynamic>?;
  }

  // Update launcher default status
  Future<void> updateLauncherDefault(
      String deviceRegistrationId, bool isDefault) async {
    await _supabase.from('device_registrations').update({
      'is_launcher_default': isDefault,
    }).eq('id', deviceRegistrationId);
  }

  // Update SMS default status
  Future<void> updateSmsDefault(
      String deviceRegistrationId, bool isDefault) async {
    await _supabase.from('device_registrations').update({
      'is_sms_default': isDefault,
    }).eq('id', deviceRegistrationId);
  }
}

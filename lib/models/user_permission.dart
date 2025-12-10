class UserPermission {
  final String id;
  final String userId;
  final String deviceId;
  final String phonePermission;
  final String smsPermission;
  final String contactsPermission;
  final String cameraPermission;
  final String microphonePermission;
  final String storagePermission;
  final String locationPrecise;
  final String locationApproximate;
  final String locationBackground;
  final String calendarPermission;
  final String notificationsPermission;
  final String biometricsPermission;
  final String callLogsPermission;
  final bool notificationListenerEnabled;
  final DateTime? lastPermissionRequestAt;
  final int permissionRequestsCount;

  UserPermission({
    required this.id,
    required this.userId,
    required this.deviceId,
    required this.phonePermission,
    required this.smsPermission,
    required this.contactsPermission,
    required this.cameraPermission,
    required this.microphonePermission,
    required this.storagePermission,
    required this.locationPrecise,
    required this.locationApproximate,
    required this.locationBackground,
    required this.calendarPermission,
    required this.notificationsPermission,
    required this.biometricsPermission,
    required this.callLogsPermission,
    required this.notificationListenerEnabled,
    this.lastPermissionRequestAt,
    required this.permissionRequestsCount,
  });

  factory UserPermission.fromJson(Map<String, dynamic> json) {
    return UserPermission(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      deviceId: json['device_id'] as String,
      phonePermission: json['phone_permission'] as String,
      smsPermission: json['sms_permission'] as String,
      contactsPermission: json['contacts_permission'] as String,
      cameraPermission: json['camera_permission'] as String,
      microphonePermission: json['microphone_permission'] as String,
      storagePermission: json['storage_permission'] as String,
      locationPrecise: json['location_precise'] as String,
      locationApproximate: json['location_approximate'] as String,
      locationBackground: json['location_background'] as String,
      calendarPermission: json['calendar_permission'] as String,
      notificationsPermission: json['notifications_permission'] as String,
      biometricsPermission: json['biometrics_permission'] as String,
      callLogsPermission: json['call_logs_permission'] as String,
      notificationListenerEnabled:
          json['notification_listener_enabled'] as bool,
      lastPermissionRequestAt: json['last_permission_request_at'] != null
          ? DateTime.parse(json['last_permission_request_at'] as String)
          : null,
      permissionRequestsCount: json['permission_requests_count'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'device_id': deviceId,
      'phone_permission': phonePermission,
      'sms_permission': smsPermission,
      'contacts_permission': contactsPermission,
      'camera_permission': cameraPermission,
      'microphone_permission': microphonePermission,
      'storage_permission': storagePermission,
      'location_precise': locationPrecise,
      'location_approximate': locationApproximate,
      'location_background': locationBackground,
      'calendar_permission': calendarPermission,
      'notifications_permission': notificationsPermission,
      'biometrics_permission': biometricsPermission,
      'call_logs_permission': callLogsPermission,
      'notification_listener_enabled': notificationListenerEnabled,
      'last_permission_request_at': lastPermissionRequestAt?.toIso8601String(),
      'permission_requests_count': permissionRequestsCount,
    };
  }
}

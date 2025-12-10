class DeviceRegistration {
  final String id;
  final String userId;
  final String deviceId;
  final String? deviceModel;
  final String? deviceManufacturer;
  final String? androidVersion;
  final String? fcmToken;
  final String? twilioNumber;
  final String currentSetupStep;
  final bool setupCompleted;
  final DateTime? setupStartedAt;
  final DateTime? setupCompletedAt;
  final bool isLauncherDefault;
  final bool isSmsDefault;

  DeviceRegistration({
    required this.id,
    required this.userId,
    required this.deviceId,
    this.deviceModel,
    this.deviceManufacturer,
    this.androidVersion,
    this.fcmToken,
    this.twilioNumber,
    required this.currentSetupStep,
    required this.setupCompleted,
    this.setupStartedAt,
    this.setupCompletedAt,
    required this.isLauncherDefault,
    required this.isSmsDefault,
  });

  factory DeviceRegistration.fromJson(Map<String, dynamic> json) {
    return DeviceRegistration(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      deviceId: json['device_id'] as String,
      deviceModel: json['device_model'] as String?,
      deviceManufacturer: json['device_manufacturer'] as String?,
      androidVersion: json['android_version'] as String?,
      fcmToken: json['fcm_token'] as String?,
      twilioNumber: json['twilio_number'] as String?,
      currentSetupStep: json['current_setup_step'] as String,
      setupCompleted: json['setup_completed'] as bool,
      setupStartedAt: json['setup_started_at'] != null
          ? DateTime.parse(json['setup_started_at'] as String)
          : null,
      setupCompletedAt: json['setup_completed_at'] != null
          ? DateTime.parse(json['setup_completed_at'] as String)
          : null,
      isLauncherDefault: json['is_launcher_default'] as bool,
      isSmsDefault: json['is_sms_default'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'device_id': deviceId,
      'device_model': deviceModel,
      'device_manufacturer': deviceManufacturer,
      'android_version': androidVersion,
      'fcm_token': fcmToken,
      'twilio_number': twilioNumber,
      'current_setup_step': currentSetupStep,
      'setup_completed': setupCompleted,
      'setup_started_at': setupStartedAt?.toIso8601String(),
      'setup_completed_at': setupCompletedAt?.toIso8601String(),
      'is_launcher_default': isLauncherDefault,
      'is_sms_default': isSmsDefault,
    };
  }
}

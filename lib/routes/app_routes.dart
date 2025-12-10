import 'package:flutter/material.dart';

import '../presentation/ai_assistant_chat/ai_assistant_chat.dart';
import '../presentation/billing_payment_center/billing_payment_center.dart';
import '../presentation/call_management_screen/call_management_screen.dart';
import '../presentation/camera_interface/camera_interface.dart';
import '../presentation/cloud_sync_configuration/cloud_sync_configuration.dart';
import '../presentation/complete_twilio_communication_suite/complete_twilio_communication_suite.dart';
import '../presentation/comprehensive_contacts_manager/comprehensive_contacts_manager.dart';
import '../presentation/cross_device_sync_backup_manager/cross_device_sync_backup_manager.dart';
import '../presentation/device_setup_wizard/device_setup_wizard.dart';
import '../presentation/dialer_interface/dialer_interface.dart';
import '../presentation/e_sim_management_settings/e_sim_management_settings.dart';
import '../presentation/enhanced_app_launcher_desktop/enhanced_app_launcher_desktop.dart';
import '../presentation/fhone_os_dashboard/fhone_os_dashboard.dart';
import '../presentation/fhone_os_subscription_plans/fhone_os_subscription_plans.dart';
import '../presentation/fhoneos_signup_flow/fhoneos_signup_flow.dart';
import '../presentation/fully_integrated_whats_app_business_center/fully_integrated_whats_app_business_center.dart';
import '../presentation/media_center/media_center.dart';
import '../presentation/messaging_interface/messaging_interface.dart';
import '../presentation/notifications_screen/notifications_screen.dart';
import '../presentation/number_management_dashboard/number_management_dashboard.dart';
import '../presentation/permission_management_center/permission_management_center.dart';
import '../presentation/phone_number_purchase/phone_number_purchase.dart';
import '../presentation/production_sms_messaging_hub/production_sms_messaging_hub.dart';
import '../presentation/real_time_call_management_center/real_time_call_management_center.dart';
import '../presentation/settings_screen/settings_screen.dart';
import '../presentation/social_hub/social_hub.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/stripe_payment_contract_management/stripe_payment_contract_management.dart';
import '../presentation/subscription_management_hub/subscription_management_hub.dart';
import '../presentation/twilio_voice_video_center/twilio_voice_video_center.dart';
import '../presentation/unified_social_inbox_hub/unified_social_inbox_hub.dart';
import '../presentation/usage_analytics_dashboard/usage_analytics_dashboard.dart';
import '../presentation/user_profile_screen/user_profile_screen.dart';
import '../presentation/video_calling_interface/video_calling_interface.dart';
import '../presentation/wallet_billing_center/wallet_billing_center.dart';

class AppRoutes {
  // Core Routes
  static const String initial = '/';
  static const String splash = '/splash-screen';
  static const String signup = '/fhoneos-signup-flow';
  static const String dashboard = '/fhone-os-dashboard';
  static const String desktop = '/enhanced-app-launcher-desktop';

  // Communication
  static const String socialHub = '/social-hub';
  static const String whatsappBusiness =
      '/fully-integrated-whats-app-business-center';
  static const String messagingInterface = '/messaging-interface';
  static const String smsMessaging = '/production-sms-messaging-hub';
  static const String unifiedInbox = '/unified-social-inbox-hub';
  static const String dialerInterface = '/dialer-interface';
  static const String videoCall = '/video-calling-interface';
  static const String callManagement = '/call-management-screen';
  static const String realTimeCallCenter = '/real-time-call-management-center';
  static const String twilioSuite = '/complete-twilio-communication-suite';
  static const String twilioVoiceVideo = '/twilio-voice-video-center';

  // Phone & Numbers
  static const String phoneNumberPurchase = '/phone-number-purchase';
  static const String numberManagement = '/number-management-dashboard';
  static const String eSimManagement = '/e-sim-management-settings';

  // Billing & Subscriptions
  static const String walletBilling = '/wallet-billing-center';
  static const String billingPayment = '/billing-payment-center';
  static const String subscriptionPlans = '/fhone-os-subscription-plans';
  static const String subscriptionManagement = '/subscription-management-hub';
  static const String stripePayment = '/stripe-payment-contract-management';
  static const String usageAnalytics = '/usage-analytics-dashboard';

  // User Management
  static const String userProfile = '/user-profile-screen';
  static const String settings = '/settings-screen';
  static const String contacts = '/comprehensive-contacts-manager';
  static const String permissions = '/permission-management-center';
  static const String deviceSetup = '/device-setup-wizard';

  // Sync & Storage
  static const String cloudSync = '/cloud-sync-configuration';
  static const String crossDeviceSync = '/cross-device-sync-backup-manager';

  // Media & Content
  static const String camera = '/camera-interface';
  static const String mediaCenter = '/media-center';
  static const String notifications = '/notifications-screen';

  // AI Features
  static const String aiAssistant = '/ai-assistant-chat';

  static Map<String, WidgetBuilder> get routes => {
        // Core flow
        initial: (context) => const SplashScreen(),
        splash: (context) => const SplashScreen(),
        signup: (context) => const FhoneosSignupFlow(),
        dashboard: (context) => const FhoneOsDashboard(),
        desktop: (context) => const EnhancedAppLauncherDesktop(),

        // Communication
        socialHub: (context) => const SocialHub(),
        whatsappBusiness: (context) =>
            const FullyIntegratedWhatsAppBusinessCenter(),
        messagingInterface: (context) => const MessagingInterface(),
        smsMessaging: (context) => const ProductionSmsMessagingHub(),
        unifiedInbox: (context) => const UnifiedSocialInboxHub(),
        dialerInterface: (context) => const DialerInterface(),
        videoCall: (context) => const VideoCallingInterface(),
        callManagement: (context) => const CallManagementScreen(),
        realTimeCallCenter: (context) => const RealTimeCallManagementCenter(),
        twilioSuite: (context) => const CompleteTwilioCommunicationSuite(),
        twilioVoiceVideo: (context) => const TwilioVoiceVideoCenter(),

        // Phone & Numbers
        phoneNumberPurchase: (context) => const PhoneNumberPurchaseScreen(),
        numberManagement: (context) => const NumberManagementDashboard(),
        eSimManagement: (context) => const ESimManagementSettings(),

        // Billing & Subscriptions
        walletBilling: (context) => const WalletBillingCenter(),
        billingPayment: (context) => const BillingPaymentCenter(),
        subscriptionPlans: (context) => const FhoneOsSubscriptionPlans(),
        subscriptionManagement: (context) => const SubscriptionManagementHub(),
        stripePayment: (context) => const StripePaymentContractManagement(),
        usageAnalytics: (context) => const UsageAnalyticsDashboard(),

        // User Management
        userProfile: (context) => const UserProfileScreen(),
        settings: (context) => const SettingsScreen(),
        contacts: (context) => const ComprehensiveContactsManager(),
        permissions: (context) => const PermissionManagementCenter(),
        deviceSetup: (context) => const DeviceSetupWizard(),

        // Sync & Storage
        cloudSync: (context) => const CloudSyncConfiguration(),
        crossDeviceSync: (context) => const CrossDeviceSyncBackupManager(),

        // Media & Content
        camera: (context) => const CameraInterface(),
        mediaCenter: (context) => const MediaCenter(),
        notifications: (context) => const NotificationsScreen(),

        // AI Features
        aiAssistant: (context) => const AiAssistantChatScreen(),
      };
}

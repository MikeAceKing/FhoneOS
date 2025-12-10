import 'package:flutter/material.dart';

import '../presentation/4_step_signup_stepper_flow/4_step_signup_stepper_flow.dart';
import '../presentation/ai_assistant_chat/ai_assistant_chat.dart';
import '../presentation/app_launcher_desktop/app_launcher_desktop.dart';
import '../presentation/billing_payment_center/billing_payment_center.dart';
import '../presentation/call_management_screen/call_management_screen.dart';
import '../presentation/camera_interface/camera_interface.dart';
import '../presentation/cloud_sync_configuration/cloud_sync_configuration.dart';
import '../presentation/complete_twilio_communication_suite/complete_twilio_communication_suite.dart';
import '../presentation/comprehensive_contacts_manager/comprehensive_contacts_manager.dart';
import '../presentation/core_apps_dashboard/core_apps_dashboard.dart';
import '../presentation/cross_device_sync_backup_manager/cross_device_sync_backup_manager.dart';
import '../presentation/device_setup_wizard/device_setup_wizard.dart';
import '../presentation/dialer_interface/dialer_interface.dart';
import '../presentation/e_sim_management_settings/e_sim_management_settings.dart';
import '../presentation/enhanced_app_launcher_desktop/enhanced_app_launcher_desktop.dart';
import '../presentation/enhanced_o_auth_registration_flow/enhanced_o_auth_registration_flow.dart';
import '../presentation/fhone_os_authentication_gateway/fhone_os_authentication_gateway.dart';
import '../presentation/fhone_os_dashboard/fhone_os_dashboard.dart';
import '../presentation/fhone_os_login_screen/fhone_os_login_screen.dart';
import '../presentation/fhone_os_subscription_plans/fhone_os_subscription_plans.dart';
import '../presentation/fhoneos_signup_flow/fhoneos_signup_flow.dart';
import '../presentation/fully_integrated_whats_app_business_center/fully_integrated_whats_app_business_center.dart';
import '../presentation/media_center/media_center.dart';
import '../presentation/messaging_interface/messaging_interface.dart';
import '../presentation/notifications_screen/notifications_screen.dart';
import '../presentation/number_management_dashboard/number_management_dashboard.dart';
import '../presentation/o_auth_login_hub/o_auth_login_hub.dart';
import '../presentation/o_auth_registration_onboarding/o_auth_registration_onboarding.dart';
import '../presentation/permission_management_center/permission_management_center.dart';
import '../presentation/phone_number_purchase/phone_number_purchase.dart';
import '../presentation/plan_selection_billing/plan_selection_billing.dart';
import '../presentation/premium_plan_selection_hub/premium_plan_selection_hub.dart';
import '../presentation/production_sms_messaging_hub/production_sms_messaging_hub.dart';
import '../presentation/real_time_call_management_center/real_time_call_management_center.dart';
import '../presentation/registration_authentication_hub/registration_authentication_hub.dart';
import '../presentation/registration_screen/registration_screen.dart';
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
import '../presentation/welcome_login_screen/welcome_login_screen.dart';
import '../presentation/whats_app_integration_hub/whats_app_integration_hub.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String videoCallingInterface = '/video-calling-interface';
  static const String splash = '/splash-screen';
  static const String settings = '/settings-screen';
  static const String socialHub = '/social-hub';
  static const String userProfile = '/user-profile-screen';
  static const String messagingInterface = '/messaging-interface';
  static const String cameraInterface = '/camera-interface';
  static const String mediaCenter = '/media-center';
  static const String notifications = '/notifications-screen';
  static const String appLauncherDesktop = '/app-launcher-desktop';
  static const String welcomeLogin = '/welcome-login-screen';
  static const String dialerInterface = '/dialer-interface';
  static const String eSimManagementSettings = '/e-sim-management-settings';
  static const String callManagementScreen = '/call-management-screen';
  static const String fhoneOsLoginScreen = '/fhone-os-login-screen';
  static const String fhoneOsDashboard = '/fhone-os-dashboard';
  static const String phoneNumberPurchaseScreen = '/phone-number-purchase';
  static const String numberManagementDashboard =
      '/number-management-dashboard';
  static const String walletBillingCenter = '/wallet-billing-center';
  static const String planSelectionBilling = '/plan-selection-billing';
  static const String aiAssistantChat = '/ai-assistant-chat';
  static const String oAuthLoginHub = '/o-auth-login-hub';
  static const String oAuthRegistrationOnboarding =
      '/o-auth-registration-onboarding';
  static const String premiumPlanSelectionHub = '/premium-plan-selection-hub';
  static const String subscriptionManagementHub =
      '/subscription-management-hub';
  static const String usageAnalyticsDashboard = '/usage-analytics-dashboard';
  static const String billingPaymentCenter = '/billing-payment-center';
  static const String registrationAuthHub = '/registration-authentication-hub';
  static const String fhoneOsSubscriptionPlans = '/fhone-os-subscription-plans';
  static const String registration = '/registration';
  static const String deviceSetupWizard = '/device-setup-wizard';
  static const String permissionManagementCenter =
      '/permission-management-center';
  static const String cloudSyncConfiguration = '/cloud-sync-configuration';
  static const String productionSmsMessagingHub =
      '/production-sms-messaging-hub';
  static const String realTimeCallManagementCenter =
      '/real-time-call-management-center';
  static const String unifiedSocialInboxHub = '/unified-social-inbox-hub';
  static const String stripePaymentContractManagement =
      '/stripe-payment-contract-management';
  static const String coreAppsDashboard = '/core-apps-dashboard';
  static const String enhancedOAuthRegistrationFlow =
      '/enhanced-o-auth-registration-flow';
  static const String comprehensiveContactsManager =
      '/comprehensive-contacts-manager';
  static const String whatsAppIntegrationHub = '/whats-app-integration-hub';
  static const String twilioVoiceVideoCenter = '/twilio-voice-video-center';
  static const String crossDeviceSyncBackupManager =
      '/cross-device-sync-backup-manager';
  static const String fhoneOsAuthenticationGateway =
      '/fhone-os-authentication-gateway';
  static const String signupStepperFlow = '/4-step-signup-stepper-flow';
  static const String fhoneosSignupFlow = '/fhoneos-signup-flow';
  static const String enhancedAppLauncherDesktop =
      '/enhanced-app-launcher-desktop';
  static const String fullyIntegratedWhatsAppBusinessCenter =
      '/fully-integrated-whats-app-business-center';
  static const String completeTwilioCommunicationSuite =
      '/complete-twilio-communication-suite';

  static Map<String, WidgetBuilder> get routes => {
        initial: (context) => const SplashScreen(),
        videoCallingInterface: (context) => const VideoCallingInterface(),
        splash: (context) => const SplashScreen(),
        settings: (context) => const SettingsScreen(),
        socialHub: (context) => const SocialHub(),
        userProfile: (context) => const UserProfileScreen(),
        messagingInterface: (context) => const MessagingInterface(),
        cameraInterface: (context) => const CameraInterface(),
        mediaCenter: (context) => const MediaCenter(),
        notifications: (context) => const NotificationsScreen(),
        appLauncherDesktop: (context) => const AppLauncherDesktop(),
        welcomeLogin: (context) => const WelcomeLoginScreen(),
        dialerInterface: (context) => const DialerInterface(),
        eSimManagementSettings: (context) => const ESimManagementSettings(),
        callManagementScreen: (context) => const CallManagementScreen(),
        fhoneOsLoginScreen: (context) => const FhoneOsLoginScreen(),
        fhoneOsDashboard: (context) => const FhoneOsDashboard(),
        phoneNumberPurchaseScreen: (context) =>
            const PhoneNumberPurchaseScreen(),
        numberManagementDashboard: (context) =>
            const NumberManagementDashboard(),
        walletBillingCenter: (context) => const WalletBillingCenter(),
        planSelectionBilling: (context) => const PlanSelectionBillingScreen(),
        aiAssistantChat: (context) => const AiAssistantChatScreen(),
        oAuthLoginHub: (context) => const OAuthLoginHub(),
        oAuthRegistrationOnboarding: (context) =>
            const OAuthRegistrationOnboarding(),
        premiumPlanSelectionHub: (context) => const PremiumPlanSelectionHub(),
        subscriptionManagementHub: (context) =>
            const SubscriptionManagementHub(),
        usageAnalyticsDashboard: (context) => const UsageAnalyticsDashboard(),
        billingPaymentCenter: (context) => const BillingPaymentCenter(),
        registrationAuthHub: (context) => const RegistrationAuthenticationHub(),
        fhoneOsSubscriptionPlans: (context) => const FhoneOsSubscriptionPlans(),
        registration: (context) => const RegistrationScreen(),
        deviceSetupWizard: (context) => const DeviceSetupWizard(),
        permissionManagementCenter: (context) =>
            const PermissionManagementCenter(),
        cloudSyncConfiguration: (context) => const CloudSyncConfiguration(),
        productionSmsMessagingHub: (context) =>
            const ProductionSmsMessagingHub(),
        realTimeCallManagementCenter: (context) =>
            const RealTimeCallManagementCenter(),
        unifiedSocialInboxHub: (context) => const UnifiedSocialInboxHub(),
        stripePaymentContractManagement: (context) =>
            const StripePaymentContractManagement(),
        coreAppsDashboard: (context) => const CoreAppsDashboard(),
        enhancedOAuthRegistrationFlow: (context) =>
            const EnhancedOAuthRegistrationFlow(),
        comprehensiveContactsManager: (context) =>
            const ComprehensiveContactsManager(),
        whatsAppIntegrationHub: (context) => const WhatsAppIntegrationHub(),
        twilioVoiceVideoCenter: (context) => const TwilioVoiceVideoCenter(),
        crossDeviceSyncBackupManager: (context) =>
            const CrossDeviceSyncBackupManager(),
        fhoneOsAuthenticationGateway: (context) =>
            const FhoneOSAuthenticationGateway(),
        signupStepperFlow: (context) => const SignupStepperFlow(),
        fhoneosSignupFlow: (context) => const FhoneosSignupFlow(),
        enhancedAppLauncherDesktop: (context) =>
            const EnhancedAppLauncherDesktop(),
        fullyIntegratedWhatsAppBusinessCenter: (context) =>
            const FullyIntegratedWhatsAppBusinessCenter(),
        completeTwilioCommunicationSuite: (context) =>
            const CompleteTwilioCommunicationSuite(),
        // TODO: Add your other routes here
      };
}

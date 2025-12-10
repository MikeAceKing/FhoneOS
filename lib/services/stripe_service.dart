import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StripeService {
  static final StripeService _instance = StripeService._internal();

  factory StripeService() {
    return _instance;
  }

  StripeService._internal();

  static const String stripePublishableKey =
      String.fromEnvironment('STRIPE_PUBLISHABLE_KEY');

  void initialize() {
    if (stripePublishableKey.isEmpty) {
      throw Exception(
          'STRIPE_PUBLISHABLE_KEY must be provided via --dart-define');
    }
    Stripe.publishableKey = stripePublishableKey;
  }

  Future<void> initializePaymentSheet({
    required String planId,
    required String accountId,
  }) async {
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase.functions.invoke(
        'create-stripe-session',
        body: {
          'plan_id': planId,
          'account_id': accountId,
        },
      );

      final data = response.data as Map<String, dynamic>;
      final clientSecret = data['payment_intent_client_secret'] as String?;

      if (clientSecret == null) {
        throw Exception('Missing client secret from backend');
      }

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'FhoneOS',
          style: ThemeMode.system,
          allowsDelayedPaymentMethods: true,
        ),
      );
    } catch (e) {
      throw StripeException(message: 'Failed to initialize payment sheet: $e');
    }
  }

  Future<void> presentPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet();
    } on StripeException catch (e) {
      throw StripeException(
          message: e.message);
    } catch (e) {
      throw StripeException(message: 'Unexpected error during payment: $e');
    }
  }

  Future<bool> checkPlatformPaySupport() async {
    try {
      return await Stripe.instance.isPlatformPaySupported();
    } catch (e) {
      return false;
    }
  }
}

class StripeException implements Exception {
  final String message;

  StripeException({required this.message});

  @override
  String toString() => 'StripeException: $message';
}
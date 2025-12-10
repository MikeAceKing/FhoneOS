import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/fhoneos_subscription_plan.dart';

class FhoneOSSubscriptionService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Fetch all active FhoneOS subscription plans
  Future<List<FhoneOSSubscriptionPlan>> getAvailablePlans() async {
    try {
      final response = await _supabase
          .from('plans')
          .select()
          .eq('is_active', true)
          .like('code', 'fhoneos_%')
          .order('price_monthly', ascending: true);

      return (response as List)
          .map((json) => FhoneOSSubscriptionPlan.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch plans: $e');
    }
  }

  /// Get user's current subscription details
  Future<Map<String, dynamic>?> getCurrentSubscription() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return null;

      // Get account ID for user
      final accountUser = await _supabase
          .from('account_users')
          .select('account_id')
          .eq('user_id', userId)
          .single();

      final accountId = accountUser['account_id'];

      // Get active subscription with plan details
      final subscription = await _supabase
          .from('account_subscriptions')
          .select('''
            id,
            status,
            stripe_customer_id,
            stripe_subscription_id,
            current_period_start,
            current_period_end,
            plans (
              id,
              code,
              name,
              description,
              price_monthly,
              minutes_included,
              sms_included,
              stripe_price_id,
              profit_margin_eur
            )
          ''')
          .eq('account_id', accountId)
          .eq('status', 'active')
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      return subscription;
    } catch (e) {
      throw Exception('Failed to fetch subscription: $e');
    }
  }

  /// Check bundle usage limits (minutes/SMS)
  Future<Map<String, dynamic>> checkBundleLimit(String usageType) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final accountUser = await _supabase
          .from('account_users')
          .select('account_id')
          .eq('user_id', userId)
          .single();

      final accountId = accountUser['account_id'];

      final result = await _supabase.rpc(
        'check_bundle_limit',
        params: {
          'p_account_id': accountId,
          'p_usage_type': usageType,
        },
      );

      return result as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to check bundle limit: $e');
    }
  }

  /// Get subscription usage statistics
  Future<SubscriptionUsage> getUsageStatistics() async {
    try {
      final subscription = await getCurrentSubscription();
      if (subscription == null) {
        return const SubscriptionUsage(
          minutesUsed: 0,
          minutesLimit: 0,
          smsUsed: 0,
          smsLimit: 0,
        );
      }

      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');
      final accountUser = await _supabase
          .from('account_users')
          .select('account_id')
          .eq('user_id', userId)
          .single();

      final accountId = accountUser['account_id'];
      final periodStart = DateTime.parse(subscription['current_period_start']);
      final periodEnd = DateTime.parse(subscription['current_period_end']);

      final usageRecords = await _supabase
          .from('usage_records')
          .select('usage_type, duration_seconds, quantity')
          .eq('account_id', accountId)
          .gte('created_at', periodStart.toIso8601String())
          .lte('created_at', periodEnd.toIso8601String());

      int minutesUsed = 0;
      int smsUsed = 0;

      for (var record in usageRecords) {
        if (record['usage_type'] == 'call') {
          minutesUsed += ((record['duration_seconds'] as int) / 60).ceil();
        } else if (record['usage_type'] == 'sms') {
          smsUsed += (record['quantity'] as num).toInt();
        }
      }

      final plan = subscription['plans'];
      return SubscriptionUsage(
        minutesUsed: minutesUsed,
        minutesLimit: plan['minutes_included'] as int,
        smsUsed: smsUsed,
        smsLimit: plan['sms_included'] as int,
        periodStart: periodStart,
        periodEnd: periodEnd,
      );
    } catch (e) {
      throw Exception('Failed to fetch usage statistics: $e');
    }
  }

  /// Cancel subscription
  Future<void> cancelSubscription() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final accountUser = await _supabase
          .from('account_users')
          .select('account_id')
          .eq('user_id', userId)
          .single();

      await _supabase
          .from('account_subscriptions')
          .update({'status': 'canceled'})
          .eq('account_id', accountUser['account_id'])
          .eq('status', 'active');
    } catch (e) {
      throw Exception('Failed to cancel subscription: $e');
    }
  }
}
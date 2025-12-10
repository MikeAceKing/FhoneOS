import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/subscription_plan.dart';

class SubscriptionService {
  final _supabase = Supabase.instance.client;

  Future<SubscriptionPlan?> getPlanById(String planId) async {
    try {
      final response =
          await _supabase.from('plans').select().eq('id', planId).single();

      return SubscriptionPlan.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch plan: $e');
    }
  }

  Future<Map<String, dynamic>?> getActiveSubscription(String accountId) async {
    try {
      final response = await _supabase
          .from('account_subscriptions')
          .select('*, plans(*)')
          .eq('account_id', accountId)
          .inFilter('status', ['active', 'trialing']).maybeSingle();

      return response;
    } catch (e) {
      throw Exception('Failed to fetch active subscription: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getBillingHistory(String accountId) async {
    try {
      final response = await _supabase
          .from('wallet_transactions')
          .select()
          .eq('account_id', accountId)
          .order('created_at', ascending: false)
          .limit(20);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to fetch billing history: $e');
    }
  }

  Future<void> createSubscription({
    required String accountId,
    required String planId,
    required String paymentType,
  }) async {
    try {
      final now = DateTime.now();
      final endsAt = now.add(const Duration(days: 365));

      await _supabase.from('account_subscriptions').insert({
        'account_id': accountId,
        'plan_id': planId,
        'payment_type': paymentType,
        'status': 'active',
        'started_at': now.toIso8601String(),
        'ends_at': endsAt.toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to create subscription: $e');
    }
  }

  Future<void> updateAutoRenewal({
    required String subscriptionId,
    required bool enabled,
  }) async {
    try {
      await _supabase.from('account_subscriptions').update({
        'status': enabled ? 'active' : 'canceled',
      }).eq('id', subscriptionId);
    } catch (e) {
      throw Exception('Failed to update auto-renewal: $e');
    }
  }

  Future<void> cancelSubscription(String subscriptionId) async {
    try {
      await _supabase.from('account_subscriptions').update({
        'status': 'canceled',
      }).eq('id', subscriptionId);
    } catch (e) {
      throw Exception('Failed to cancel subscription: $e');
    }
  }
}
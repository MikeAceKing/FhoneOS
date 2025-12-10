import 'package:supabase_flutter/supabase_flutter.dart';

class PhoneNumberService {
  final client = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getAvailableNumbers({
    String? countryCode,
    String? searchPattern,
    bool? smsEnabled,
    bool? voiceEnabled,
  }) async {
    try {
      var query = client
          .from('phone_numbers')
          .select('*, accounts!inner(name)')
          .eq('status', 'active');

      if (countryCode != null) {
        query = query.eq('country_code', countryCode);
      }

      if (searchPattern != null && searchPattern.isNotEmpty) {
        query = query.like('e164_number', '%$searchPattern%');
      }

      if (smsEnabled != null) {
        query = query.eq('capabilities->sms', smsEnabled);
      }

      if (voiceEnabled != null) {
        query = query.eq('capabilities->voice', voiceEnabled);
      }

      final response =
          await query.order('created_at', ascending: false).limit(50);
      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to fetch available numbers: $error');
    }
  }

  Future<Map<String, dynamic>> purchaseNumber({
    required String accountId,
    required String phoneNumberId,
    required double purchasePrice,
    required double monthlyCost,
  }) async {
    try {
      // Use maybeSingle() to handle 0 rows gracefully
      final walletCheck = await client
          .from('accounts')
          .select('wallet_balance')
          .eq('id', accountId)
          .maybeSingle();

      if (walletCheck == null) {
        throw Exception('Account not found. Please contact support.');
      }

      final currentBalance = (walletCheck['wallet_balance'] as num).toDouble();

      if (currentBalance < purchasePrice) {
        throw Exception('Insufficient wallet balance');
      }

      final purchaseData = {
        'account_id': accountId,
        'phone_number_id': phoneNumberId,
        'purchase_price': purchasePrice,
        'monthly_cost': monthlyCost,
        'activation_date': DateTime.now().toIso8601String(),
      };

      final purchase = await client
          .from('number_purchases')
          .insert(purchaseData)
          .select()
          .single();

      await client.from('wallet_transactions').insert({
        'account_id': accountId,
        'amount': purchasePrice,
        'transaction_type': 'debit',
        'description': 'Phone number purchase',
        'reference_id': purchase['id'],
      });

      return purchase;
    } catch (error) {
      throw Exception('Failed to purchase number: $error');
    }
  }

  Future<List<Map<String, dynamic>>> getAccountPhoneNumbers(
      String accountId) async {
    try {
      final response = await client
          .from('phone_numbers')
          .select(
              '*, number_purchases!inner(purchase_price, monthly_cost, purchase_date)')
          .eq('account_id', accountId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to fetch account phone numbers: $error');
    }
  }

  Future<Map<String, dynamic>> getNumberUsageStats(
      String phoneNumberId, DateTime startDate, DateTime endDate) async {
    try {
      final usageData = await client
          .from('usage_records')
          .select('usage_type, quantity, cost, direction')
          .eq('phone_number_id', phoneNumberId)
          .gte('created_at', startDate.toIso8601String())
          .lte('created_at', endDate.toIso8601String());

      final List<dynamic> records = usageData;

      double totalCalls = 0;
      double totalSms = 0;
      double totalData = 0;
      double totalCost = 0;

      for (final record in records) {
        final cost = (record['cost'] as num).toDouble();
        totalCost += cost;

        switch (record['usage_type']) {
          case 'call':
            totalCalls += (record['quantity'] as num).toDouble();
            break;
          case 'sms':
            totalSms += (record['quantity'] as num).toDouble();
            break;
          case 'data':
            totalData += (record['quantity'] as num).toDouble();
            break;
        }
      }

      return {
        'total_calls': totalCalls,
        'total_sms': totalSms,
        'total_data': totalData,
        'total_cost': totalCost,
        'period_start': startDate.toIso8601String(),
        'period_end': endDate.toIso8601String(),
      };
    } catch (error) {
      throw Exception('Failed to fetch usage stats: $error');
    }
  }

  Future<double> getWalletBalance(String accountId) async {
    try {
      // Use maybeSingle() instead of single() to handle 0 rows case
      final response = await client
          .from('accounts')
          .select('wallet_balance')
          .eq('id', accountId)
          .maybeSingle();

      // Return 0 if no wallet exists yet
      if (response == null) {
        return 0.0;
      }

      return (response['wallet_balance'] as num?)?.toDouble() ?? 0.0;
    } catch (error) {
      // Silent fallback for any errors - return 0 instead of throwing
      return 0.0;
    }
  }

  Future<List<Map<String, dynamic>>> getWalletTransactions(
      String accountId) async {
    try {
      final response = await client
          .from('wallet_transactions')
          .select()
          .eq('account_id', accountId)
          .order('created_at', ascending: false)
          .limit(50);

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to fetch wallet transactions: $error');
    }
  }

  Future<void> topUpWallet(String accountId, double amount) async {
    try {
      await client.from('wallet_transactions').insert({
        'account_id': accountId,
        'amount': amount,
        'transaction_type': 'credit',
        'description': 'Wallet top-up via Stripe',
      });
    } catch (error) {
      throw Exception('Failed to top up wallet: $error');
    }
  }
}

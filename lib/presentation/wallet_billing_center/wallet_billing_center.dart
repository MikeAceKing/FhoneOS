import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../services/supabase_service.dart';
import './widgets/billing_history_widget.dart';
import './widgets/payment_methods_widget.dart';
import './widgets/quick_topup_widget.dart';
import './widgets/subscription_summary_widget.dart';
import './widgets/transaction_history_widget.dart';
import './widgets/usage_alerts_widget.dart';
import './widgets/wallet_balance_card_widget.dart';

/// Wallet & Billing Center Screen
/// Comprehensive financial management for telecom services
class WalletBillingCenter extends StatefulWidget {
  const WalletBillingCenter({super.key});

  @override
  State<WalletBillingCenter> createState() => _WalletBillingCenterState();
}

class _WalletBillingCenterState extends State<WalletBillingCenter>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _supabaseService = SupabaseService.instance;

  bool _isLoading = true;
  Map<String, dynamic>? _accountData;
  Map<String, dynamic>? _billingSummary;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadWalletData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadWalletData() async {
    setState(() => _isLoading = true);
    try {
      // Get current user's account
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Fetch account with wallet balance
      final accountResponse = await Supabase.instance.client
          .from('account_users')
          .select('account_id, accounts!inner(*)')
          .eq('user_id', userId)
          .single();

      final accountId = accountResponse['accounts']['id'];

      // Fetch billing summary using function
      final summaryResponse = await Supabase.instance.client
          .rpc('get_billing_summary', params: {'p_account_id': accountId});

      setState(() {
        _accountData = accountResponse['accounts'];
        _billingSummary = summaryResponse;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load wallet data: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      appBar: AppBar(
        backgroundColor: const Color(0xFF020617),
        elevation: 0,
        title: const Text(
          'Wallet & Billing',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, size: 22),
            onPressed: _loadWalletData,
          ),
          IconButton(
            icon: const Icon(Icons.help_outline, size: 22),
            onPressed: () {
              // Show help/FAQ
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF6366F1),
          labelColor: const Color(0xFF6366F1),
          unselectedLabelColor: Colors.white60,
          labelStyle:
              const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Payments'),
            Tab(text: 'History'),
            Tab(text: 'Alerts'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF6366F1),
              ),
            )
          : RefreshIndicator(
              color: const Color(0xFF6366F1),
              onRefresh: _loadWalletData,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildOverviewTab(),
                  _buildPaymentsTab(),
                  _buildHistoryTab(),
                  _buildAlertsTab(),
                ],
              ),
            ),
    );
  }

  Widget _buildOverviewTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        WalletBalanceCard(
          balance: _accountData?['wallet_balance'] ?? 0.0,
          currency: _accountData?['wallet_currency'] ?? 'EUR',
          onTopUp: _handleTopUp,
        ),
        const SizedBox(height: 16),
        QuickTopUpWidget(
          onAmountSelected: _handleQuickTopUp,
        ),
        const SizedBox(height: 16),
        SubscriptionSummaryWidget(
          totalSpent: _billingSummary?['total_spent'] ?? 0.0,
          subscriptionCost: _billingSummary?['subscription_cost'] ?? 0.0,
          callCost: _billingSummary?['call_cost'] ?? 0.0,
          messageCost: _billingSummary?['message_cost'] ?? 0.0,
        ),
        const SizedBox(height: 16),
        TransactionHistoryWidget(
          accountId: _accountData?['id'],
          limit: 5,
        ),
      ],
    );
  }

  Widget _buildPaymentsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        PaymentMethodsWidget(
          accountId: _accountData?['id'],
          onMethodAdded: _loadWalletData,
        ),
        const SizedBox(height: 16),
        _buildAutoReloadSection(),
      ],
    );
  }

  Widget _buildHistoryTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        BillingHistoryWidget(
          accountId: _accountData?['id'],
        ),
      ],
    );
  }

  Widget _buildAlertsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        UsageAlertsWidget(
          accountId: _accountData?['id'],
          currentBalance: _accountData?['wallet_balance'] ?? 0.0,
        ),
      ],
    );
  }

  Widget _buildAutoReloadSection() {
    final autoReloadEnabled = _accountData?['auto_reload_enabled'] ?? false;
    final autoReloadAmount = _accountData?['auto_reload_amount'] ?? 10.0;
    final autoReloadThreshold = _accountData?['auto_reload_threshold'] ?? 5.0;

    return Card(
      color: const Color(0xFF020617),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Color(0xFF1E293B)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Auto-Reload',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Automatically top up when balance is low',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white60,
                      ),
                    ),
                  ],
                ),
                Switch(
                  value: autoReloadEnabled,
                  activeColor: const Color(0xFF6366F1),
                  onChanged: (value) => _toggleAutoReload(value),
                ),
              ],
            ),
            if (autoReloadEnabled) ...[
              const SizedBox(height: 16),
              const Divider(color: Color(0xFF1E293B)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildAutoReloadField(
                      'Reload Amount',
                      '€${autoReloadAmount.toStringAsFixed(2)}',
                      Icons.euro,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildAutoReloadField(
                      'When Below',
                      '€${autoReloadThreshold.toStringAsFixed(2)}',
                      Icons.trending_down,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Show auto-reload settings dialog
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E293B),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  child: const Text('Configure Auto-Reload'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAutoReloadField(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: Colors.white60),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.white60,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleTopUp() async {
    // TODO: Show top-up dialog with payment options
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Top Up Wallet'),
        content: const Text(
            'Top-up functionality will be integrated with payment provider'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleQuickTopUp(double amount) async {
    // TODO: Process quick top-up
    await _handleTopUp();
  }

  Future<void> _toggleAutoReload(bool enabled) async {
    try {
      final accountId = _accountData?['id'];
      if (accountId == null) return;

      await Supabase.instance.client
          .from('accounts')
          .update({'auto_reload_enabled': enabled}).eq('id', accountId);

      setState(() {
        _accountData?['auto_reload_enabled'] = enabled;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              enabled ? 'Auto-reload enabled' : 'Auto-reload disabled',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update auto-reload: $e')),
        );
      }
    }
  }
}
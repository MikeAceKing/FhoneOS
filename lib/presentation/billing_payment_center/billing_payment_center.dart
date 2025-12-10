import 'package:flutter/material.dart';

import '../../models/fhoneos_subscription_plan.dart';
import '../../services/fhoneos_subscription_service.dart';
import './widgets/billing_history_widget.dart';
import './widgets/current_subscription_widget.dart';
import './widgets/plan_selection_widget.dart';
import './widgets/usage_overview_widget.dart';

class BillingPaymentCenter extends StatefulWidget {
  const BillingPaymentCenter({super.key});

  @override
  State<BillingPaymentCenter> createState() => _BillingPaymentCenterState();
}

class _BillingPaymentCenterState extends State<BillingPaymentCenter>
    with SingleTickerProviderStateMixin {
  final _subscriptionService = FhoneOSSubscriptionService();
  late TabController _tabController;

  Map<String, dynamic>? _currentSubscription;
  SubscriptionUsage? _usageStats;
  List<FhoneOSSubscriptionPlan> _availablePlans = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final subscription = await _subscriptionService.getCurrentSubscription();
      final plans = await _subscriptionService.getAvailablePlans();

      SubscriptionUsage? usage;
      if (subscription != null) {
        usage = await _subscriptionService.getUsageStatistics();
      }

      setState(() {
        _currentSubscription = subscription;
        _availablePlans = plans;
        _usageStats = usage;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Billing & Payment Center'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.payment), text: 'Subscription'),
            Tab(icon: Icon(Icons.bar_chart), text: 'Usage'),
            Tab(icon: Icon(Icons.history), text: 'History'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Error: $_error'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadData,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildSubscriptionTab(),
                    _buildUsageTab(),
                    const BillingHistoryWidget(),
                  ],
                ),
    );
  }

  Widget _buildSubscriptionTab() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_currentSubscription != null) ...[
              CurrentSubscriptionWidget(
                subscription: _currentSubscription!,
                onCancelPressed: _handleCancelSubscription,
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 24),
            ],
            const Text(
              'Available Plans',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            PlanSelectionWidget(
              plans: _availablePlans,
              currentPlanId: _currentSubscription?['plans']?['id'],
              onPlanSelected: _handlePlanSelection,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsageTab() {
    if (_currentSubscription == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.info_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No active subscription',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Subscribe to a plan to view usage statistics'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _tabController.animateTo(0),
              child: const Text('View Plans'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: UsageOverviewWidget(
          usage: _usageStats ??
              const SubscriptionUsage(
                minutesUsed: 0,
                minutesLimit: 0,
                smsUsed: 0,
                smsLimit: 0,
              ),
          onRefresh: _loadData,
        ),
      ),
    );
  }

  Future<void> _handlePlanSelection(String planId) async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // TODO: Implement Stripe checkout flow
      // This will be handled by the create-stripe-session edge function

      if (!mounted) return;
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Redirecting to payment...'),
          backgroundColor: Colors.blue,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleCancelSubscription() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Subscription'),
        content: const Text(
          'Are you sure you want to cancel your subscription? '
          'You will retain access until the end of your billing period.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep Subscription'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Cancel Subscription'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _subscriptionService.cancelSubscription();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Subscription cancelled successfully'),
          backgroundColor: Colors.green,
        ),
      );

      await _loadData();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error cancelling subscription: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

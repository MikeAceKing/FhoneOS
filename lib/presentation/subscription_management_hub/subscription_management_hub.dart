import 'package:flutter/material.dart';

import '../../models/fhoneos_plan.dart';
import '../../models/subscription_usage.dart';
import '../../services/fhoneos_subscription_service.dart';
import './widgets/plan_card_widget.dart';
import './widgets/subscription_details_widget.dart';
import './widgets/usage_stats_widget.dart';

class SubscriptionManagementHub extends StatefulWidget {
  const SubscriptionManagementHub({super.key});

  @override
  State<SubscriptionManagementHub> createState() =>
      _SubscriptionManagementHubState();
}

class _SubscriptionManagementHubState extends State<SubscriptionManagementHub> {
  final _subscriptionService = FhoneOSSubscriptionService();

  List<FhoneOSPlan> _plans = [];
  Map<String, dynamic>? _currentSubscription;
  SubscriptionUsage? _usageSummary;
  bool _isLoading = true;
  String? _errorMessage;
  bool _showPlanSelection = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final accountId =
          'f35b9d52-c5f9-409f-bfab-bd4cc8f8fe10'; // Get from auth context

      final results = await Future.wait<dynamic>([
        _subscriptionService.getAvailablePlans(),
        _subscriptionService.getCurrentSubscription(),
        _subscriptionService.getUsageStatistics(),
      ]);

      setState(() {
        _plans = results[0] as List<FhoneOSPlan>;
        _currentSubscription = results[1] as Map<String, dynamic>?;
        _usageSummary = results[2] as SubscriptionUsage?;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _handlePlanSelection(FhoneOSPlan plan) async {
    try {
      final accountId =
          'f35b9d52-c5f9-409f-bfab-bd4cc8f8fe10'; // Get from auth context
      // Remove the createStripeCheckoutSession call
      // TODO: Implement plan selection logic
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Plan selectie functionaliteit komt binnenkort'),
            backgroundColor: Colors.blue,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fout bij starten betaling: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Abonnement Beheer'),
        actions: [
          if (_currentSubscription != null)
            IconButton(
              icon: const Icon(Icons.swap_horiz),
              tooltip: 'Wijzig abonnement',
              onPressed: () {
                setState(() {
                  _showPlanSelection = !_showPlanSelection;
                });
              },
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline,
                          size: 64, color: Colors.red[300]),
                      const SizedBox(height: 16),
                      Text(
                        'Fout bij laden',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _loadData,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Opnieuw proberen'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_currentSubscription != null &&
                            !_showPlanSelection) ...[
                          SubscriptionDetailsWidget(
                            subscription: _currentSubscription!,
                            onChangePress: () {
                              setState(() {
                                _showPlanSelection = true;
                              });
                            },
                          ),
                          const SizedBox(height: 24),
                          if (_usageSummary != null) ...[
                            UsageStatsWidget(usage: _usageSummary!),
                            const SizedBox(height: 24),
                          ],
                        ],
                        if (_currentSubscription == null ||
                            _showPlanSelection) ...[
                          Text(
                            _currentSubscription == null
                                ? 'Kies uw abonnement'
                                : 'Wijzig abonnement',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _currentSubscription == null
                                ? 'Selecteer het abonnement dat bij uw behoeften past'
                                : 'Wijzig naar een ander abonnement',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Colors.grey[600],
                                ),
                          ),
                          const SizedBox(height: 24),
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _plans.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 16),
                            itemBuilder: (context, index) {
                              final plan = _plans[index];
                              final isCurrentPlan = _currentSubscription !=
                                      null &&
                                  _currentSubscription!['plan_id'] == plan.id;

                              return PlanCardWidget(
                                plan: plan,
                                isCurrentPlan: isCurrentPlan,
                                onSelect: () => _handlePlanSelection(plan),
                              );
                            },
                          ),
                          if (_showPlanSelection) ...[
                            const SizedBox(height: 16),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _showPlanSelection = false;
                                });
                              },
                              child: const Text('Annuleren'),
                            ),
                          ],
                        ],
                      ],
                    ),
                  ),
                ),
    );
  }
}
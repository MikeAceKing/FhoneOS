import 'package:flutter/material.dart';

import '../../services/supabase_service.dart';
import './widgets/plan_tier_card_widget.dart';
import './widgets/add_ons_section_widget.dart';
import './widgets/payment_options_widget.dart';
import './widgets/feature_comparison_widget.dart';

/// FhoneOS Subscription Plans - Complete subscription selection system
/// Displays 4-tier plans with add-ons and Stripe payment integration
class FhoneOsSubscriptionPlans extends StatefulWidget {
  const FhoneOsSubscriptionPlans({super.key});

  @override
  State<FhoneOsSubscriptionPlans> createState() =>
      _FhoneOsSubscriptionPlansState();
}

class _FhoneOsSubscriptionPlansState extends State<FhoneOsSubscriptionPlans> {
  List<Map<String, dynamic>> _plans = [];
  List<Map<String, dynamic>> _addons = [];
  bool _isLoading = true;
  String? _selectedPlanId;
  List<String> _selectedAddonIds = [];
  String _paymentType = 'monthly_term'; // monthly_term or yearly_full

  @override
  void initState() {
    super.initState();
    _loadPlansAndAddons();
  }

  Future<void> _loadPlansAndAddons() async {
    try {
      final client = SupabaseService.instance.client;

      // Load FhoneOS plans
      final plansResponse = await client
          .from('plans')
          .select()
          .like('code', 'fhoneos_%')
          .eq('is_active', true)
          .order('price_monthly', ascending: true);

      // Load add-ons
      final addonsResponse = await client
          .from('addons')
          .select()
          .eq('is_active', true)
          .order('type', ascending: true);

      setState(() {
        _plans = List<Map<String, dynamic>>.from(plansResponse);
        _addons = List<Map<String, dynamic>>.from(addonsResponse);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load plans: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handlePlanSelection(String planId) {
    setState(() => _selectedPlanId = planId);
  }

  void _handleAddonToggle(String addonId) {
    setState(() {
      if (_selectedAddonIds.contains(addonId)) {
        _selectedAddonIds.remove(addonId);
      } else {
        _selectedAddonIds.add(addonId);
      }
    });
  }

  void _handlePaymentTypeChange(String type) {
    setState(() => _paymentType = type);
  }

  double _calculateTotal() {
    double total = 0.0;

    // Add plan price
    if (_selectedPlanId != null) {
      final plan = _plans.firstWhere((p) => p['id'] == _selectedPlanId);
      total +=
          _paymentType == 'yearly_full'
              ? (plan['price_yearly'] ?? 0.0).toDouble()
              : (plan['price_monthly'] ?? 0.0).toDouble();
    }

    // Add addon prices
    for (final addonId in _selectedAddonIds) {
      final addon = _addons.firstWhere((a) => a['id'] == addonId);
      total += (addon['price'] ?? 0.0).toDouble();
    }

    return total;
  }

  Future<void> _handleCheckout() async {
    if (_selectedPlanId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a plan first')),
      );
      return;
    }

    // TODO: Implement Stripe checkout
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Checkout with plan $_selectedPlanId and ${_selectedAddonIds.length} add-ons',
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Choose Your Plan'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    Text(
                      'Select your FhoneOS subscription',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      'Annual commitment with flexible payment options',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.7,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24.0),

                    // Plan tier cards
                    ..._plans.map(
                      (plan) => Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: PlanTierCardWidget(
                          plan: plan,
                          isSelected: _selectedPlanId == plan['id'],
                          onSelect: () => _handlePlanSelection(plan['id']),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24.0),

                    // Add-ons section
                    if (_selectedPlanId != null) ...[
                      AddOnsSectionWidget(
                        addons: _addons,
                        selectedIds: _selectedAddonIds,
                        onToggle: _handleAddonToggle,
                      ),

                      const SizedBox(height: 24.0),

                      // Payment options
                      PaymentOptionsWidget(
                        selectedType: _paymentType,
                        onTypeChange: _handlePaymentTypeChange,
                      ),

                      const SizedBox(height: 24.0),

                      // Feature comparison
                      FeatureComparisonWidget(plans: _plans),

                      const SizedBox(height: 32.0),

                      // Total and checkout
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '€${_calculateTotal().toStringAsFixed(2)}',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8.0),
                            Text(
                              _paymentType == 'yearly_full'
                                  ? 'Paid annually in full'
                                  : 'Billed monthly (12-month commitment)',
                              style: theme.textTheme.bodySmall,
                            ),
                            const SizedBox(height: 16.0),
                            ElevatedButton(
                              onPressed: _handleCheckout,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16.0,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                              ),
                              child: const Text('Continue to Checkout'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
    );
  }
}

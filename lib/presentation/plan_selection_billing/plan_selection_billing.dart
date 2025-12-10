import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/app_export.dart';
import '../../models/subscription_plan.dart';
import '../../routes/app_routes.dart';
import '../../services/stripe_service.dart';
import './widgets/billing_summary_widget.dart';
import './widgets/plan_card_widget.dart';

class PlanSelectionBillingScreen extends StatefulWidget {
  const PlanSelectionBillingScreen({super.key});

  @override
  State<PlanSelectionBillingScreen> createState() =>
      _PlanSelectionBillingScreenState();
}

class _PlanSelectionBillingScreenState
    extends State<PlanSelectionBillingScreen> {
  final _stripeService = StripeService();
  final _supabase = Supabase.instance.client;

  List<SubscriptionPlan> _plans = [];
  bool _isLoading = false;
  bool _isYearly = false;
  String? _error;
  String? _selectedPlanId;

  @override
  void initState() {
    super.initState();
    _stripeService.initialize();
    _loadPlans();
  }

  Future<void> _loadPlans() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response =
          await _supabase.from('plans').select().eq('is_active', true);

      final plans = (response as List)
          .map((json) => SubscriptionPlan.fromJson(json))
          .toList();

      setState(() {
        _plans = plans;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load plans: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _selectPlan(String planId) async {
    setState(() {
      _isLoading = true;
      _error = null;
      _selectedPlanId = planId;
    });

    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('Please sign in to continue');
      }

      final accountResponse = await _supabase
          .from('account_users')
          .select('account_id')
          .eq('user_id', user.id)
          .single();

      final accountId = accountResponse['account_id'] as String;

      await _stripeService.initializePaymentSheet(
        planId: planId,
        accountId: accountId,
      );

      await _stripeService.presentPaymentSheet();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment successful! Subscription activated.'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushReplacementNamed(context, AppRoutes.fhoneOsDashboard);
    } catch (e) {
      setState(() {
        _error = e.toString();
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
        _selectedPlanId = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Your Plan'),
        elevation: 0,
      ),
      body: _isLoading && _plans.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline,
                          size: 64, color: Colors.red.shade300),
                      const SizedBox(height: 16),
                      Text(_error!, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadPlans,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      // Billing cycle toggle
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: _buildCycleButton(
                                  'Monthly',
                                  !_isYearly,
                                  () => setState(() => _isYearly = false),
                                ),
                              ),
                              Expanded(
                                child: _buildCycleButton(
                                  'Yearly (Save 20%)',
                                  _isYearly,
                                  () => setState(() => _isYearly = true),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Plans list
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _plans.length,
                        itemBuilder: (context, index) {
                          final plan = _plans[index];
                          return PlanCardWidget(
                            plan: plan,
                            isYearly: _isYearly,
                            isSelected: _selectedPlanId == plan.id,
                            isLoading: _isLoading && _selectedPlanId == plan.id,
                            onSelect: () => _selectPlan(plan.id),
                          );
                        },
                      ),

                      // Billing summary
                      if (_selectedPlanId != null)
                        BillingSummaryWidget(
                          plan:
                              _plans.firstWhere((p) => p.id == _selectedPlanId),
                          isYearly: _isYearly,
                        ),

                      const SizedBox(height: 24),

                      // Support text
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          'All plans include 24/7 customer support and 30-day money-back guarantee',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
    );
  }

  Widget _buildCycleButton(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
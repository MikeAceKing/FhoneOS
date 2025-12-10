import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import '../../models/subscription_plan.dart';
import '../../routes/app_routes.dart';
import '../../services/stripe_service.dart';
import '../../services/subscription_service.dart';
import './widgets/auto_renewal_widget.dart';
import './widgets/billing_history_widget.dart';
import './widgets/contract_terms_widget.dart';
import './widgets/payment_method_selection_widget.dart';

class StripePaymentContractManagement extends StatefulWidget {
  final String? selectedPlanId;
  final String? accountId;

  const StripePaymentContractManagement({
    super.key,
    this.selectedPlanId,
    this.accountId,
  });

  @override
  State<StripePaymentContractManagement> createState() =>
      _StripePaymentContractManagementState();
}

class _StripePaymentContractManagementState
    extends State<StripePaymentContractManagement> {
  final _stripeService = StripeService();
  final _subscriptionService = SubscriptionService();

  bool _isLoading = false;
  SubscriptionPlan? _selectedPlan;
  String _paymentType = 'monthly_term';
  Map<String, dynamic>? _activeSubscription;
  List<Map<String, dynamic>> _billingHistory = [];
  bool _autoRenewalEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSubscriptionData();
  }

  Future<void> _loadSubscriptionData() async {
    if (widget.accountId == null) return;

    setState(() => _isLoading = true);

    try {
      final subscription =
          await _subscriptionService.getActiveSubscription(widget.accountId!);
      final history =
          await _subscriptionService.getBillingHistory(widget.accountId!);

      if (widget.selectedPlanId != null) {
        final plan =
            await _subscriptionService.getPlanById(widget.selectedPlanId!);
        setState(() => _selectedPlan = plan);
      }

      setState(() {
        _activeSubscription = subscription;
        _billingHistory = history;
        _autoRenewalEnabled =
            subscription?['status'] != 'canceled' && subscription != null;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading subscription data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _processPayment() async {
    if (_selectedPlan == null || widget.accountId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a plan to continue'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _stripeService.initializePaymentSheet(
        planId: _selectedPlan!.id,
        accountId: widget.accountId!,
      );

      await _stripeService.presentPaymentSheet();

      await _subscriptionService.createSubscription(
        accountId: widget.accountId!,
        planId: _selectedPlan!.id,
        paymentType: _paymentType,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment successful! Subscription activated.'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushReplacementNamed(context, AppRoutes.fhoneOsDashboard);
      }
    } on StripeException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment failed: ${e.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unexpected error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleAutoRenewal(bool enabled) async {
    if (widget.accountId == null || _activeSubscription == null) return;

    setState(() => _isLoading = true);

    try {
      await _subscriptionService.updateAutoRenewal(
        subscriptionId: _activeSubscription!['id'],
        enabled: enabled,
      );

      setState(() => _autoRenewalEnabled = enabled);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              enabled
                  ? 'Auto-renewal enabled'
                  : 'Auto-renewal disabled - subscription will end on expiry date',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating auto-renewal: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Payment & Contract',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: Colors.grey[200],
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_selectedPlan != null) ...[
                    _buildSelectedPlanCard(),
                    const SizedBox(height: 20),
                  ],
                  if (_activeSubscription == null) ...[
                    PaymentMethodSelectionWidget(
                      selectedPaymentType: _paymentType,
                      onPaymentTypeChanged: (type) {
                        setState(() => _paymentType = type);
                      },
                    ),
                    const SizedBox(height: 20),
                    ContractTermsWidget(
                      plan: _selectedPlan,
                      paymentType: _paymentType,
                    ),
                    const SizedBox(height: 24),
                    _buildPaymentButton(),
                  ] else ...[
                    AutoRenewalWidget(
                      enabled: _autoRenewalEnabled,
                      onToggle: _toggleAutoRenewal,
                      subscription: _activeSubscription!,
                    ),
                    const SizedBox(height: 20),
                  ],
                  const SizedBox(height: 20),
                  BillingHistoryWidget(
                    transactions: _billingHistory,
                    accountId: widget.accountId ?? '',
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSelectedPlanCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withAlpha(26),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.workspace_premium,
                    color: Colors.blue, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedPlan!.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _selectedPlan!.description ?? 'Premium features',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),
          _buildPriceDisplay(),
          const SizedBox(height: 16),
          _buildIncludedFeatures(),
        ],
      ),
    );
  }

  Widget _buildPriceDisplay() {
    final monthlyPrice = _selectedPlan!.priceMonthly;
    final yearlyPrice = _selectedPlan!.priceYearly;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Monthly',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '€${monthlyPrice.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.green.withAlpha(26),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Text(
                'Annual Contract',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '€${yearlyPrice.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIncludedFeatures() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Included:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        _buildFeatureItem('${_selectedPlan!.minutesIncluded} minutes'),
        _buildFeatureItem('${_selectedPlan!.smsIncluded} SMS'),
        _buildFeatureItem('${_selectedPlan!.numbersIncluded} phone number(s)'),
        if (_selectedPlan!.aiLevel != 'none')
          _buildFeatureItem('AI ${_selectedPlan!.aiLevel}'),
      ],
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 18),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _processPayment,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    _paymentType == 'yearly_full'
                        ? 'Pay €${_selectedPlan?.priceYearly.toStringAsFixed(2)} Now'
                        : 'Subscribe for €${_selectedPlan?.priceMonthly.toStringAsFixed(2)}/month',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
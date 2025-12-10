import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../services/supabase_service.dart';

class PaymentMethodsWidget extends StatefulWidget {
  final String? accountId;
  final VoidCallback onMethodAdded;

  const PaymentMethodsWidget({
    super.key,
    required this.accountId,
    required this.onMethodAdded,
  });

  @override
  State<PaymentMethodsWidget> createState() => _PaymentMethodsWidgetState();
}

class _PaymentMethodsWidgetState extends State<PaymentMethodsWidget> {
  final _supabaseService = SupabaseService.instance;
  List<Map<String, dynamic>> _paymentMethods = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPaymentMethods();
  }

  Future<void> _loadPaymentMethods() async {
    if (widget.accountId == null) return;

    setState(() => _isLoading = true);
    try {
      final response = await Supabase.instance.client
          .from('payment_methods')
          .select()
          .eq('account_id', widget.accountId!)
          .eq('is_active', true)
          .order('is_default', ascending: false);

      setState(() {
        _paymentMethods = List<Map<String, dynamic>>.from(response);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                      'Payment Methods',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Manage saved payment methods',
                      style: TextStyle(fontSize: 12, color: Colors.white60),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: _handleAddPaymentMethod,
                  icon: const Icon(
                    Icons.add_circle_outline,
                    color: Color(0xFF6366F1),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(color: Color(0xFF6366F1)),
                ),
              )
            else if (_paymentMethods.isEmpty)
              _buildEmptyState()
            else
              ..._paymentMethods
                  .map((method) => _buildPaymentMethodCard(method))
                  .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(Icons.credit_card_off, size: 48, color: Colors.white30),
          const SizedBox(height: 12),
          const Text(
            'No payment methods added',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          const Text(
            'Add a payment method to enable auto-reload',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.white60),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _handleAddPaymentMethod,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add Payment Method'),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodCard(Map<String, dynamic> method) {
    final type = method['type'] as String;
    final isDefault = method['is_default'] as bool;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        border:
            isDefault
                ? Border.all(color: const Color(0xFF6366F1))
                : Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getPaymentIcon(type),
              size: 24,
              color: const Color(0xFF6366F1),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _getPaymentLabel(type, method),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (isDefault) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6366F1).withAlpha(51),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Text(
                          'Default',
                          style: TextStyle(
                            fontSize: 10,
                            color: Color(0xFF6366F1),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  method['billing_name'] ?? 'No name',
                  style: const TextStyle(fontSize: 12, color: Colors.white60),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, size: 20),
            color: const Color(0xFF1E293B),
            onSelected: (value) {
              switch (value) {
                case 'default':
                  _setAsDefault(method['id']);
                  break;
                case 'remove':
                  _removePaymentMethod(method['id']);
                  break;
              }
            },
            itemBuilder:
                (context) => [
                  if (!isDefault)
                    const PopupMenuItem(
                      value: 'default',
                      child: Text('Set as default'),
                    ),
                  const PopupMenuItem(value: 'remove', child: Text('Remove')),
                ],
          ),
        ],
      ),
    );
  }

  IconData _getPaymentIcon(String type) {
    switch (type) {
      case 'card':
        return Icons.credit_card;
      case 'bank_account':
        return Icons.account_balance;
      case 'paypal':
        return Icons.paypal;
      case 'apple_pay':
        return Icons.apple;
      case 'google_pay':
        return Icons.payment;
      default:
        return Icons.payment;
    }
  }

  String _getPaymentLabel(String type, Map<String, dynamic> method) {
    switch (type) {
      case 'card':
        final brand = method['card_brand'] ?? 'Card';
        final last4 = method['card_last4'] ?? '****';
        return '$brand •••• $last4';
      case 'bank_account':
        final last4 = method['account_last4'] ?? '****';
        return 'Bank •••• $last4';
      default:
        return type.toUpperCase();
    }
  }

  Future<void> _handleAddPaymentMethod() async {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF1E293B),
            title: const Text('Add Payment Method'),
            content: const Text(
              'Payment method integration will be connected to Stripe/payment provider',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  Future<void> _setAsDefault(String methodId) async {
    try {
      // Remove default from all methods
      await Supabase.instance.client
          .from('payment_methods')
          .update({'is_default': false})
          .eq('account_id', widget.accountId!);

      // Set new default
      await Supabase.instance.client
          .from('payment_methods')
          .update({'is_default': true})
          .eq('id', methodId);

      await _loadPaymentMethods();
      widget.onMethodAdded();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to set default: $e')));
      }
    }
  }

  Future<void> _removePaymentMethod(String methodId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF1E293B),
            title: const Text('Remove Payment Method'),
            content: const Text(
              'Are you sure you want to remove this payment method?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Remove'),
              ),
            ],
          ),
    );

    if (confirmed != true) return;

    try {
      await Supabase.instance.client
          .from('payment_methods')
          .update({'is_active': false})
          .eq('id', methodId);

      await _loadPaymentMethods();
      widget.onMethodAdded();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to remove method: $e')));
      }
    }
  }
}

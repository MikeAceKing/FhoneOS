import 'package:flutter/material.dart';
import '../../../services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UsageAlertsWidget extends StatefulWidget {
  final String? accountId;
  final double currentBalance;

  const UsageAlertsWidget({
    super.key,
    required this.accountId,
    required this.currentBalance,
  });

  @override
  State<UsageAlertsWidget> createState() => _UsageAlertsWidgetState();
}

class _UsageAlertsWidgetState extends State<UsageAlertsWidget> {
  final _supabaseService = SupabaseService.instance;
  List<Map<String, dynamic>> _alerts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAlerts();
  }

  Future<void> _loadAlerts() async {
    if (widget.accountId == null) return;

    setState(() => _isLoading = true);
    try {
      final response = await Supabase.instance.client
          .from('usage_alerts')
          .select()
          .eq('account_id', widget.accountId!)
          .order('created_at', ascending: false);

      setState(() {
        _alerts = List<Map<String, dynamic>>.from(response);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
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
                    const Text(
                      'Usage Alerts',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton(
                      onPressed: _handleAddAlert,
                      icon: const Icon(
                        Icons.add_circle_outline,
                        color: Color(0xFF6366F1),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Get notified about spending and balance',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white60,
                  ),
                ),
                const SizedBox(height: 16),
                if (_isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(
                        color: Color(0xFF6366F1),
                      ),
                    ),
                  )
                else if (_alerts.isEmpty)
                  _buildEmptyState()
                else
                  ..._alerts.map((alert) => _buildAlertCard(alert)).toList(),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildCurrentStatusCard(),
      ],
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
          const Icon(
            Icons.notifications_off,
            size: 48,
            color: Colors.white30,
          ),
          const SizedBox(height: 12),
          const Text(
            'No alerts configured',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Set up alerts to stay informed',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white60,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _handleAddAlert,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add Alert'),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertCard(Map<String, dynamic> alert) {
    final alertType = alert['alert_type'] as String;
    final isEnabled = alert['is_enabled'] as bool;
    final thresholdAmount = alert['threshold_amount'] as num?;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isEnabled ? const Color(0xFF6366F1) : const Color(0xFF1E293B),
        ),
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
              _getAlertIcon(alertType),
              size: 20,
              color: isEnabled ? const Color(0xFF6366F1) : Colors.white30,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getAlertLabel(alertType),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                if (thresholdAmount != null)
                  Text(
                    'When balance below €${thresholdAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.white60,
                    ),
                  ),
              ],
            ),
          ),
          Switch(
            value: isEnabled,
            activeColor: const Color(0xFF6366F1),
            onChanged: (value) => _toggleAlert(alert['id'], value),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStatusCard() {
    final hasLowBalance = widget.currentBalance < 10.0;

    return Card(
      color: hasLowBalance
          ? const Color(0xFFEF4444).withAlpha(26)
          : const Color(0xFF020617),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color:
              hasLowBalance ? const Color(0xFFEF4444) : const Color(0xFF1E293B),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              hasLowBalance ? Icons.warning : Icons.check_circle,
              color: hasLowBalance
                  ? const Color(0xFFEF4444)
                  : const Color(0xFF22C55E),
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hasLowBalance ? 'Low Balance Warning' : 'Balance Status OK',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    hasLowBalance
                        ? 'Your balance is running low. Consider topping up.'
                        : 'Your balance is healthy.',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white60,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getAlertIcon(String type) {
    switch (type) {
      case 'low_balance':
        return Icons.account_balance_wallet;
      case 'spending_limit':
        return Icons.trending_up;
      case 'usage_threshold':
        return Icons.data_usage;
      default:
        return Icons.notifications;
    }
  }

  String _getAlertLabel(String type) {
    switch (type) {
      case 'low_balance':
        return 'Low Balance Alert';
      case 'spending_limit':
        return 'Spending Limit Alert';
      case 'usage_threshold':
        return 'Usage Threshold Alert';
      default:
        return type;
    }
  }

  Future<void> _handleAddAlert() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Add Alert'),
        content: const Text(
            'Alert configuration will be implemented with form inputs'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleAlert(String alertId, bool enabled) async {
    try {
      await Supabase.instance.client
          .from('usage_alerts')
          .update({'is_enabled': enabled}).eq('id', alertId);

      await _loadAlerts();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to toggle alert: $e')),
        );
      }
    }
  }
}
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../services/supabase_service.dart';

class BillingHistoryWidget extends StatefulWidget {
  final String? accountId;

  const BillingHistoryWidget({super.key, required this.accountId});

  @override
  State<BillingHistoryWidget> createState() => _BillingHistoryWidgetState();
}

class _BillingHistoryWidgetState extends State<BillingHistoryWidget> {
  final _supabaseService = SupabaseService.instance;
  List<Map<String, dynamic>> _payments = [];
  List<Map<String, dynamic>> _calls = [];
  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = true;
  String _selectedCategory = 'all';

  @override
  void initState() {
    super.initState();
    _loadBillingHistory();
  }

  Future<void> _loadBillingHistory() async {
    if (widget.accountId == null) return;

    setState(() => _isLoading = true);
    try {
      // Load payments
      final paymentsResponse = await Supabase.instance.client
          .from('payments')
          .select()
          .eq('account_id', widget.accountId!)
          .order('created_at', ascending: false)
          .limit(50);

      // Load calls with pricing
      final callsResponse = await Supabase.instance.client
          .from('calls')
          .select()
          .eq('account_id', widget.accountId!)
          .not('price', 'is', null)
          .order('created_at', ascending: false)
          .limit(50);

      // Load messages with pricing
      final messagesResponse = await Supabase.instance.client
          .from('messages')
          .select()
          .eq('account_id', widget.accountId!)
          .not('price', 'is', null)
          .order('created_at', ascending: false)
          .limit(50);

      setState(() {
        _payments = List<Map<String, dynamic>>.from(paymentsResponse);
        _calls = List<Map<String, dynamic>>.from(callsResponse);
        _messages = List<Map<String, dynamic>>.from(messagesResponse);
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
        _buildCategoryFilter(),
        const SizedBox(height: 16),
        if (_isLoading)
          const Center(
            child: CircularProgressIndicator(color: Color(0xFF6366F1)),
          )
        else
          _buildHistoryList(),
      ],
    );
  }

  Widget _buildCategoryFilter() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip('All', 'all'),
          const SizedBox(width: 8),
          _buildFilterChip('Payments', 'payments'),
          const SizedBox(width: 8),
          _buildFilterChip('Calls', 'calls'),
          const SizedBox(width: 8),
          _buildFilterChip('Messages', 'messages'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedCategory == value;
    return InkWell(
      onTap: () => setState(() => _selectedCategory = value),
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6366F1) : const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color:
                isSelected ? const Color(0xFF6366F1) : const Color(0xFF1E293B),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.white70,
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryList() {
    final items = _getFilteredItems();

    if (items.isEmpty) {
      return Card(
        color: const Color(0xFF020617),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: Color(0xFF1E293B)),
        ),
        child: const Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(Icons.receipt_long, size: 48, color: Colors.white30),
              SizedBox(height: 12),
              Text(
                'No billing history',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 4),
              Text(
                'Your invoices and charges will appear here',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.white60),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return _buildHistoryCard(items[index]);
      },
    );
  }

  List<Map<String, dynamic>> _getFilteredItems() {
    switch (_selectedCategory) {
      case 'payments':
        return _payments;
      case 'calls':
        return _calls;
      case 'messages':
        return _messages;
      default:
        final all = <Map<String, dynamic>>[];
        all.addAll(_payments.map((p) => {...p, '_type': 'payment'}));
        all.addAll(_calls.map((c) => {...c, '_type': 'call'}));
        all.addAll(_messages.map((m) => {...m, '_type': 'message'}));
        all.sort((a, b) {
          final aDate = DateTime.parse(a['created_at'] as String);
          final bDate = DateTime.parse(b['created_at'] as String);
          return bDate.compareTo(aDate);
        });
        return all;
    }
  }

  Widget _buildHistoryCard(Map<String, dynamic> item) {
    final type = item['_type'] as String? ?? _selectedCategory;
    final createdAt = DateTime.parse(item['created_at'] as String);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: const Color(0xFF020617),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFF1E293B)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _getTypeColor(type).withAlpha(26),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getTypeIcon(type),
                size: 20,
                color: _getTypeColor(type),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getItemTitle(item, type),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatDate(createdAt),
                    style: const TextStyle(fontSize: 11, color: Colors.white60),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _getItemAmount(item, type),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (type == 'payment')
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(
                        item['status'] as String,
                      ).withAlpha(51),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      (item['status'] as String).toUpperCase(),
                      style: TextStyle(
                        fontSize: 9,
                        color: _getStatusColor(item['status'] as String),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'payment':
        return Icons.payment;
      case 'call':
        return Icons.phone;
      case 'message':
        return Icons.sms;
      default:
        return Icons.receipt;
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'payment':
        return const Color(0xFF6366F1);
      case 'call':
        return const Color(0xFF22C55E);
      case 'message':
        return const Color(0xFF8B5CF6);
      default:
        return Colors.white;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return const Color(0xFF22C55E);
      case 'failed':
        return const Color(0xFFEF4444);
      case 'pending':
      case 'processing':
        return const Color(0xFFF59E0B);
      default:
        return Colors.white60;
    }
  }

  String _getItemTitle(Map<String, dynamic> item, String type) {
    switch (type) {
      case 'payment':
        return item['description'] as String? ?? 'Payment';
      case 'call':
        return 'Call to ${item['to_number']}';
      case 'message':
        return 'SMS to ${item['to_number']}';
      default:
        return 'Transaction';
    }
  }

  String _getItemAmount(Map<String, dynamic> item, String type) {
    switch (type) {
      case 'payment':
        final amount = (item['amount'] as num).toDouble();
        return '€${amount.toStringAsFixed(2)}';
      case 'call':
      case 'message':
        final price = (item['price'] as num?)?.toDouble() ?? 0.0;
        return '€${price.toStringAsFixed(2)}';
      default:
        return '€0.00';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today ${DateFormat('HH:mm').format(date)}';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return DateFormat('EEEE').format(date);
    } else {
      return DateFormat('MMM dd, yyyy').format(date);
    }
  }
}

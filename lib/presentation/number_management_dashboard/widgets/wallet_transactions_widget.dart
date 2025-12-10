import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../services/phone_number_service.dart';

class WalletTransactionsWidget extends StatefulWidget {
  const WalletTransactionsWidget({super.key});

  @override
  State<WalletTransactionsWidget> createState() =>
      _WalletTransactionsWidgetState();
}

class _WalletTransactionsWidgetState extends State<WalletTransactionsWidget> {
  final _phoneNumberService = PhoneNumberService();
  List<Map<String, dynamic>> _transactions = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() => _isLoading = true);
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId != null) {
        final transactions =
            await _phoneNumberService.getWalletTransactions(userId);
        setState(() => _transactions = transactions);
      }
    } catch (e) {
      debugPrint('Failed to load transactions: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Transactions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          color: const Color(0xFF0F172A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: Color(0xFF1E293B)),
          ),
          child: _isLoading
              ? const Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(child: CircularProgressIndicator()),
                )
              : _transactions.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(
                        child: Text(
                          'No transactions yet',
                          style: TextStyle(fontSize: 14, color: Colors.white54),
                        ),
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      itemCount:
                          _transactions.length > 5 ? 5 : _transactions.length,
                      separatorBuilder: (context, index) =>
                          const Divider(color: Color(0xFF1E293B)),
                      itemBuilder: (context, index) {
                        final transaction = _transactions[index];
                        final isCredit =
                            transaction['transaction_type'] == 'credit';
                        final amount =
                            (transaction['amount'] as num?)?.toDouble() ?? 0.0;

                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: (isCredit ? Colors.green : Colors.red)
                                  .withAlpha(26),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              isCredit
                                  ? Icons.arrow_downward
                                  : Icons.arrow_upward,
                              color: isCredit ? Colors.green : Colors.red,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            transaction['description'] ?? 'Transaction',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                          subtitle: Text(
                            _formatDate(transaction['created_at']),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white54,
                            ),
                          ),
                          trailing: Text(
                            '${isCredit ? '+' : '-'}€${amount.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isCredit ? Colors.green : Colors.red,
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  String _formatDate(dynamic dateStr) {
    try {
      final date = DateTime.parse(dateStr.toString());
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) return 'Today';
      if (difference.inDays == 1) return 'Yesterday';
      if (difference.inDays < 7) return '${difference.inDays} days ago';
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Unknown date';
    }
  }
}
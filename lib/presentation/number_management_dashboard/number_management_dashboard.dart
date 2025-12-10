import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import '../../routes/app_routes.dart';
import '../../services/phone_number_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import './widgets/number_card_widget.dart';
import './widgets/usage_stats_widget.dart';
import './widgets/wallet_transactions_widget.dart';

class NumberManagementDashboard extends StatefulWidget {
  const NumberManagementDashboard({super.key});

  @override
  State<NumberManagementDashboard> createState() =>
      _NumberManagementDashboardState();
}

class _NumberManagementDashboardState extends State<NumberManagementDashboard> {
  final _phoneNumberService = PhoneNumberService();
  List<Map<String, dynamic>> _myNumbers = [];
  bool _isLoading = false;
  String? _selectedNumberId;
  Map<String, dynamic>? _usageStats;

  @override
  void initState() {
    super.initState();
    _loadMyNumbers();
  }

  Future<void> _loadMyNumbers() async {
    setState(() => _isLoading = true);
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId != null) {
        final numbers =
            await _phoneNumberService.getAccountPhoneNumbers(userId);
        setState(() => _myNumbers = numbers);

        if (numbers.isNotEmpty && _selectedNumberId == null) {
          _selectNumber(numbers.first['id']);
        }
      }
    } catch (e) {
      _showErrorSnackBar('Failed to load numbers: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _selectNumber(String numberId) async {
    setState(() {
      _selectedNumberId = numberId;
      _isLoading = true;
    });

    try {
      final now = DateTime.now();
      final startDate = DateTime(now.year, now.month, 1);
      final stats = await _phoneNumberService.getNumberUsageStats(
        numberId,
        startDate,
        now,
      );
      setState(() => _usageStats = stats);
    } catch (e) {
      _showErrorSnackBar('Failed to load usage stats: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      appBar: AppBar(
        title: const Text('Number Management'),
        backgroundColor: const Color(0xFF020617),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _myNumbers.isEmpty
              ? _buildEmptyState()
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'My Phone Numbers',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _myNumbers.length,
                        itemBuilder: (context, index) {
                          final number = _myNumbers[index];
                          final isSelected = number['id'] == _selectedNumberId;
                          return NumberCardWidget(
                            number: number,
                            isSelected: isSelected,
                            onTap: () => _selectNumber(number['id']),
                          );
                        },
                      ),
                      if (_usageStats != null) ...[
                        const SizedBox(height: 20),
                        const Text(
                          'Usage Statistics',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        UsageStatsWidget(stats: _usageStats!),
                      ],
                      const SizedBox(height: 20),
                      const WalletTransactionsWidget(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.phone_disabled, size: 64, color: Colors.white38),
          const SizedBox(height: 16),
          const Text(
            'No phone numbers yet',
            style: TextStyle(fontSize: 18, color: Colors.white60),
          ),
          const SizedBox(height: 8),
          const Text(
            'Purchase a number to get started',
            style: TextStyle(fontSize: 14, color: Colors.white38),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(
                context, AppRoutes.phoneNumberPurchase),
            icon: const Icon(Icons.add),
            label: const Text('Purchase Number'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../services/phone_number_service.dart';
import './widgets/available_numbers_list_widget.dart';
import './widgets/number_search_filters_widget.dart';
import './widgets/wallet_balance_widget.dart';

class PhoneNumberPurchaseScreen extends StatefulWidget {
  const PhoneNumberPurchaseScreen({super.key});

  @override
  State<PhoneNumberPurchaseScreen> createState() =>
      _PhoneNumberPurchaseScreenState();
}

class _PhoneNumberPurchaseScreenState extends State<PhoneNumberPurchaseScreen> {
  final _phoneNumberService = PhoneNumberService();
  List<Map<String, dynamic>> _availableNumbers = [];
  bool _isLoading = false;
  String _selectedCountry = 'US';
  String _searchPattern = '';
  bool _smsFilter = false;
  bool _voiceFilter = false;
  double _walletBalance = 0.0;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    try {
      await _loadWalletBalance();
      await _searchNumbers();
    } catch (e) {
      _showErrorSnackBar('Failed to load data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadWalletBalance() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId != null) {
        final balance = await _phoneNumberService.getWalletBalance(userId);
        if (mounted) {
          setState(() => _walletBalance = balance);
        }
      }
    } catch (e) {
      // Silent fail - wallet will show €0.00 by default
      if (mounted) {
        setState(() => _walletBalance = 0.0);
      }
    }
  }

  Future<void> _searchNumbers() async {
    setState(() => _isLoading = true);
    try {
      final numbers = await _phoneNumberService.getAvailableNumbers(
        countryCode: _selectedCountry,
        searchPattern: _searchPattern.isEmpty ? null : _searchPattern,
        smsEnabled: _smsFilter ? true : null,
        voiceEnabled: _voiceFilter ? true : null,
      );
      setState(() => _availableNumbers = numbers);
    } catch (e) {
      _showErrorSnackBar('Search failed: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handlePurchase(String phoneNumberId, double price) async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      if (_walletBalance < price) {
        _showErrorSnackBar('Insufficient wallet balance. Please top up first.');
        return;
      }

      setState(() => _isLoading = true);

      await _phoneNumberService.purchaseNumber(
        accountId: userId,
        phoneNumberId: phoneNumberId,
        purchasePrice: price,
        monthlyCost: price * 0.5,
      );

      _showSuccessSnackBar('Phone number purchased successfully!');
      await _loadInitialData();
    } catch (e) {
      _showErrorSnackBar('Purchase failed: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      appBar: AppBar(
        title: const Text('Purchase Phone Number'),
        backgroundColor: const Color(0xFF020617),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  WalletBalanceWidget(
                    balance: _walletBalance,
                    onTopUp: () async {
                      await _loadWalletBalance();
                    },
                  ),
                  const SizedBox(height: 20),
                  NumberSearchFiltersWidget(
                    selectedCountry: _selectedCountry,
                    searchPattern: _searchPattern,
                    smsFilter: _smsFilter,
                    voiceFilter: _voiceFilter,
                    onCountryChanged: (value) {
                      setState(() => _selectedCountry = value);
                      _searchNumbers();
                    },
                    onSearchChanged: (value) {
                      setState(() => _searchPattern = value);
                    },
                    onSmsFilterChanged: (value) {
                      setState(() => _smsFilter = value);
                      _searchNumbers();
                    },
                    onVoiceFilterChanged: (value) {
                      setState(() => _voiceFilter = value);
                      _searchNumbers();
                    },
                    onSearch: _searchNumbers,
                  ),
                  const SizedBox(height: 20),
                  _availableNumbers.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.phone_disabled,
                                  size: 64,
                                  color: Colors.white.withAlpha(77),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No numbers available',
                                  style: TextStyle(
                                    color: Colors.white.withAlpha(179),
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Try adjusting filters or check back later',
                                  style: TextStyle(
                                    color: Colors.white.withAlpha(128),
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        )
                      : AvailableNumbersListWidget(
                          numbers: _availableNumbers,
                          onPurchase: _handlePurchase,
                        ),
                ],
              ),
            ),
    );
  }
}

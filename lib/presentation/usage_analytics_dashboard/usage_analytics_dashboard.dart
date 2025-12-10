import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../services/fhoneos_subscription_service.dart';
import './widgets/cost_breakdown_widget.dart';
import './widgets/usage_chart_widget.dart';
import './widgets/usage_history_list_widget.dart';

class UsageAnalyticsDashboard extends StatefulWidget {
  const UsageAnalyticsDashboard({super.key});

  @override
  State<UsageAnalyticsDashboard> createState() =>
      _UsageAnalyticsDashboardState();
}

class _UsageAnalyticsDashboardState extends State<UsageAnalyticsDashboard> {
  final _subscriptionService = FhoneOSSubscriptionService();

  List<Map<String, dynamic>> _usageHistory = [];
  Map<String, dynamic>? _statistics;
  bool _isLoading = true;
  String? _errorMessage;
  DateTime _selectedStartDate =
      DateTime.now().subtract(const Duration(days: 30));
  DateTime _selectedEndDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadUsageData();
  }

  Future<void> _loadUsageData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final accountId =
          'f35b9d52-c5f9-409f-bfab-bd4cc8f8fe10'; // Get from auth context

      // Remove this block - methods don't exist in service
      final usageStats = await _subscriptionService.getUsageStatistics();
      
      setState(() {
        _usageHistory = []; // Set empty list since getUsageHistory doesn't exist
        _statistics = {
          'minutes_used': usageStats.minutesUsed,
          'minutes_limit': usageStats.minutesLimit,
          'sms_used': usageStats.smsUsed,
          'sms_limit': usageStats.smsLimit,
        };
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: _selectedStartDate,
        end: _selectedEndDate,
      ),
    );

    if (picked != null) {
      setState(() {
        _selectedStartDate = picked.start;
        _selectedEndDate = picked.end;
      });
      _loadUsageData();
    }
  }

  Map<String, int> _calculateDailyUsage() {
    final Map<String, int> dailyMinutes = {};
    final Map<String, int> dailySms = {};

    for (final record in _usageHistory) {
      final date = DateTime.parse(record['created_at'] as String);
      final dateKey = DateFormat('dd MMM').format(date);
      final usageType = record['usage_type'] as String;

      if (usageType == 'call') {
        final duration = record['duration_seconds'] as int? ?? 0;
        final minutes = (duration / 60).ceil();
        dailyMinutes[dateKey] = (dailyMinutes[dateKey] ?? 0) + minutes;
      } else if (usageType == 'sms') {
        dailySms[dateKey] = (dailySms[dateKey] ?? 0) + 1;
      }
    }

    return {'minutes': dailyMinutes.length, 'sms': dailySms.length};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gebruiksanalyse'),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            tooltip: 'Selecteer periode',
            onPressed: _selectDateRange,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUsageData,
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
                        onPressed: _loadUsageData,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Opnieuw proberen'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadUsageData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Periode',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            TextButton.icon(
                              onPressed: _selectDateRange,
                              icon: const Icon(Icons.edit_calendar, size: 16),
                              label: Text(
                                '${DateFormat('dd MMM').format(_selectedStartDate)} - ${DateFormat('dd MMM').format(_selectedEndDate)}',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (_statistics != null)
                          CostBreakdownWidget(statistics: _statistics!),
                        const SizedBox(height: 24),
                        if (_usageHistory.isNotEmpty)
                          UsageChartWidget(usageHistory: _usageHistory),
                        const SizedBox(height: 24),
                        Text(
                          'Recente activiteit',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 12),
                        if (_usageHistory.isEmpty)
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(32),
                              child: Center(
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.history,
                                      size: 48,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Geen gebruiksgegevens',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        else
                          UsageHistoryListWidget(usageHistory: _usageHistory),
                      ],
                    ),
                  ),
                ),
    );
  }
}
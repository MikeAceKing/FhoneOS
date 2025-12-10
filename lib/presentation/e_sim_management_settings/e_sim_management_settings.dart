import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/data_usage_chart_widget.dart';
import './widgets/esim_plan_card_widget.dart';
import './widgets/network_selector_widget.dart';
import './widgets/qr_scanner_widget.dart';

/// eSIM Management Settings Screen
/// Comprehensive cellular plan management with eSIM provisioning
class ESimManagementSettings extends StatefulWidget {
  const ESimManagementSettings({super.key});

  @override
  State<ESimManagementSettings> createState() => _ESimManagementSettingsState();
}

class _ESimManagementSettingsState extends State<ESimManagementSettings>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _showQrScanner = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _toggleQrScanner() {
    setState(() {
      _showQrScanner = !_showQrScanner;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Mobile & eSIM',
          style: GoogleFonts.inter(
            fontSize: 20.h,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
        backgroundColor: theme.appBarTheme.backgroundColor,
        actions: [
          IconButton(
            icon: Icon(Icons.qr_code_scanner, size: 24.h),
            onPressed: _toggleQrScanner,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelStyle: GoogleFonts.inter(
            fontSize: 14.h,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: GoogleFonts.inter(
            fontSize: 14.h,
            fontWeight: FontWeight.w400,
          ),
          tabs: const [
            Tab(text: 'Plans'),
            Tab(text: 'Data Usage'),
            Tab(text: 'Network'),
          ],
        ),
      ),
      body: _showQrScanner
          ? QrScannerWidget(onClose: _toggleQrScanner)
          : TabBarView(
              controller: _tabController,
              children: [
                _buildPlansTab(isDark),
                _buildDataUsageTab(isDark),
                _buildNetworkTab(isDark),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _toggleQrScanner,
        backgroundColor: theme.colorScheme.primary,
        icon: Icon(Icons.add, size: 24.h),
        label: Text(
          'Add eSIM',
          style: GoogleFonts.inter(
            fontSize: 14.h,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildPlansTab(bool isDark) {
    // Mock eSIM plans data
    final List<Map<String, dynamic>> plans = [
      {
        'carrier': 'Verizon',
        'planName': 'Unlimited Plus',
        'status': 'active',
        'dataRemaining': '45 GB',
        'dataTotal': '50 GB',
        'billingCycle': 'Renews Dec 25, 2025',
        'features': ['Voice', 'Data', 'Roaming'],
      },
      {
        'carrier': 'T-Mobile',
        'planName': 'Global Traveler',
        'status': 'inactive',
        'dataRemaining': '10 GB',
        'dataTotal': '15 GB',
        'billingCycle': 'Expires Jan 15, 2026',
        'features': ['Data', 'Roaming'],
      },
    ];

    return ListView(
      padding: EdgeInsets.all(16.w),
      children: [
        Text(
          'Active Plans',
          style: GoogleFonts.inter(
            fontSize: 18.h,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 16.h),
        ...plans.map((plan) => EsimPlanCardWidget(plan: plan)),
        SizedBox(height: 24.h),
        _buildAddPlanButton(isDark),
      ],
    );
  }

  Widget _buildDataUsageTab(bool isDark) {
    return const SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DataUsageChartWidget(),
        ],
      ),
    );
  }

  Widget _buildNetworkTab(bool isDark) {
    return const NetworkSelectorWidget();
  }

  Widget _buildAddPlanButton(bool isDark) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(16.w),
        border: Border.all(
          color: isDark ? const Color(0xFF3A3A4A) : Colors.grey[300]!,
          width: 2,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.qr_code_2,
            size: 48.h,
            color: theme.colorScheme.primary,
          ),
          SizedBox(height: 16.h),
          Text(
            'Scan QR Code',
            style: GoogleFonts.inter(
              fontSize: 16.h,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Scan the QR code provided by your carrier to activate a new eSIM',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 13.h,
              color: theme.textTheme.bodySmall?.color,
            ),
          ),
          SizedBox(height: 16.h),
          TextButton(
            onPressed: _toggleQrScanner,
            child: Text(
              'Open Scanner',
              style: GoogleFonts.inter(
                fontSize: 14.h,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../models/fhoneos_plan.dart';
import '../../models/subscription_addon.dart';
import '../../routes/app_routes.dart';
import '../../services/subscription_service.dart';
import './widgets/addon_section_widget.dart';
import './widgets/billing_cycle_toggle_widget.dart';
import './widgets/payment_selection_widget.dart';
import './widgets/plan_card_widget.dart';

class PremiumPlanSelectionHub extends StatefulWidget {
  const PremiumPlanSelectionHub({super.key});

  @override
  State<PremiumPlanSelectionHub> createState() =>
      _PremiumPlanSelectionHubState();
}

class _PremiumPlanSelectionHubState extends State<PremiumPlanSelectionHub> {
  final SubscriptionService _subscriptionService = SubscriptionService();
  List<FhoneOSPlan> _plans = [];
  List<SubscriptionAddon> _aiAddons = [];
  List<SubscriptionAddon> _numberAddons = [];
  List<SubscriptionAddon> _bundleAddons = [];
  bool _isLoading = true;
  bool _isYearlyBilling = true;
  FhoneOSPlan? _selectedPlan;
  List<String> _selectedAddonIds = [];
  String _paymentType = 'yearly_full';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      // Remove the method calls that don't exist in SubscriptionService
      // final plans = await _subscriptionService.getAvailablePlans();
      // final addons = await _subscriptionService.getAvailableAddons();

      setState(() {
        // Use empty lists initially, fallback data will be used below
        _plans = [];
        final addons = <SubscriptionAddon>[];
        _aiAddons = addons.where((a) => a.code.contains('ai_')).toList();
        _numberAddons = addons.where((a) => a.code.contains('number')).toList();
        _bundleAddons = addons
            .where((a) => a.code.contains('min') || a.code.contains('sms'))
            .toList();

        if (_aiAddons.isEmpty) _aiAddons = SubscriptionAddon.getAIAddons();
        if (_numberAddons.isEmpty) {
          _numberAddons = SubscriptionAddon.getNumberAddons();
        }
        if (_bundleAddons.isEmpty) {
          _bundleAddons = SubscriptionAddon.getBundleAddons();
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fout bij laden: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _toggleAddon(String addonId) {
    setState(() {
      if (_selectedAddonIds.contains(addonId)) {
        _selectedAddonIds.remove(addonId);
      } else {
        _selectedAddonIds.add(addonId);
      }
    });
  }

  double _calculateTotal() {
    double total = 0.0;

    if (_selectedPlan != null) {
      total += _isYearlyBilling
          ? _selectedPlan!.priceYearly
          : _selectedPlan!.priceMonthly;
    }

    for (final addonId in _selectedAddonIds) {
      final addon = [..._aiAddons, ..._numberAddons, ..._bundleAddons]
          .firstWhere((a) => a.id == addonId);
      total += _isYearlyBilling ? addon.yearlyPrice : addon.price;
    }

    return total;
  }

  void _proceedToPayment() {
    if (_selectedPlan == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecteer eerst een plan')),
      );
      return;
    }

    Navigator.pushNamed(
      context,
      AppRoutes.fhoneOsDashboard,
      arguments: {
        'plan': _selectedPlan,
        'addons': _selectedAddonIds,
        'paymentType': _paymentType,
        'isYearly': _isYearlyBilling,
        'total': _calculateTotal(),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Kies je Plan',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xFF6366F1),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    color: Color(0xFF6366F1),
                    padding: EdgeInsets.all(4.w),
                    child: Column(
                      children: [
                        Text(
                          'FhoneOS Abonnementen',
                          style: GoogleFonts.inter(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          'Jaarcontract - Maandelijkse of jaarlijkse betaling',
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            color: Colors.white70,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 2.h),
                        BillingCycleToggleWidget(
                          isYearly: _isYearlyBilling,
                          onChanged: (value) {
                            setState(() => _isYearlyBilling = value);
                          },
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(4.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Kies je Plan',
                          style: GoogleFonts.inter(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        ..._plans.map((plan) => Padding(
                              padding: EdgeInsets.only(bottom: 2.h),
                              child: PlanCardWidget(
                                plan: plan,
                                isYearly: _isYearlyBilling,
                                isSelected: _selectedPlan?.id == plan.id,
                                onTap: () {
                                  setState(() => _selectedPlan = plan);
                                },
                              ),
                            )),
                        if (_selectedPlan != null) ...[
                          SizedBox(height: 3.h),
                          AddonSectionWidget(
                            title: 'AI Add-ons',
                            addons: _aiAddons,
                            selectedIds: _selectedAddonIds,
                            isYearly: _isYearlyBilling,
                            onToggle: _toggleAddon,
                          ),
                          SizedBox(height: 2.h),
                          AddonSectionWidget(
                            title: 'Extra Nummers',
                            addons: _numberAddons,
                            selectedIds: _selectedAddonIds,
                            isYearly: _isYearlyBilling,
                            onToggle: _toggleAddon,
                          ),
                          SizedBox(height: 2.h),
                          AddonSectionWidget(
                            title: 'Extra Bundels',
                            addons: _bundleAddons,
                            selectedIds: _selectedAddonIds,
                            isYearly: _isYearlyBilling,
                            onToggle: _toggleAddon,
                          ),
                          SizedBox(height: 3.h),
                          PaymentSelectionWidget(
                            isYearly: _isYearlyBilling,
                            selectedType: _paymentType,
                            onChanged: (value) {
                              setState(() => _paymentType = value);
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: _selectedPlan != null
          ? Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Totaal:',
                          style: GoogleFonts.inter(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '€${_calculateTotal().toStringAsFixed(2)}',
                          style: GoogleFonts.inter(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6366F1),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      _isYearlyBilling ? 'per jaar' : 'per maand',
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 2.h),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _proceedToPayment,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF6366F1),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 2.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Doorgaan naar Betaling',
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }
}
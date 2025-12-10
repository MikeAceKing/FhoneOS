import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../services/fhoneos_subscription_service.dart';
import '../../../models/fhoneos_subscription_plan.dart';
import '../4_step_signup_stepper_flow.dart';

class Step2PhonePlanWidget extends StatefulWidget {
  final SignupData signupData;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const Step2PhonePlanWidget({
    Key? key,
    required this.signupData,
    required this.onNext,
    required this.onBack,
  }) : super(key: key);

  @override
  State<Step2PhonePlanWidget> createState() => _Step2PhonePlanWidgetState();
}

class _Step2PhonePlanWidgetState extends State<Step2PhonePlanWidget> {
  final _subscriptionService = FhoneOSSubscriptionService();
  List<FhoneOSSubscriptionPlan> _plans = [];
  bool _isLoading = true;
  String? _selectedPlanId;
  String _selectedNumberType = 'Mobile';
  String _searchQuery = '';

  final List<String> _numberTypes = ['Mobile', 'Local', 'Toll-free'];

  @override
  void initState() {
    super.initState();
    _loadPlans();
    _selectedPlanId = widget.signupData.selectedPlanId;
  }

  Future<void> _loadPlans() async {
    try {
      final plans = await _subscriptionService.getAvailablePlans();
      setState(() {
        _plans = plans;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load plans: $e')));
      }
    }
  }

  void _handleNext() {
    if (_selectedPlanId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a subscription plan'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final selectedPlan = _plans.firstWhere((p) => p.id == _selectedPlanId);
    widget.signupData.selectedPlanId = _selectedPlanId;
    widget.signupData.planName = selectedPlan.name;
    widget.signupData.planPrice = selectedPlan.priceMonthly;
    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Choose your Fhone Number',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        _buildCountryPrefixSelector(),
        const SizedBox(height: 16),
        _buildNumberTypeSelector(),
        const SizedBox(height: 16),
        _buildNumberSearch(),
        const SizedBox(height: 32),
        Text(
          'Select Your Plan',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Powered by Twilio connectivity',
          style: GoogleFonts.inter(fontSize: 14, color: Colors.white70),
        ),
        const SizedBox(height: 16),
        _isLoading ? _buildLoadingState() : _buildPlansList(),
        const SizedBox(height: 32),
        _buildNavigationButtons(),
      ],
    );
  }

  Widget _buildCountryPrefixSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(13),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withAlpha(26)),
      ),
      child: Row(
        children: [
          const Icon(Icons.public, color: Colors.white70),
          const SizedBox(width: 12),
          Text(
            'Country / Prefix: +1 (US)',
            style: GoogleFonts.inter(fontSize: 16, color: Colors.white),
          ),
          const Spacer(),
          const Icon(Icons.arrow_drop_down, color: Colors.white70),
        ],
      ),
    );
  }

  Widget _buildNumberTypeSelector() {
    return Row(
      children:
          _numberTypes.map((type) {
            final isSelected = _selectedNumberType == type;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedNumberType = type),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? const Color(0xFF3B82F6)
                              : Colors.white.withAlpha(13),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            isSelected
                                ? const Color(0xFF3B82F6)
                                : Colors.white.withAlpha(26),
                      ),
                    ),
                    child: Text(
                      type,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }

  Widget _buildNumberSearch() {
    return TextField(
      onChanged: (value) => setState(() => _searchQuery = value),
      style: GoogleFonts.inter(color: Colors.white),
      decoration: InputDecoration(
        hintText: 'Search available numbers...',
        hintStyle: GoogleFonts.inter(color: Colors.white.withOpacity(0.5)),
        prefixIcon: const Icon(Icons.search, color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withAlpha(13),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withAlpha(51)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withAlpha(51)),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(color: Color(0xFF3B82F6)),
    );
  }

  Widget _buildPlansList() {
    return Column(
      children: _plans.map((plan) => _buildPlanCard(plan)).toList(),
    );
  }

  Widget _buildPlanCard(FhoneOSSubscriptionPlan plan) {
    final isSelected = _selectedPlanId == plan.id;
    return GestureDetector(
      onTap: () => setState(() => _selectedPlanId = plan.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? const Color(0xFF3B82F6).withAlpha(26)
                  : Colors.white.withAlpha(13),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                isSelected
                    ? const Color(0xFF3B82F6)
                    : Colors.white.withAlpha(26),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    plan.name,
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                if (isSelected)
                  const Icon(
                    Icons.check_circle,
                    color: Color(0xFF3B82F6),
                    size: 24,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              plan.description,
              style: GoogleFonts.inter(fontSize: 14, color: Colors.white70),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  '€${plan.priceMonthly.toStringAsFixed(0)}',
                  style: GoogleFonts.inter(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '/month',
                  style: GoogleFonts.inter(fontSize: 16, color: Colors.white70),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildFeatureChip('1 number'),
                _buildFeatureChip('${plan.minutesIncluded} min'),
                _buildFeatureChip('${plan.smsIncluded} SMS'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(26),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(fontSize: 12, color: Colors.white),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: widget.onBack,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: Colors.white30),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Back',
              style: GoogleFonts.inter(fontSize: 16, color: Colors.white),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _handleNext,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: const Color(0xFF3B82F6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Next: AI & Add-ons',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
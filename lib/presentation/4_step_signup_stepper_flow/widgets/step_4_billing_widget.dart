import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../4_step_signup_stepper_flow.dart';

class Step4BillingWidget extends StatefulWidget {
  final SignupData signupData;
  final VoidCallback onComplete;
  final VoidCallback onBack;

  const Step4BillingWidget({
    Key? key,
    required this.signupData,
    required this.onComplete,
    required this.onBack,
  }) : super(key: key);

  @override
  State<Step4BillingWidget> createState() => _Step4BillingWidgetState();
}

class _Step4BillingWidgetState extends State<Step4BillingWidget> {
  final _companyNameController = TextEditingController();
  final _billingAddressController = TextEditingController();
  final _vatNumberController = TextEditingController();

  String _selectedPaymentMethod = 'Card';
  final List<String> _paymentMethods = ['Card', 'SEPA', 'Other'];

  @override
  void initState() {
    super.initState();
    _companyNameController.text = widget.signupData.companyName ?? '';
    _billingAddressController.text = widget.signupData.billingAddress ?? '';
    _vatNumberController.text = widget.signupData.vatNumber ?? '';
    _selectedPaymentMethod = widget.signupData.paymentMethod ?? 'Card';
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    _billingAddressController.dispose();
    _vatNumberController.dispose();
    super.dispose();
  }

  void _handleComplete() {
    if (!widget.signupData.agreedToSubscription) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please acknowledge the subscription terms'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    widget.signupData.companyName = _companyNameController.text.trim();
    widget.signupData.billingAddress = _billingAddressController.text.trim();
    widget.signupData.vatNumber = _vatNumberController.text.trim();
    widget.signupData.paymentMethod = _selectedPaymentMethod;

    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildOrderSummary(),
        const SizedBox(height: 32),
        _buildBillingForm(),
        const SizedBox(height: 24),
        _buildPaymentMethodSelector(),
        const SizedBox(height: 24),
        _buildSubscriptionAgreement(),
        const SizedBox(height: 32),
        _buildNavigationButtons(),
      ],
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF3B82F6).withAlpha(26),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF3B82F6).withAlpha(77)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Summary',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          _buildSummaryRow(
            'Plan',
            widget.signupData.planName ?? 'Not selected',
          ),
          const SizedBox(height: 8),
          _buildSummaryRow('Phone Number', '+1 (555) 123-4567'),
          const SizedBox(height: 8),
          _buildSummaryRow(
            'AI Features',
            widget.signupData.selectedAddons.isEmpty
                ? 'None'
                : '${widget.signupData.selectedAddons.length} selected',
          ),
          const SizedBox(height: 8),
          _buildSummaryRow(
            'Add-ons',
            widget.signupData.selectedTwilioAddons.isEmpty
                ? 'None'
                : '${widget.signupData.selectedTwilioAddons.length} selected',
          ),
          const Divider(color: Colors.white30, height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Monthly',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                '€${widget.signupData.totalMonthly.toStringAsFixed(2)}',
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF3B82F6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 14, color: Colors.white70),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildBillingForm() {
    return Column(
      children: [
        _buildTextField(
          controller: _companyNameController,
          label: 'Company / Project Name (Optional)',
          icon: Icons.business,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _billingAddressController,
          label: 'Billing Address',
          icon: Icons.location_on,
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _vatNumberController,
          label: 'VAT / Tax ID (Optional)',
          icon: Icons.receipt,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: GoogleFonts.inter(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.inter(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
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
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
        ),
      ),
    );
  }

  Widget _buildPaymentMethodSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Method',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children:
              _paymentMethods.map((method) {
                final isSelected = _selectedPaymentMethod == method;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap:
                          () => setState(() => _selectedPaymentMethod = method),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
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
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _getPaymentIcon(method),
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              method,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight:
                                    isSelected
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  IconData _getPaymentIcon(String method) {
    switch (method) {
      case 'Card':
        return Icons.credit_card;
      case 'SEPA':
        return Icons.account_balance;
      default:
        return Icons.payment;
    }
  }

  Widget _buildSubscriptionAgreement() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(13),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withAlpha(26)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Checkbox(
                value: widget.signupData.agreedToSubscription,
                activeColor: const Color(0xFF3B82F6),
                onChanged: (value) {
                  setState(() {
                    widget.signupData.agreedToSubscription = value ?? false;
                  });
                },
              ),
              Expanded(
                child: Text(
                  'I understand this subscription will renew monthly.',
                  style: GoogleFonts.inter(fontSize: 14, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'You can change plan or add-ons anytime.',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.white70,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
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
            onPressed: _handleComplete,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: const Color(0xFF10B981),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Start FhoneOS',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

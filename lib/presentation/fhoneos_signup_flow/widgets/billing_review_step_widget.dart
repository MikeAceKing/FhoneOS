import 'package:flutter/material.dart';

import '../../../widgets/custom_icon_widget.dart';

/// Step 4: Billing information and order review
class BillingReviewStepWidget extends StatelessWidget {
  final TextEditingController companyNameController;
  final TextEditingController billingAddressController;
  final TextEditingController vatIdController;
  final String paymentMethod;
  final String selectedPhoneNumber;
  final String selectedPlan;
  final Map<String, bool> selectedAddons;
  final Function(String) onPaymentMethodChanged;

  const BillingReviewStepWidget({
    super.key,
    required this.companyNameController,
    required this.billingAddressController,
    required this.vatIdController,
    required this.paymentMethod,
    required this.selectedPhoneNumber,
    required this.selectedPlan,
    required this.selectedAddons,
    required this.onPaymentMethodChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Review & Activate',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            'Review your selections and complete setup',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 32.0),

          _buildSummaryCard(theme),

          const SizedBox(height: 24.0),

          Text(
            'Billing Details',
            style: theme.textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16.0),

          _buildTextField(
            controller: companyNameController,
            label: 'Company / Project Name (Optional)',
            icon: 'business',
          ),

          const SizedBox(height: 16.0),

          _buildTextField(
            controller: billingAddressController,
            label: 'Billing Address',
            icon: 'location_on',
          ),

          const SizedBox(height: 16.0),

          _buildTextField(
            controller: vatIdController,
            label: 'VAT / Tax ID (Optional)',
            icon: 'receipt',
          ),

          const SizedBox(height: 24.0),

          _buildPaymentMethodSelector(theme),

          const SizedBox(height: 24.0),

          _buildRenewalCheckbox(theme),

          const SizedBox(height: 16.0),

          Center(
            child: Text(
              'You can change plan or add-ons anytime.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.5),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(ThemeData theme) {
    final activeAddons = selectedAddons.entries.where((e) => e.value).length;

    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7B2FFF), Color(0xFF00D9FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00D9FF).withValues(alpha: 0.3),
            blurRadius: 20.0,
            spreadRadius: 2.0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your FhoneOS Package',
            style: theme.textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16.0),

          _buildSummaryRow('Phone Number', selectedPhoneNumber),
          const SizedBox(height: 8.0),
          _buildSummaryRow('Plan', selectedPlan.toUpperCase()),
          const SizedBox(height: 8.0),
          _buildSummaryRow('AI Features', '$activeAddons selected'),

          const SizedBox(height: 16.0),

          const Divider(color: Colors.white54),

          const SizedBox(height: 16.0),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Estimated Monthly',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                _calculateEstimatedTotal(),
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
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
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 14.0,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _calculateEstimatedTotal() {
    int basePrice = 0;
    switch (selectedPlan) {
      case 'starter':
        basePrice = 15;
        break;
      case 'growth':
        basePrice = 39;
        break;
      case 'scale':
        basePrice = 99;
        break;
    }

    final addonCount = selectedAddons.values.where((v) => v).length;
    final addonPrice = addonCount * 5;

    return '€${basePrice + addonPrice}';
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String icon,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
        prefixIcon: CustomIconWidget(
          iconName: icon,
          color: const Color(0xFF00D9FF),
          size: 20.0,
        ),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: Color(0xFF00D9FF), width: 2.0),
        ),
      ),
    );
  }

  Widget _buildPaymentMethodSelector(ThemeData theme) {
    return Row(
      children: [
        _buildPaymentChip('Card', 'credit_card'),
        const SizedBox(width: 12.0),
        _buildPaymentChip('SEPA', 'account_balance'),
        const SizedBox(width: 12.0),
        _buildPaymentChip('Other', 'payment'),
      ],
    );
  }

  Widget _buildPaymentChip(String method, String icon) {
    final isSelected = paymentMethod == method;

    return Expanded(
      child: GestureDetector(
        onTap: () => onPaymentMethodChanged(method),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14.0),
          decoration: BoxDecoration(
            color:
                isSelected
                    ? const Color(0xFF00D9FF).withValues(alpha: 0.2)
                    : Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(
              color:
                  isSelected
                      ? const Color(0xFF00D9FF)
                      : Colors.white.withValues(alpha: 0.2),
              width: isSelected ? 2.0 : 1.0,
            ),
          ),
          child: Column(
            children: [
              CustomIconWidget(
                iconName: icon,
                color: isSelected ? const Color(0xFF00D9FF) : Colors.white,
                size: 24.0,
              ),
              const SizedBox(height: 6.0),
              Text(
                method,
                style: TextStyle(
                  color: isSelected ? const Color(0xFF00D9FF) : Colors.white,
                  fontSize: 13.0,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRenewalCheckbox(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: 'info',
            color: const Color(0xFF00D9FF),
            size: 20.0,
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Text(
              'This subscription will renew monthly.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

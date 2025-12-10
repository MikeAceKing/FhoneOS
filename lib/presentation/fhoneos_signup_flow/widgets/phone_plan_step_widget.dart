import 'package:flutter/material.dart';

import '../../../widgets/custom_icon_widget.dart';

/// Step 2: Phone number selection and plan choice
class PhonePlanStepWidget extends StatelessWidget {
  final String countryPrefix;
  final String numberType;
  final String? selectedPhoneNumber;
  final String? selectedPlan;
  final Function(String) onPrefixChanged;
  final Function(String) onTypeChanged;
  final Function(String) onPhoneNumberSelected;
  final Function(String) onPlanSelected;

  const PhonePlanStepWidget({
    super.key,
    required this.countryPrefix,
    required this.numberType,
    required this.selectedPhoneNumber,
    required this.selectedPlan,
    required this.onPrefixChanged,
    required this.onTypeChanged,
    required this.onPhoneNumberSelected,
    required this.onPlanSelected,
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
            'Choose your Fhone Number',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            'Select a phone number and plan that fits your needs',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 32.0),

          _buildPrefixSelector(theme),

          const SizedBox(height: 20.0),

          _buildNumberTypeSelector(theme),

          const SizedBox(height: 20.0),

          _buildNumberList(theme),

          const SizedBox(height: 32.0),

          Text(
            'Plans',
            style: theme.textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16.0),

          _buildPlanCard(
            theme,
            'Starter',
            '€15/month',
            '1 number · basic voice & SMS',
            'starter',
          ),

          const SizedBox(height: 12.0),

          _buildPlanCard(
            theme,
            'Growth',
            '€39/month',
            'Multiple numbers · higher limits',
            'growth',
          ),

          const SizedBox(height: 12.0),

          _buildPlanCard(
            theme,
            'Scale',
            '€99/month',
            'Advanced routing & analytics',
            'scale',
          ),

          const SizedBox(height: 16.0),

          Center(
            child: Text(
              'Powered by Twilio connectivity.',
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

  Widget _buildPrefixSelector(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 4.0,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: countryPrefix,
                dropdownColor: const Color(0xFF1A1F3A),
                style: const TextStyle(color: Colors.white, fontSize: 16.0),
                icon: CustomIconWidget(
                  iconName: 'arrow_drop_down',
                  color: const Color(0xFF00D9FF),
                  size: 24.0,
                ),
                items:
                    ['+31', '+1', '+44', '+49']
                        .map(
                          (prefix) => DropdownMenuItem(
                            value: prefix,
                            child: Text(prefix),
                          ),
                        )
                        .toList(),
                onChanged: (value) {
                  if (value != null) onPrefixChanged(value);
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNumberTypeSelector(ThemeData theme) {
    return Row(
      children: [
        _buildTypeChip('Mobile', 'phone_iphone'),
        const SizedBox(width: 12.0),
        _buildTypeChip('Local', 'location_on'),
        const SizedBox(width: 12.0),
        _buildTypeChip('Toll-free', 'phone_forwarded'),
      ],
    );
  }

  Widget _buildTypeChip(String type, String icon) {
    final isSelected = numberType == type;

    return Expanded(
      child: GestureDetector(
        onTap: () => onTypeChanged(type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
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
              const SizedBox(height: 4.0),
              Text(
                type,
                style: TextStyle(
                  color: isSelected ? const Color(0xFF00D9FF) : Colors.white,
                  fontSize: 12.0,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumberList(ThemeData theme) {
    final mockNumbers = [
      '+31 20 123 4567',
      '+31 20 234 5678',
      '+31 20 345 6789',
    ];

    return Column(
      children:
          mockNumbers.map((number) => _buildNumberItem(theme, number)).toList(),
    );
  }

  Widget _buildNumberItem(ThemeData theme, String number) {
    final isSelected = selectedPhoneNumber == number;

    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color:
              isSelected
                  ? const Color(0xFF00D9FF)
                  : Colors.white.withValues(alpha: 0.2),
          width: isSelected ? 2.0 : 1.0,
        ),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: const Color(0xFF00D9FF).withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: CustomIconWidget(
            iconName: 'phone',
            color: const Color(0xFF00D9FF),
            size: 20.0,
          ),
        ),
        title: Text(
          number,
          style: theme.textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing:
            isSelected
                ? const Icon(Icons.check_circle, color: Color(0xFF00D9FF))
                : const Icon(Icons.circle_outlined, color: Colors.white54),
        onTap: () => onPhoneNumberSelected(number),
      ),
    );
  }

  Widget _buildPlanCard(
    ThemeData theme,
    String name,
    String price,
    String description,
    String planId,
  ) {
    final isSelected = selectedPlan == planId;

    return GestureDetector(
      onTap: () => onPlanSelected(planId),
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          gradient:
              isSelected
                  ? const LinearGradient(
                    colors: [Color(0xFF7B2FFF), Color(0xFF00D9FF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                  : null,
          color: isSelected ? null : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(
            color:
                isSelected
                    ? Colors.transparent
                    : Colors.white.withValues(alpha: 0.2),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              price,
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (isSelected)
              Padding(
                padding: const EdgeInsets.only(left: 12.0),
                child: const Icon(Icons.check_circle, color: Colors.white),
              ),
          ],
        ),
      ),
    );
  }
}

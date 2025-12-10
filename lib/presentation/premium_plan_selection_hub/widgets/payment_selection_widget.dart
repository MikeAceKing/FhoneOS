import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class PaymentSelectionWidget extends StatelessWidget {
  final bool isYearly;
  final String selectedType;
  final Function(String) onChanged;

  const PaymentSelectionWidget({
    super.key,
    required this.isYearly,
    required this.selectedType,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Betalingsmethode',
          style: GoogleFonts.inter(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 1.h),
        _buildPaymentOption(
          type: 'yearly_full',
          title: 'Betaal het hele jaar in één keer',
          subtitle: 'Eenmalige betaling voor 12 maanden',
          icon: Icons.payment,
        ),
        SizedBox(height: 1.h),
        _buildPaymentOption(
          type: 'monthly_term',
          title: 'Betaal per maand',
          subtitle: 'Maandelijkse termijnen, jaarcontract bindend',
          icon: Icons.calendar_today,
        ),
      ],
    );
  }

  Widget _buildPaymentOption({
    required String type,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final isSelected = selectedType == type;

    return GestureDetector(
      onTap: () => onChanged(type),
      child: Container(
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF6366F1).withAlpha(13) : Colors.white,
          border: Border.all(
            color: isSelected ? Color(0xFF6366F1) : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Radio<String>(
              value: type,
              groupValue: selectedType,
              onChanged: (value) => onChanged(value!),
              activeColor: Color(0xFF6366F1),
            ),
            Icon(icon, color: Color(0xFF6366F1)),
            SizedBox(width: 2.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 11.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

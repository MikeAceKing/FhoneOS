import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../../../models/fhoneos_plan.dart';

class PlanCardWidget extends StatelessWidget {
  final FhoneOSPlan plan;
  final bool isYearly;
  final bool isSelected;
  final VoidCallback onTap;

  const PlanCardWidget({
    super.key,
    required this.plan,
    required this.isYearly,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final price = isYearly ? plan.priceYearly : plan.priceMonthly;
    final displayPrice = isYearly ? plan.priceMonthly : plan.priceMonthly;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF6366F1).withAlpha(26) : Colors.white,
          border: Border.all(
            color: isSelected ? Color(0xFF6366F1) : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Color(0xFF6366F1).withAlpha(51),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  plan.name,
                  style: GoogleFonts.inter(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                if (isSelected)
                  Icon(Icons.check_circle, color: Color(0xFF6366F1)),
              ],
            ),
            SizedBox(height: 1.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '€${displayPrice.toStringAsFixed(0)}',
                  style: GoogleFonts.inter(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6366F1),
                  ),
                ),
                Text(
                  ' / maand',
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            if (isYearly)
              Padding(
                padding: EdgeInsets.only(top: 0.5.h),
                child: Text(
                  '€${price.toStringAsFixed(0)} per jaar',
                  style: GoogleFonts.inter(
                    fontSize: 11.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            SizedBox(height: 2.h),
            Text(
              plan.description,
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 2.h),
            Wrap(
              spacing: 2.w,
              runSpacing: 1.h,
              children: [
                _buildFeatureBadge(
                  '${plan.phoneNumbersIncluded} nummer${plan.phoneNumbersIncluded > 1 ? 's' : ''}',
                  Icons.phone,
                ),
                _buildFeatureBadge(
                  '${plan.minutesIncluded} min',
                  Icons.call,
                ),
                _buildFeatureBadge(
                  '${plan.smsIncluded} SMS',
                  Icons.message,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureBadge(String text, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Color(0xFF6366F1)),
          SizedBox(width: 1.w),
          Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 11.sp,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
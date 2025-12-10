import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../../../models/subscription_addon.dart';

class AddonSectionWidget extends StatelessWidget {
  final String title;
  final List<SubscriptionAddon> addons;
  final List<String> selectedIds;
  final bool isYearly;
  final Function(String) onToggle;

  const AddonSectionWidget({
    super.key,
    required this.title,
    required this.addons,
    required this.selectedIds,
    required this.isYearly,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 1.h),
        ...addons.map((addon) => Padding(
              padding: EdgeInsets.only(bottom: 1.h),
              child: _buildAddonCard(addon),
            )),
      ],
    );
  }

  Widget _buildAddonCard(SubscriptionAddon addon) {
    final isSelected = selectedIds.contains(addon.id);
    final price = isYearly ? addon.yearlyPrice : addon.price;
    final displayPrice = isYearly ? addon.price : addon.price;

    return GestureDetector(
      onTap: () => onToggle(addon.id),
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
            Checkbox(
              value: isSelected,
              onChanged: (_) => onToggle(addon.id),
              activeColor: Color(0xFF6366F1),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    addon.name,
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    addon.description,
                    style: GoogleFonts.inter(
                      fontSize: 11.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '+€${displayPrice.toStringAsFixed(0)}/mnd',
                  style: GoogleFonts.inter(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6366F1),
                  ),
                ),
                if (isYearly)
                  Text(
                    '€${price.toStringAsFixed(0)}/jr',
                    style: GoogleFonts.inter(
                      fontSize: 10.sp,
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

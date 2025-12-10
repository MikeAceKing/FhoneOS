import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// eSIM Plan Card Widget
/// Displays individual eSIM plan details with status and features
class EsimPlanCardWidget extends StatelessWidget {
  final Map<String, dynamic> plan;

  const EsimPlanCardWidget({
    super.key,
    required this.plan,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isActive = plan['status'] == 'active';

    // Calculate data usage percentage
    final dataRemaining = double.tryParse(
          plan['dataRemaining'].toString().replaceAll(RegExp(r'[^0-9.]'), ''),
        ) ??
        0;
    final dataTotal = double.tryParse(
          plan['dataTotal'].toString().replaceAll(RegExp(r'[^0-9.]'), ''),
        ) ??
        1;
    final usagePercentage =
        ((dataTotal - dataRemaining) / dataTotal).clamp(0.0, 1.0);

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive
              ? const Color(0xFF00D4AA)
              : (isDark ? const Color(0xFF3A3A4A) : Colors.grey[300]!),
          width: isActive ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Carrier and status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 40.w,
                    height: 40.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4A9EFF).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.sim_card,
                      color: const Color(0xFF4A9EFF),
                      size: 24.h,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plan['carrier'],
                        style: GoogleFonts.inter(
                          fontSize: 16.h,
                          fontWeight: FontWeight.w600,
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                      Text(
                        plan['planName'],
                        style: GoogleFonts.inter(
                          fontSize: 13.h,
                          color: theme.textTheme.bodySmall?.color,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: isActive
                      ? const Color(0xFF00D4AA).withValues(alpha: 0.15)
                      : Colors.grey.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isActive ? 'Active' : 'Inactive',
                  style: GoogleFonts.inter(
                    fontSize: 11.h,
                    fontWeight: FontWeight.w600,
                    color: isActive ? const Color(0xFF00D4AA) : Colors.grey,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // Data usage progress
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Data Remaining',
                    style: GoogleFonts.inter(
                      fontSize: 12.h,
                      color: theme.textTheme.bodySmall?.color,
                    ),
                  ),
                  Text(
                    '${plan['dataRemaining']} of ${plan['dataTotal']}',
                    style: GoogleFonts.inter(
                      fontSize: 12.h,
                      fontWeight: FontWeight.w600,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: 1 - usagePercentage,
                  minHeight: 8.h,
                  backgroundColor:
                      isDark ? const Color(0xFF2D2D3A) : Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    usagePercentage > 0.8
                        ? const Color(0xFFFF4757)
                        : usagePercentage > 0.5
                            ? const Color(0xFFF5A623)
                            : const Color(0xFF00D4AA),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // Features
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: (plan['features'] as List<String>).map((feature) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2D2D3A) : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getFeatureIcon(feature),
                      size: 14.h,
                      color: theme.textTheme.bodySmall?.color,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      feature,
                      style: GoogleFonts.inter(
                        fontSize: 11.h,
                        color: theme.textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),

          SizedBox(height: 12.h),

          // Billing cycle
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 14.h,
                color: theme.textTheme.bodySmall?.color,
              ),
              SizedBox(width: 6.w),
              Text(
                plan['billingCycle'],
                style: GoogleFonts.inter(
                  fontSize: 12.h,
                  color: theme.textTheme.bodySmall?.color,
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                  ),
                  child: Text(
                    'Manage',
                    style: GoogleFonts.inter(fontSize: 13.h),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: isActive ? null : () {},
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                  ),
                  child: Text(
                    isActive ? 'Active' : 'Activate',
                    style: GoogleFonts.inter(fontSize: 13.h),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getFeatureIcon(String feature) {
    switch (feature.toLowerCase()) {
      case 'voice':
        return Icons.phone;
      case 'data':
        return Icons.data_usage;
      case 'roaming':
        return Icons.public;
      default:
        return Icons.check_circle_outline;
    }
  }
}
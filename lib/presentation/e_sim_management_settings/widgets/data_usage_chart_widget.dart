import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// Data Usage Chart Widget
/// Displays monthly data consumption with breakdown
class DataUsageChartWidget extends StatelessWidget {
  const DataUsageChartWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'This Month',
          style: GoogleFonts.inter(
            fontSize: 18.h,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          '32.5 GB used of 50 GB',
          style: GoogleFonts.inter(
            fontSize: 14.h,
            color: theme.textTheme.bodySmall?.color,
          ),
        ),
        SizedBox(height: 24.h),

        // Bar chart
        Container(
          height: 250.h,
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: 60,
              barTouchData: BarTouchData(enabled: true),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      const days = [
                        'Mon',
                        'Tue',
                        'Wed',
                        'Thu',
                        'Fri',
                        'Sat',
                        'Sun'
                      ];
                      return Text(
                        days[value.toInt() % 7],
                        style: GoogleFonts.inter(
                          fontSize: 11.h,
                          color: theme.textTheme.bodySmall?.color,
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40.w,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        '${value.toInt()} GB',
                        style: GoogleFonts.inter(
                          fontSize: 10.h,
                          color: theme.textTheme.bodySmall?.color,
                        ),
                      );
                    },
                  ),
                ),
                topTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 10,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: isDark ? const Color(0xFF2D2D3A) : Colors.grey[200]!,
                    strokeWidth: 1,
                  );
                },
              ),
              borderData: FlBorderData(show: false),
              barGroups: [
                _buildBarGroup(0, 45),
                _buildBarGroup(1, 38),
                _buildBarGroup(2, 52),
                _buildBarGroup(3, 42),
                _buildBarGroup(4, 48),
                _buildBarGroup(5, 35),
                _buildBarGroup(6, 28),
              ],
            ),
          ),
        ),

        SizedBox(height: 24.h),

        // Category breakdown
        Text(
          'Usage by Category',
          style: GoogleFonts.inter(
            fontSize: 16.h,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 16.h),
        _buildCategoryItem('Streaming', 18.5, const Color(0xFF4A9EFF), isDark),
        _buildCategoryItem(
            'Social Media', 8.2, const Color(0xFF00D4AA), isDark),
        _buildCategoryItem('Browsing', 4.3, const Color(0xFFF5A623), isDark),
        _buildCategoryItem('Other', 1.5, const Color(0xFFFF4757), isDark),
      ],
    );
  }

  BarChartGroupData _buildBarGroup(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          gradient: const LinearGradient(
            colors: [Color(0xFF4A9EFF), Color(0xFF00D4AA)],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
          width: 20,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget _buildCategoryItem(
      String name, double usage, Color color, bool isDark) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF3A3A4A) : Colors.grey[200]!,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 12.w,
            height: 12.h,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              name,
              style: GoogleFonts.inter(
                fontSize: 14.h,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            '$usage GB',
            style: GoogleFonts.inter(
              fontSize: 14.h,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
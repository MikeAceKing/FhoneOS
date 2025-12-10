import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// Network Selector Widget
/// Allows manual carrier switching and roaming configuration
class NetworkSelectorWidget extends StatefulWidget {
  const NetworkSelectorWidget({super.key});

  @override
  State<NetworkSelectorWidget> createState() => _NetworkSelectorWidgetState();
}

class _NetworkSelectorWidgetState extends State<NetworkSelectorWidget> {
  String _selectedNetwork = 'Verizon';
  bool _dataRoaming = false;
  bool _voiceRoaming = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Mock available networks
    final List<Map<String, dynamic>> networks = [
      {'name': 'Verizon', 'signal': 5, 'type': '5G'},
      {'name': 'AT&T', 'signal': 4, 'type': '5G'},
      {'name': 'T-Mobile', 'signal': 5, 'type': '5G'},
      {'name': 'Sprint', 'signal': 3, 'type': 'LTE'},
    ];

    return ListView(
      padding: EdgeInsets.all(16.w),
      children: [
        // Network selection
        Text(
          'Available Networks',
          style: GoogleFonts.inter(
            fontSize: 18.h,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 16.h),
        ...networks.map((network) => _buildNetworkItem(network, isDark)),

        SizedBox(height: 32.h),

        // Roaming settings
        Text(
          'Roaming Settings',
          style: GoogleFonts.inter(
            fontSize: 18.h,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 16.h),
        _buildRoamingSetting(
          'Data Roaming',
          'Allow data usage while roaming',
          _dataRoaming,
          (value) => setState(() => _dataRoaming = value),
          isDark,
        ),
        _buildRoamingSetting(
          'Voice Roaming',
          'Allow voice calls while roaming',
          _voiceRoaming,
          (value) => setState(() => _voiceRoaming = value),
          isDark,
        ),

        SizedBox(height: 32.h),

        // Network mode
        Text(
          'Network Mode',
          style: GoogleFonts.inter(
            fontSize: 18.h,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 16.h),
        _buildNetworkModeOption('5G / LTE / 3G', '5g_auto', isDark),
        _buildNetworkModeOption('LTE / 3G', 'lte', isDark),
        _buildNetworkModeOption('3G Only', '3g', isDark),
      ],
    );
  }

  Widget _buildNetworkItem(Map<String, dynamic> network, bool isDark) {
    final isSelected = network['name'] == _selectedNetwork;
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected
              ? const Color(0xFF00D4AA)
              : (isDark ? const Color(0xFF3A3A4A) : Colors.grey[300]!),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: ListTile(
        onTap: () => setState(() => _selectedNetwork = network['name']),
        leading: Icon(
          Icons.signal_cellular_alt,
          color: isSelected
              ? const Color(0xFF00D4AA)
              : theme.textTheme.bodySmall?.color,
          size: 24.h,
        ),
        title: Row(
          children: [
            Text(
              network['name'],
              style: GoogleFonts.inter(
                fontSize: 15.h,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            SizedBox(width: 8.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: const Color(0xFF4A9EFF).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                network['type'],
                style: GoogleFonts.inter(
                  fontSize: 10.h,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF4A9EFF),
                ),
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...List.generate(
              5,
              (index) => Icon(
                Icons.signal_cellular_alt,
                size: 16.h,
                color: index < network['signal']
                    ? const Color(0xFF00D4AA)
                    : Colors.grey[400],
              ),
            ),
            if (isSelected) ...[
              SizedBox(width: 8.w),
              Icon(
                Icons.check_circle,
                color: const Color(0xFF00D4AA),
                size: 20.h,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRoamingSetting(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
    bool isDark,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF3A3A4A) : Colors.grey[200]!,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 15.h,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 12.h,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildNetworkModeOption(String title, String mode, bool isDark) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF3A3A4A) : Colors.grey[200]!,
        ),
      ),
      child: RadioListTile<String>(
        value: mode,
        groupValue: '5g_auto',
        onChanged: (value) {},
        title: Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 14.h,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
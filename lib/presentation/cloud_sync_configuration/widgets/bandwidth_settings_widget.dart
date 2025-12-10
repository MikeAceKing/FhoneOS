import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BandwidthSettingsWidget extends StatelessWidget {
  final bool wifiOnly;
  final int cellularLimitMb;
  final Function(bool) onWifiOnlyChanged;
  final Function(int) onCellularLimitChanged;

  const BandwidthSettingsWidget({
    Key? key,
    required this.wifiOnly,
    required this.cellularLimitMb,
    required this.onWifiOnlyChanged,
    required this.onCellularLimitChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.network_check, color: Colors.blue[700], size: 24),
              const SizedBox(width: 12),
              Text(
                'Network Preferences',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            value: wifiOnly,
            onChanged: onWifiOnlyChanged,
            title: Text(
              'WiFi Only Mode',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            subtitle: Text(
              'Sync only when connected to WiFi',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            activeColor: Colors.blue,
            contentPadding: EdgeInsets.zero,
          ),
          if (!wifiOnly) ...[
            const Divider(height: 24),
            Text(
              'Cellular Data Limit',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: cellularLimitMb.toDouble(),
                    min: 50,
                    max: 500,
                    divisions: 9,
                    label: '$cellularLimitMb MB',
                    onChanged: (value) => onCellularLimitChanged(value.toInt()),
                    activeColor: Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.orange[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$cellularLimitMb MB',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.orange[900],
                    ),
                  ),
                ),
              ],
            ),
          ],
          const Divider(height: 24),
          _buildInfoRow(
            icon: Icons.speed,
            label: 'Network Optimization',
            value: 'Enabled',
            valueColor: Colors.green,
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            icon: Icons.battery_charging_full,
            label: 'Battery Saver Mode',
            value: 'Auto',
            valueColor: Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: Colors.grey[700],
            ),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
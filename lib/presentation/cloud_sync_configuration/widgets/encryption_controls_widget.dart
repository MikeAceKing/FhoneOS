import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EncryptionControlsWidget extends StatefulWidget {
  final Function(String) onEncryptionLevelChanged;

  const EncryptionControlsWidget({
    Key? key,
    required this.onEncryptionLevelChanged,
  }) : super(key: key);

  @override
  State<EncryptionControlsWidget> createState() =>
      _EncryptionControlsWidgetState();
}

class _EncryptionControlsWidgetState extends State<EncryptionControlsWidget> {
  String _selectedLevel = 'standard';

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
              Icon(Icons.security, color: Colors.green[700], size: 24),
              const SizedBox(width: 12),
              Text(
                'Encryption & Security',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Encryption Level',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          _buildEncryptionOption(
            'basic',
            'Basic',
            'Standard AES-128 encryption',
            Icons.shield,
            Colors.blue,
          ),
          const SizedBox(height: 8),
          _buildEncryptionOption(
            'standard',
            'Standard',
            'AES-256 encryption with key rotation',
            Icons.shield_outlined,
            Colors.green,
          ),
          const SizedBox(height: 8),
          _buildEncryptionOption(
            'enterprise',
            'Enterprise',
            'Military-grade encryption with hardware security',
            Icons.verified_user,
            Colors.purple,
          ),
          const Divider(height: 24),
          _buildSecurityFeature(
            icon: Icons.lock,
            title: 'End-to-End Encryption',
            subtitle: 'Your data is encrypted on device',
            isEnabled: true,
          ),
          const SizedBox(height: 12),
          _buildSecurityFeature(
            icon: Icons.vpn_key,
            title: 'Key Management',
            subtitle: 'Automatic key rotation every 90 days',
            isEnabled: true,
          ),
        ],
      ),
    );
  }

  Widget _buildEncryptionOption(
    String value,
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    final isSelected = _selectedLevel == value;

    return GestureDetector(
      onTap: () {
        setState(() => _selectedLevel = value);
        widget.onEncryptionLevelChanged(value);
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? color.withAlpha(26) : Colors.grey[50],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? color : Colors.grey[200]!,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? color.withAlpha(51) : Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    description,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected) Icon(Icons.check_circle, color: color, size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityFeature({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isEnabled,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: Colors.green[700]),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        Icon(
          isEnabled ? Icons.check_circle : Icons.cancel,
          color: isEnabled ? Colors.green : Colors.grey,
          size: 20,
        ),
      ],
    );
  }
}
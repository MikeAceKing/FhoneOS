import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// FhoneOS Branding Widget for Authentication Gateway
/// Displays FhoneOS logo and tagline with modern styling
class FhoneOSBrandingWidget extends StatelessWidget {
  const FhoneOSBrandingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // FhoneOS Logo Icon with gradient background
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF3B82F6),
                const Color(0xFF8B5CF6),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3B82F6).withAlpha(77),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            Icons.phone_android_rounded,
            size: 48,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 24),
        // FhoneOS Brand Name
        Text(
          'FhoneOS',
          style: GoogleFonts.inter(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        // Tagline
        Text(
          'Cloud Phone System',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: Colors.white60,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

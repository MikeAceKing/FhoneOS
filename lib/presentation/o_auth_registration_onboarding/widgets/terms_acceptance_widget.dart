import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class TermsAcceptanceWidget extends StatelessWidget {
  final bool isAccepted;
  final ValueChanged<bool> onChanged;

  const TermsAcceptanceWidget({
    super.key,
    required this.isAccepted,
    required this.onChanged,
  });

  void _showTermsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Algemene Voorwaarden'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'FhoneOS Abonnementsvoorwaarden',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  fontSize: 14.sp,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                '• Het abonnement is jaarlijks bindend\n'
                '• Betaling kan per maand, maar u bent 12 maanden verplicht\n'
                '• Annulering vóór einde contract niet toegestaan (behalve binnen 14 dagen)\n'
                '• Noodoproepen (112) niet ondersteund\n'
                '• AI-functionaliteit afhankelijk van gekozen plan\n'
                '• Twilio-nummers worden automatisch toegekend',
                style: GoogleFonts.inter(fontSize: 12.sp),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Sluiten'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Privacybeleid'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'FhoneOS Privacy & GDPR Compliance',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  fontSize: 14.sp,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                '• Uw gegevens worden veilig opgeslagen\n'
                '• GDPR-compliant gegevensverwerking\n'
                '• Recht op inzage en verwijdering\n'
                '• Geen gegevens delen met derden zonder toestemming\n'
                '• Versleutelde opslag van persoonlijke informatie',
                style: GoogleFonts.inter(fontSize: 12.sp),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Sluiten'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Checkbox(
              value: isAccepted,
              onChanged: (value) => onChanged(value ?? false),
              activeColor: Color(0xFF6366F1),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(!isAccepted),
                child: RichText(
                  text: TextSpan(
                    style: GoogleFonts.inter(
                      fontSize: 11.sp,
                      color: Colors.grey[700],
                    ),
                    children: [
                      TextSpan(text: 'Ik accepteer de '),
                      WidgetSpan(
                        child: GestureDetector(
                          onTap: () => _showTermsDialog(context),
                          child: Text(
                            'Algemene Voorwaarden',
                            style: GoogleFonts.inter(
                              fontSize: 11.sp,
                              color: Color(0xFF6366F1),
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                      TextSpan(text: ' en '),
                      WidgetSpan(
                        child: GestureDetector(
                          onTap: () => _showPrivacyDialog(context),
                          child: Text(
                            'Privacybeleid',
                            style: GoogleFonts.inter(
                              fontSize: 11.sp,
                              color: Color(0xFF6366F1),
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        if (!isAccepted)
          Padding(
            padding: EdgeInsets.only(left: 4.w, top: 1.h),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: Colors.orange),
                SizedBox(width: 1.w),
                Expanded(
                  child: Text(
                    'Acceptatie vereist om door te gaan',
                    style: GoogleFonts.inter(
                      fontSize: 10.sp,
                      color: Colors.orange,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

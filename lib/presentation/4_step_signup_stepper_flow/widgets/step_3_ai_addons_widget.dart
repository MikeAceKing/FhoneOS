import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../4_step_signup_stepper_flow.dart';

class Step3AIAddonsWidget extends StatefulWidget {
  final SignupData signupData;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const Step3AIAddonsWidget({
    Key? key,
    required this.signupData,
    required this.onNext,
    required this.onBack,
  }) : super(key: key);

  @override
  State<Step3AIAddonsWidget> createState() => _Step3AIAddonsWidgetState();
}

class _Step3AIAddonsWidgetState extends State<Step3AIAddonsWidget> {
  final Map<String, bool> _aiFeatures = {
    'ai_call_assistant': false,
    'ai_sms_copilot': false,
    'voicemail_to_text': false,
    'call_recording': false,
  };

  final Map<String, bool> _twilioAddons = {
    'whatsapp_business': false,
    'verify_otp': false,
  };

  @override
  void initState() {
    super.initState();
    for (var addon in widget.signupData.selectedAddons) {
      if (_aiFeatures.containsKey(addon)) {
        _aiFeatures[addon] = true;
      }
    }
    for (var addon in widget.signupData.selectedTwilioAddons) {
      if (_twilioAddons.containsKey(addon)) {
        _twilioAddons[addon] = true;
      }
    }
  }

  void _handleNext() {
    widget.signupData.selectedAddons =
        _aiFeatures.entries
            .where((entry) => entry.value)
            .map((entry) => entry.key)
            .toList();

    widget.signupData.selectedTwilioAddons =
        _twilioAddons.entries
            .where((entry) => entry.value)
            .map((entry) => entry.key)
            .toList();

    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Supercharge your FhoneOS',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 24),
        _buildAIFeaturesSection(),
        const SizedBox(height: 32),
        _buildTwilioAddonsSection(),
        const SizedBox(height: 32),
        _buildComingSoonSection(),
        const SizedBox(height: 32),
        _buildNavigationButtons(),
      ],
    );
  }

  Widget _buildAIFeaturesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AI Features',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        _buildFeatureToggle(
          'ai_call_assistant',
          'AI Call Assistant',
          'Realtime call transcription & smart replies',
          Icons.support_agent,
        ),
        const SizedBox(height: 12),
        _buildFeatureToggle(
          'ai_sms_copilot',
          'AI SMS Copilot',
          'Suggested responses & workflows',
          Icons.chat_bubble_outline,
        ),
        const SizedBox(height: 12),
        _buildFeatureToggle(
          'voicemail_to_text',
          'Voicemail to Text',
          'Automatic voicemail transcription',
          Icons.voicemail,
        ),
        const SizedBox(height: 12),
        _buildFeatureToggle(
          'call_recording',
          'Call Recording & Analytics',
          'Record calls and analyze conversations',
          Icons.fiber_manual_record,
        ),
      ],
    );
  }

  Widget _buildTwilioAddonsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Twilio Add-ons',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6).withAlpha(51),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Powered by Twilio',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: const Color(0xFF3B82F6),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildTwilioToggle(
          'whatsapp_business',
          'WhatsApp Business',
          '2-way messaging via WhatsApp',
          Icons.chat,
        ),
        const SizedBox(height: 12),
        _buildTwilioToggle(
          'verify_otp',
          'Verify (OTP)',
          'Send one-time passwords via SMS/WhatsApp',
          Icons.verified_user,
        ),
      ],
    );
  }

  Widget _buildComingSoonSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Coming Soon',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildComingSoonChip('Video Rooms', Icons.video_call),
            _buildComingSoonChip('Chat Widgets', Icons.chat_bubble),
          ],
        ),
      ],
    );
  }

  Widget _buildFeatureToggle(
    String key,
    String title,
    String description,
    IconData icon,
  ) {
    final isEnabled = _aiFeatures[key] ?? false;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(13),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              isEnabled ? const Color(0xFF3B82F6) : Colors.white.withAlpha(26),
          width: isEnabled ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6).withAlpha(26),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF3B82F6)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.inter(fontSize: 14, color: Colors.white70),
                ),
              ],
            ),
          ),
          Switch(
            value: isEnabled,
            activeColor: const Color(0xFF3B82F6),
            onChanged: (value) {
              setState(() => _aiFeatures[key] = value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTwilioToggle(
    String key,
    String title,
    String description,
    IconData icon,
  ) {
    final isEnabled = _twilioAddons[key] ?? false;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(13),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              isEnabled ? const Color(0xFF10B981) : Colors.white.withAlpha(26),
          width: isEnabled ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withAlpha(26),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF10B981)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.inter(fontSize: 14, color: Colors.white70),
                ),
              ],
            ),
          ),
          Switch(
            value: isEnabled,
            activeColor: const Color(0xFF10B981),
            onChanged: (value) {
              setState(() => _twilioAddons[key] = value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildComingSoonChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(13),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withAlpha(26)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white30, size: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 14, color: Colors.white30),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(26),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Soon',
              style: GoogleFonts.inter(fontSize: 10, color: Colors.white.withOpacity(0.5)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: widget.onBack,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: Colors.white30),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Back',
              style: GoogleFonts.inter(fontSize: 16, color: Colors.white),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _handleNext,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: const Color(0xFF3B82F6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Next: Billing',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
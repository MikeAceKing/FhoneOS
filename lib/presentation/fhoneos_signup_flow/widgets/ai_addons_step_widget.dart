import 'package:flutter/material.dart';

import '../../../widgets/custom_icon_widget.dart';

/// Step 3: AI features and add-ons selection
class AiAddonsStepWidget extends StatelessWidget {
  final Map<String, bool> selectedAddons;
  final Function(String, bool) onAddonToggle;

  const AiAddonsStepWidget({
    super.key,
    required this.selectedAddons,
    required this.onAddonToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Supercharge your FhoneOS',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            'Add AI-powered features and integrations',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 32.0),

          Text(
            'AI Features',
            style: theme.textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16.0),

          _buildAddonToggle(
            theme,
            'ai_call_assistant',
            'AI Call Assistant',
            'Realtime call transcription & smart replies',
            'psychology',
          ),

          const SizedBox(height: 12.0),

          _buildAddonToggle(
            theme,
            'ai_sms_copilot',
            'AI SMS Copilot',
            'Suggested responses & workflows',
            'chat',
          ),

          const SizedBox(height: 12.0),

          _buildAddonToggle(
            theme,
            'voicemail_to_text',
            'Voicemail to Text',
            'Automatic transcription of voicemails',
            'voicemail',
          ),

          const SizedBox(height: 12.0),

          _buildAddonToggle(
            theme,
            'call_recording',
            'Call Recording & Analytics',
            'Record calls and gain insights',
            'mic',
          ),

          const SizedBox(height: 32.0),

          Text(
            'Twilio Add-ons',
            style: theme.textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16.0),

          _buildAddonToggle(
            theme,
            'whatsapp_business',
            'WhatsApp Business',
            '2-way messaging via WhatsApp',
            'message',
          ),

          const SizedBox(height: 12.0),

          _buildAddonToggle(
            theme,
            'verify_otp',
            'Verify (OTP)',
            'Send one-time passwords via SMS/WhatsApp',
            'verified_user',
          ),

          const SizedBox(height: 32.0),

          _buildComingSoonChips(theme),
        ],
      ),
    );
  }

  Widget _buildAddonToggle(
    ThemeData theme,
    String key,
    String title,
    String description,
    String icon,
  ) {
    final isSelected = selectedAddons[key] ?? false;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color:
            isSelected
                ? const Color(0xFF00D9FF).withValues(alpha: 0.1)
                : Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color:
              isSelected
                  ? const Color(0xFF00D9FF)
                  : Colors.white.withValues(alpha: 0.2),
          width: isSelected ? 2.0 : 1.0,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: const Color(0xFF00D9FF).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: CustomIconWidget(
              iconName: icon,
              color: const Color(0xFF00D9FF),
              size: 24.0,
            ),
          ),
          const SizedBox(width: 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: isSelected,
            onChanged: (value) => onAddonToggle(key, value),
            activeColor: const Color(0xFF00D9FF),
            activeTrackColor: const Color(0xFF00D9FF).withValues(alpha: 0.5),
            inactiveThumbColor: Colors.white54,
            inactiveTrackColor: Colors.white.withValues(alpha: 0.2),
          ),
        ],
      ),
    );
  }

  Widget _buildComingSoonChips(ThemeData theme) {
    return Wrap(
      spacing: 12.0,
      runSpacing: 12.0,
      children: [
        _buildComingSoonChip(theme, 'Video Rooms'),
        _buildComingSoonChip(theme, 'Chat Widgets'),
      ],
    );
  }

  Widget _buildComingSoonChip(ThemeData theme, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(width: 8.0),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
            decoration: BoxDecoration(
              color: const Color(0xFF7B2FFF).withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Text(
              'Coming soon',
              style: theme.textTheme.bodySmall?.copyWith(
                color: const Color(0xFF7B2FFF),
                fontSize: 10.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

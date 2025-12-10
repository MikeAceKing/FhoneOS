import 'package:flutter/material.dart';

class PlatformFilterWidget extends StatelessWidget {
  final String? selectedPlatform;
  final Function(String?) onPlatformSelected;

  const PlatformFilterWidget({
    super.key,
    required this.selectedPlatform,
    required this.onPlatformSelected,
  });

  @override
  Widget build(BuildContext context) {
    final platforms = [
      {
        'name': 'All',
        'value': null,
        'icon': Icons.all_inbox,
        'color': const Color(0xFF4D9FFF)
      },
      {
        'name': 'SMS',
        'value': 'sms',
        'icon': Icons.sms,
        'color': const Color(0xFF01C38D)
      },
      {
        'name': 'WhatsApp',
        'value': 'whatsapp',
        'icon': Icons.chat_bubble,
        'color': const Color(0xFF25D366)
      },
      {
        'name': 'Telegram',
        'value': 'telegram',
        'icon': Icons.telegram,
        'color': const Color(0xFF0088CC)
      },
      {
        'name': 'Email',
        'value': 'email',
        'icon': Icons.email,
        'color': const Color(0xFFEA4335)
      },
    ];

    return Container(
      height: 60,
      color: Colors.white,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: platforms.length,
        itemBuilder: (context, index) {
          final platform = platforms[index];
          final isSelected = selectedPlatform == platform['value'];

          return GestureDetector(
            onTap: () => onPlatformSelected(platform['value'] as String?),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? (platform['color'] as Color).withAlpha(26)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? platform['color'] as Color
                      : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    platform['icon'] as IconData,
                    size: 20,
                    color: isSelected
                        ? platform['color'] as Color
                        : Colors.grey.shade600,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    platform['name'] as String,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected
                          ? platform['color'] as Color
                          : Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

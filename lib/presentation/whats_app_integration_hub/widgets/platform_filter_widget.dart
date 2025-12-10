import 'package:flutter/material.dart';

class PlatformFilterWidget extends StatelessWidget {
  final String selectedPlatform;
  final Function(String) onPlatformChanged;

  const PlatformFilterWidget({
    Key? key,
    required this.selectedPlatform,
    required this.onPlatformChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(26),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildFilterChip(
            context,
            label: 'All',
            value: 'all',
            icon: Icons.all_inbox,
            color: Colors.grey,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            context,
            label: 'WhatsApp',
            value: 'whatsapp',
            icon: Icons.help_outline,
            color: const Color(0xFF25D366),
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            context,
            label: 'SMS',
            value: 'sms',
            icon: Icons.sms,
            color: Colors.blue,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            context,
            label: 'Telegram',
            value: 'telegram',
            icon: Icons.telegram,
            color: const Color(0xFF0088CC),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = selectedPlatform == value;
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isSelected ? Colors.white : color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
      selected: isSelected,
      onSelected: (_) => onPlatformChanged(value),
      backgroundColor: Colors.grey[100],
      selectedColor: color,
      checkmarkColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }
}

import 'package:flutter/material.dart';

class PrivacyDashboardWidget extends StatelessWidget {
  const PrivacyDashboardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Privacy Level',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildPrivacyPreset(
                        context,
                        'Maximum Privacy',
                        Colors.red,
                        false,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildPrivacyPreset(
                        context,
                        'Balanced',
                        Colors.orange,
                        true,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildPrivacyPreset(
                        context,
                        'Full Access',
                        Colors.green,
                        false,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Data Collection Summary',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildDataItem('Location Data', 'Collected', true),
                _buildDataItem('Contact Data', 'Collected', true),
                _buildDataItem('Usage Analytics', 'Opt-out available', false),
                _buildDataItem('Crash Reports', 'Opt-out available', false),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: ListTile(
            leading: const Icon(Icons.download, color: Colors.blue),
            title: const Text('Export Privacy Report'),
            subtitle: const Text('Generate compliance report'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: ListTile(
            leading: const Icon(Icons.restore, color: Colors.orange),
            title: const Text('Reset Permissions'),
            subtitle: const Text('Restore default states'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),
        ),
      ],
    );
  }

  Widget _buildPrivacyPreset(
    BuildContext context,
    String title,
    Color color,
    bool isSelected,
  ) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withAlpha(26) : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected ? color : Colors.grey,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? color : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataItem(String title, String subtitle, bool isOptOut) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            isOptOut ? Icons.check_circle : Icons.info,
            color: isOptOut ? Colors.green : Colors.blue,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          if (!isOptOut)
            TextButton(
              onPressed: () {},
              child: const Text('Opt-out', style: TextStyle(fontSize: 12)),
            ),
        ],
      ),
    );
  }
}

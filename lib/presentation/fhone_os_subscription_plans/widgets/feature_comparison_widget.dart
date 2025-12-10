import 'package:flutter/material.dart';

/// Feature comparison matrix for all plans
class FeatureComparisonWidget extends StatelessWidget {
  final List<Map<String, dynamic>> plans;

  const FeatureComparisonWidget({super.key, required this.plans});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Compare Plans',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16.0),

        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(
                theme.colorScheme.primaryContainer,
              ),
              columns: [
                const DataColumn(label: Text('Feature')),
                ...plans.map(
                  (plan) => DataColumn(
                    label: Text(
                      plan['name'] ?? '',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
              rows: [
                DataRow(
                  cells: [
                    const DataCell(Text('Phone Numbers')),
                    ...plans.map(
                      (p) => DataCell(Text('${p['numbers_included'] ?? 0}')),
                    ),
                  ],
                ),
                DataRow(
                  cells: [
                    const DataCell(Text('Minutes')),
                    ...plans.map(
                      (p) => DataCell(Text('${p['minutes_included'] ?? 0}')),
                    ),
                  ],
                ),
                DataRow(
                  cells: [
                    const DataCell(Text('SMS')),
                    ...plans.map(
                      (p) => DataCell(Text('${p['sms_included'] ?? 0}')),
                    ),
                  ],
                ),
                DataRow(
                  cells: [
                    const DataCell(Text('AI Level')),
                    ...plans.map((p) {
                      final aiLevel = p['ai_level'] ?? 'none';
                      return DataCell(Text(_formatAiLevel(aiLevel)));
                    }),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatAiLevel(String level) {
    switch (level) {
      case 'none':
        return 'None';
      case 'ai_lite':
        return 'Lite';
      case 'ai_full':
        return 'Full';
      case 'ai_premium':
        return 'Premium';
      default:
        return level;
    }
  }
}

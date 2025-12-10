import 'package:flutter/material.dart';

/// Section displaying available add-ons with selection capability
class AddOnsSectionWidget extends StatelessWidget {
  final List<Map<String, dynamic>> addons;
  final List<String> selectedIds;
  final Function(String) onToggle;

  const AddOnsSectionWidget({
    super.key,
    required this.addons,
    required this.selectedIds,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Group addons by type
    final aiAddons =
        addons
            .where((a) => a['code']?.toString().contains('ai_') == true)
            .toList();
    final numberAddons =
        addons
            .where((a) => a['code']?.toString().contains('number') == true)
            .toList();
    final bundleAddons =
        addons
            .where((a) => a['code']?.toString().contains('bundle') == true)
            .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Add-ons',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16.0),

        // AI Add-ons
        if (aiAddons.isNotEmpty) ...[
          _buildCategoryHeader('AI Enhancements', theme),
          ...aiAddons.map((addon) => _buildAddonTile(addon, theme)),
          const SizedBox(height: 16.0),
        ],

        // Phone Number Add-ons
        if (numberAddons.isNotEmpty) ...[
          _buildCategoryHeader('Extra Phone Numbers', theme),
          ...numberAddons.map((addon) => _buildAddonTile(addon, theme)),
          const SizedBox(height: 16.0),
        ],

        // Usage Bundle Add-ons
        if (bundleAddons.isNotEmpty) ...[
          _buildCategoryHeader('Usage Bundles', theme),
          ...bundleAddons.map((addon) => _buildAddonTile(addon, theme)),
        ],
      ],
    );
  }

  Widget _buildCategoryHeader(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildAddonTile(Map<String, dynamic> addon, ThemeData theme) {
    final isSelected = selectedIds.contains(addon['id']);
    final price = (addon['price'] ?? 0.0).toDouble();

    return CheckboxListTile(
      value: isSelected,
      onChanged: (_) => onToggle(addon['id']),
      title: Text(addon['name'] ?? ''),
      subtitle: Text(addon['description'] ?? ''),
      secondary: Text(
        '€${price.toStringAsFixed(0)}',
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.primary,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      tileColor:
          isSelected
              ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
              : null,
    );
  }
}

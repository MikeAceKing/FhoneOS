import 'package:flutter/material.dart';

class NumberSearchFiltersWidget extends StatelessWidget {
  final String selectedCountry;
  final String searchPattern;
  final bool smsFilter;
  final bool voiceFilter;
  final ValueChanged<String> onCountryChanged;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<bool> onSmsFilterChanged;
  final ValueChanged<bool> onVoiceFilterChanged;
  final VoidCallback onSearch;

  const NumberSearchFiltersWidget({
    super.key,
    required this.selectedCountry,
    required this.searchPattern,
    required this.smsFilter,
    required this.voiceFilter,
    required this.onCountryChanged,
    required this.onSearchChanged,
    required this.onSmsFilterChanged,
    required this.onVoiceFilterChanged,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF0F172A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Color(0xFF1E293B)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Search Filters',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedCountry,
              dropdownColor: const Color(0xFF0F172A),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Country',
                labelStyle: const TextStyle(color: Colors.white60),
                filled: true,
                fillColor: const Color(0xFF020617),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF1E293B)),
                ),
              ),
              items: const [
                DropdownMenuItem(value: 'US', child: Text('United States')),
                DropdownMenuItem(value: 'BE', child: Text('Belgium')),
                DropdownMenuItem(value: 'NL', child: Text('Netherlands')),
                DropdownMenuItem(value: 'GB', child: Text('United Kingdom')),
              ],
              onChanged: (value) => onCountryChanged(value!),
            ),
            const SizedBox(height: 12),
            TextField(
              onChanged: onSearchChanged,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Search Pattern (e.g., 555)',
                labelStyle: const TextStyle(color: Colors.white60),
                filled: true,
                fillColor: const Color(0xFF020617),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF1E293B)),
                ),
                suffixIcon:
                    const Icon(Icons.search, color: Colors.white60, size: 20),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: CheckboxListTile(
                    title: const Text('SMS', style: TextStyle(fontSize: 13)),
                    value: smsFilter,
                    onChanged: (value) => onSmsFilterChanged(value ?? false),
                    activeColor: const Color(0xFF6366F1),
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  ),
                ),
                Expanded(
                  child: CheckboxListTile(
                    title: const Text('Voice', style: TextStyle(fontSize: 13)),
                    value: voiceFilter,
                    onChanged: (value) => onVoiceFilterChanged(value ?? false),
                    activeColor: const Color(0xFF6366F1),
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onSearch,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Search Numbers'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

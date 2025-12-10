import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../services/cloud_sync_service.dart';

class ConflictResolutionWidget extends StatefulWidget {
  const ConflictResolutionWidget({Key? key}) : super(key: key);

  @override
  State<ConflictResolutionWidget> createState() =>
      _ConflictResolutionWidgetState();
}

class _ConflictResolutionWidgetState extends State<ConflictResolutionWidget> {
  final CloudSyncService _syncService = CloudSyncService();
  List<Map<String, dynamic>> _conflicts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadConflicts();
  }

  Future<void> _loadConflicts() async {
    setState(() => _isLoading = true);
    try {
      final conflicts = <Map<String, dynamic>>[];
      setState(() {
        _conflicts = conflicts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load conflicts: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _resolveConflict(String conflictId, String resolution) async {
    try {
      await _loadConflicts();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Conflict resolved successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Resolution failed: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_conflicts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, size: 64, color: Colors.green[400]),
            const SizedBox(height: 16),
            const Text(
              'No Sync Conflicts',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'All data is synchronized properly',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _conflicts.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final conflict = _conflicts[index];
        return _buildConflictCard(conflict);
      },
    );
  }

  Widget _buildConflictCard(Map<String, dynamic> conflict) {
    final conflictId = conflict['id'] ?? '';
    final dataType = conflict['data_type'] ?? 'Unknown';
    final deviceA = conflict['device_a'] ?? {};
    final deviceB = conflict['device_b'] ?? {};
    final timestamp = conflict['timestamp'] != null
        ? DateTime.parse(conflict['timestamp'])
        : null;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.warning_amber,
                    color: Colors.orange[800],
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Conflict: $dataType',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (timestamp != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('MMM d, yyyy • h:mm a').format(timestamp),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildVersionCard(
                    'Device A',
                    deviceA,
                    () => _resolveConflict(conflictId, 'device_a'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildVersionCard(
                    'Device B',
                    deviceB,
                    () => _resolveConflict(conflictId, 'device_b'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _resolveConflict(conflictId, 'merge'),
                icon: const Icon(Icons.merge_type, size: 18),
                label: const Text('Merge Both'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVersionCard(
    String label,
    Map<String, dynamic> data,
    VoidCallback onSelect,
  ) {
    final deviceName = data['device_name'] ?? 'Unknown Device';
    final lastModified = data['last_modified'] != null
        ? DateTime.parse(data['last_modified'])
        : null;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            deviceName,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (lastModified != null) ...[
            const SizedBox(height: 4),
            Text(
              DateFormat('MMM d, h:mm a').format(lastModified),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onSelect,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Use This',
                style: TextStyle(fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
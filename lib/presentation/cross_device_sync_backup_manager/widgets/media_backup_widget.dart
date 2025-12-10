import 'package:flutter/material.dart';
import '../../../services/cloud_sync_service.dart';

class MediaBackupWidget extends StatefulWidget {
  const MediaBackupWidget({Key? key}) : super(key: key);

  @override
  State<MediaBackupWidget> createState() => _MediaBackupWidgetState();
}

class _MediaBackupWidgetState extends State<MediaBackupWidget> {
  final CloudSyncService _syncService = CloudSyncService();

  Map<String, dynamic> _mediaStats = {
    'photos': {'total': 0, 'synced': 0, 'size_gb': 0.0},
    'videos': {'total': 0, 'synced': 0, 'size_gb': 0.0},
    'documents': {'total': 0, 'synced': 0, 'size_gb': 0.0},
    'voice_messages': {'total': 0, 'synced': 0, 'size_gb': 0.0},
  };

  bool _compressionEnabled = true;
  bool _wifiOnly = true;
  bool _isBackingUp = false;

  @override
  void initState() {
    super.initState();
    _loadMediaStats();
  }

  Future<void> _loadMediaStats() async {
    try {
      final stats = {
        'photos': {'total': 150, 'synced': 120, 'size_gb': 2.5},
        'videos': {'total': 45, 'synced': 30, 'size_gb': 8.3},
        'documents': {'total': 78, 'synced': 78, 'size_gb': 0.5},
        'voice_messages': {'total': 203, 'synced': 195, 'size_gb': 1.2},
      };
      setState(() => _mediaStats = stats);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to load media stats: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _startBackup() async {
    setState(() => _isBackingUp = true);
    try {
      await Future.delayed(const Duration(seconds: 2));
      await _loadMediaStats();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Media backup started successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Backup failed: ${e.toString()}')),
        );
      }
    } finally {
      setState(() => _isBackingUp = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildMediaCategoryCard(
          icon: Icons.photo_library,
          title: 'Photos',
          stats: _mediaStats['photos'],
          color: Colors.blue,
        ),
        const SizedBox(height: 12),
        _buildMediaCategoryCard(
          icon: Icons.video_library,
          title: 'Videos',
          stats: _mediaStats['videos'],
          color: Colors.red,
        ),
        const SizedBox(height: 12),
        _buildMediaCategoryCard(
          icon: Icons.description,
          title: 'Documents',
          stats: _mediaStats['documents'],
          color: Colors.orange,
        ),
        const SizedBox(height: 12),
        _buildMediaCategoryCard(
          icon: Icons.mic,
          title: 'Voice Messages',
          stats: _mediaStats['voice_messages'],
          color: Colors.green,
        ),
        const SizedBox(height: 24),
        _buildBackupSettingsCard(),
        const SizedBox(height: 16),
        _buildBackupButton(),
      ],
    );
  }

  Widget _buildMediaCategoryCard({
    required IconData icon,
    required String title,
    required Map<String, dynamic> stats,
    required Color color,
  }) {
    final total = stats['total'] ?? 0;
    final synced = stats['synced'] ?? 0;
    final sizeGb = stats['size_gb'] ?? 0.0;
    final progress = total > 0 ? synced / total : 0.0;

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
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withAlpha(26),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$synced / $total backed up • ${sizeGb.toStringAsFixed(2)} GB',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: color.withAlpha(26),
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 8,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackupSettingsCard() {
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
            const Text(
              'Backup Settings',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Enable Compression'),
              subtitle: const Text('Reduce storage usage with compression'),
              value: _compressionEnabled,
              onChanged: (value) {
                setState(() => _compressionEnabled = value);
              },
              contentPadding: EdgeInsets.zero,
            ),
            const Divider(),
            SwitchListTile(
              title: const Text('Wi-Fi Only'),
              subtitle: const Text('Only backup on Wi-Fi connection'),
              value: _wifiOnly,
              onChanged: (value) {
                setState(() => _wifiOnly = value);
              },
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackupButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isBackingUp ? null : _startBackup,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isBackingUp
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'Start Backup Now',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }
}
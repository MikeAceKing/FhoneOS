import 'package:flutter/material.dart';

import '../../../services/cloud_sync_service.dart';

class SelectiveSyncControlsWidget extends StatefulWidget {
  const SelectiveSyncControlsWidget({Key? key}) : super(key: key);

  @override
  State<SelectiveSyncControlsWidget> createState() =>
      _SelectiveSyncControlsWidgetState();
}

class _SelectiveSyncControlsWidgetState
    extends State<SelectiveSyncControlsWidget> {
  final CloudSyncService _syncService = CloudSyncService();

  final Map<String, bool> _syncToggles = {
    'contacts': true,
    'messages': true,
    'call_history': true,
    'photos': true,
    'videos': false,
    'documents': true,
    'voice_messages': true,
    'settings': true,
  };

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadSyncPreferences();
  }

  Future<void> _loadSyncPreferences() async {
    try {
      final configs = await _syncService.getSyncConfigurations();
      setState(() {
        for (var config in configs) {
          if (_syncToggles.containsKey(config.categoryId)) {
            _syncToggles[config.categoryId] = config.isEnabled ?? false;
          }
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to load preferences: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _saveSyncPreferences() async {
    setState(() => _isSaving = true);
    try {
      final configs = await _syncService.getSyncConfigurations();
      for (var config in configs) {
        if (_syncToggles.containsKey(config.categoryId)) {
          await _syncService.updateSyncConfiguration(
            configId: config.id ?? '',
            isEnabled: _syncToggles[config.categoryId],
          );
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Preferences saved successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: ${e.toString()}')),
        );
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Select Data Types to Sync',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              _buildSyncCard(
                icon: Icons.contacts,
                title: 'Contacts',
                subtitle: 'Sync contact information across devices',
                toggleKey: 'contacts',
                color: Colors.blue,
              ),
              const SizedBox(height: 12),
              _buildSyncCard(
                icon: Icons.message,
                title: 'Messages',
                subtitle: 'Sync SMS and chat messages',
                toggleKey: 'messages',
                color: Colors.green,
              ),
              const SizedBox(height: 12),
              _buildSyncCard(
                icon: Icons.phone,
                title: 'Call History',
                subtitle: 'Sync call logs and recordings',
                toggleKey: 'call_history',
                color: Colors.orange,
              ),
              const SizedBox(height: 12),
              _buildSyncCard(
                icon: Icons.photo_library,
                title: 'Photos',
                subtitle: 'Sync photo library',
                toggleKey: 'photos',
                color: Colors.purple,
              ),
              const SizedBox(height: 12),
              _buildSyncCard(
                icon: Icons.video_library,
                title: 'Videos',
                subtitle: 'Sync video library (large files)',
                toggleKey: 'videos',
                color: Colors.red,
              ),
              const SizedBox(height: 12),
              _buildSyncCard(
                icon: Icons.description,
                title: 'Documents',
                subtitle: 'Sync document files',
                toggleKey: 'documents',
                color: Colors.indigo,
              ),
              const SizedBox(height: 12),
              _buildSyncCard(
                icon: Icons.mic,
                title: 'Voice Messages',
                subtitle: 'Sync audio recordings',
                toggleKey: 'voice_messages',
                color: Colors.teal,
              ),
              const SizedBox(height: 12),
              _buildSyncCard(
                icon: Icons.settings,
                title: 'App Settings',
                subtitle: 'Sync application preferences',
                toggleKey: 'settings',
                color: Colors.grey,
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(13),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _saveSyncPreferences,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Save Preferences',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSyncCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String toggleKey,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: SwitchListTile(
        secondary: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withAlpha(26),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
          ),
        ),
        value: _syncToggles[toggleKey] ?? false,
        onChanged: (value) {
          setState(() {
            _syncToggles[toggleKey] = value;
          });
        },
      ),
    );
  }
}
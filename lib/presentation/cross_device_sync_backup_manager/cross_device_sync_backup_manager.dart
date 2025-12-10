import 'package:flutter/material.dart';

import '../../models/device_registration.dart';
import '../../services/cloud_sync_service.dart';
import './widgets/conflict_resolution_widget.dart';
import './widgets/connected_devices_widget.dart';
import './widgets/media_backup_widget.dart';
import './widgets/selective_sync_controls_widget.dart';
import './widgets/sync_progress_widget.dart';

class CrossDeviceSyncBackupManager extends StatefulWidget {
  const CrossDeviceSyncBackupManager({Key? key}) : super(key: key);

  @override
  State<CrossDeviceSyncBackupManager> createState() =>
      _CrossDeviceSyncBackupManagerState();
}

class _CrossDeviceSyncBackupManagerState
    extends State<CrossDeviceSyncBackupManager> with TickerProviderStateMixin {
  final CloudSyncService _syncService = CloudSyncService();
  late TabController _tabController;

  List<DeviceRegistration> _connectedDevices = [];
  Map<String, dynamic> _syncStats = {};
  bool _isLoading = true;
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadSyncData();
  }

  Future<void> _loadSyncData() async {
    setState(() => _isLoading = true);
    try {
      final devices = await _syncService.getDeviceRegistrations();
      final stats = <String,
          dynamic>{}; // Initialize empty stats as getSyncStatistics is not available

      setState(() {
        _connectedDevices = devices;
        _syncStats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load sync data: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _triggerSync() async {
    setState(() => _isSyncing = true);
    try {
      await _syncService.triggerManualSync(
          ''); // Pass empty string as categoryId parameter is required
      await _loadSyncData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sync completed successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sync failed: ${e.toString()}')),
        );
      }
    } finally {
      setState(() => _isSyncing = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Sync & Backup Manager',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Colors.grey[200]!, width: 1),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: Theme.of(context).primaryColor,
              unselectedLabelColor: Colors.grey[600],
              indicatorColor: Theme.of(context).primaryColor,
              indicatorWeight: 3,
              tabs: const [
                Tab(text: 'Devices'),
                Tab(text: 'Sync Status'),
                Tab(text: 'Media Backup'),
                Tab(text: 'Sync Controls'),
                Tab(text: 'Conflicts'),
              ],
            ),
          ),
        ),
        actions: [
          if (_isSyncing)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.sync),
              onPressed: _triggerSync,
              tooltip: 'Sync Now',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                ConnectedDevicesWidget(devices: _connectedDevices),
                SyncProgressWidget(syncStats: _syncStats),
                const MediaBackupWidget(),
                const SelectiveSyncControlsWidget(),
                const ConflictResolutionWidget(),
              ],
            ),
    );
  }
}
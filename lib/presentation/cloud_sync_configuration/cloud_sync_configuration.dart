import '../../models/sync_configuration.dart';
import '../../services/cloud_sync_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import './widgets/backup_frequency_widget.dart';
import './widgets/bandwidth_settings_widget.dart';
import './widgets/device_management_widget.dart';
import './widgets/encryption_controls_widget.dart';
import './widgets/sync_category_card_widget.dart';

class CloudSyncConfiguration extends StatefulWidget {
  const CloudSyncConfiguration({Key? key}) : super(key: key);

  @override
  State<CloudSyncConfiguration> createState() => _CloudSyncConfigurationState();
}

class _CloudSyncConfigurationState extends State<CloudSyncConfiguration> {
  final CloudSyncService _syncService = CloudSyncService();
  List<SyncConfiguration> _syncConfigs = [];
  List<DeviceRegistration> _devices = [];
  BackupSchedule? _backupSchedule;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSyncData();
  }

  Future<void> _loadSyncData() async {
    setState(() => _isLoading = true);
    try {
      final configs = await _syncService.getSyncConfigurations();
      final devices = await _syncService.getDeviceRegistrations();
      final schedule = await _syncService.getBackupSchedule();

      setState(() {
        _syncConfigs = configs;
        _devices = devices;
        _backupSchedule = schedule;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load sync data: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Cloud Sync Configuration',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadSyncData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sync Status Dashboard
                    _buildSectionTitle('Sync Status Dashboard'),
                    const SizedBox(height: 12),
                    _buildSyncStatusCard(),
                    const SizedBox(height: 24),

                    // Sync Categories
                    _buildSectionTitle('Data Categories'),
                    const SizedBox(height: 12),
                    ..._syncConfigs.map((config) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: SyncCategoryCardWidget(
                            configuration: config,
                            onToggle: (isEnabled) =>
                                _handleToggleSync(config.id, isEnabled),
                            onSettingsTap: () => _showCategorySettings(config),
                          ),
                        )),
                    const SizedBox(height: 24),

                    // Bandwidth Management
                    _buildSectionTitle('Bandwidth Management'),
                    const SizedBox(height: 12),
                    BandwidthSettingsWidget(
                      wifiOnly: _syncConfigs.first.wifiOnly,
                      cellularLimitMb: _syncConfigs.first.cellularDataLimitMb,
                      onWifiOnlyChanged: _handleWifiOnlyChanged,
                      onCellularLimitChanged: _handleCellularLimitChanged,
                    ),
                    const SizedBox(height: 24),

                    // Encryption Settings
                    _buildSectionTitle('Security & Encryption'),
                    const SizedBox(height: 12),
                    EncryptionControlsWidget(
                      onEncryptionLevelChanged: _handleEncryptionLevelChanged,
                    ),
                    const SizedBox(height: 24),

                    // Backup Frequency
                    _buildSectionTitle('Backup Schedule'),
                    const SizedBox(height: 12),
                    BackupFrequencyWidget(
                      backupSchedule: _backupSchedule,
                      onFrequencyChanged: _handleBackupFrequencyChanged,
                    ),
                    const SizedBox(height: 24),

                    // Device Management
                    _buildSectionTitle('Connected Devices'),
                    const SizedBox(height: 12),
                    DeviceManagementWidget(
                      devices: _devices,
                      onDevicePermissionsChanged:
                          _handleDevicePermissionsChanged,
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildSyncStatusCard() {
    final totalStorage = _syncConfigs.fold<double>(
      0,
      (sum, config) => sum + config.storageUsedMb,
    );
    final activeSyncs = _syncConfigs.where((c) => c.isEnabled).length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatusItem(
                  'Active Syncs',
                  '$activeSyncs/${_syncConfigs.length}',
                  Icons.sync,
                  Colors.green,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.grey[200],
              ),
              Expanded(
                child: _buildStatusItem(
                  'Storage Used',
                  '${totalStorage.toStringAsFixed(1)} MB',
                  Icons.storage,
                  Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: totalStorage / (_backupSchedule?.storageQuotaMb ?? 5000),
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              totalStorage > 4000 ? Colors.orange : Colors.green,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${totalStorage.toStringAsFixed(1)} MB / ${_backupSchedule?.storageQuotaMb ?? 5000} MB used',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusItem(
      String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Future<void> _handleToggleSync(String configId, bool isEnabled) async {
    try {
      await _syncService.updateSyncConfiguration(
        configId: configId,
        isEnabled: isEnabled,
      );
      await _loadSyncData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update sync: $e')),
        );
      }
    }
  }

  void _showCategorySettings(SyncConfiguration config) {
    // Show category-specific settings dialog
  }

  Future<void> _handleWifiOnlyChanged(bool value) async {
    try {
      for (final config in _syncConfigs) {
        await _syncService.updateSyncConfiguration(
          configId: config.id,
          wifiOnly: value,
        );
      }
      await _loadSyncData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update settings: $e')),
        );
      }
    }
  }

  Future<void> _handleCellularLimitChanged(int limitMb) async {
    try {
      for (final config in _syncConfigs) {
        await _syncService.updateSyncConfiguration(
          configId: config.id,
          cellularDataLimitMb: limitMb,
        );
      }
      await _loadSyncData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update limit: $e')),
        );
      }
    }
  }

  Future<void> _handleEncryptionLevelChanged(String level) async {
    try {
      await _syncService.updateEncryptionSettings(encryptionLevel: level);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Encryption level updated')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update encryption: $e')),
        );
      }
    }
  }

  Future<void> _handleBackupFrequencyChanged(String frequency) async {
    try {
      await _syncService.updateBackupSchedule(frequency: frequency);
      await _loadSyncData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update backup frequency: $e')),
        );
      }
    }
  }

  Future<void> _handleDevicePermissionsChanged(
      String deviceId, bool canWipe, bool syncEnabled) async {
    try {
      await _syncService.updateDevicePermissions(
        deviceId: deviceId,
        canRemoteWipe: canWipe,
        syncEnabled: syncEnabled,
      );
      await _loadSyncData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update device permissions: $e')),
        );
      }
    }
  }
}
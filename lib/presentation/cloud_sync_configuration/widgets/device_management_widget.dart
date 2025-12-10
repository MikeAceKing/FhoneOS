import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/sync_configuration.dart';

class DeviceManagementWidget extends StatelessWidget {
  final List<DeviceRegistration> devices;
  final Function(String, bool, bool) onDevicePermissionsChanged;

  const DeviceManagementWidget({
    Key? key,
    required this.devices,
    required this.onDevicePermissionsChanged,
  }) : super(key: key);

  String _formatLastActive(DateTime lastActive) {
    final now = DateTime.now();
    final diff = now.difference(lastActive);

    if (diff.inMinutes < 1) return 'Active now';
    if (diff.inMinutes < 60) return 'Active ${diff.inMinutes}m ago';
    if (diff.inHours < 24) return 'Active ${diff.inHours}h ago';
    if (diff.inDays < 7) return 'Active ${diff.inDays}d ago';
    return 'Last active ${lastActive.day}/${lastActive.month}';
  }

  IconData _getDeviceIcon(String? model) {
    if (model == null) return Icons.phone_android;
    final modelLower = model.toLowerCase();
    if (modelLower.contains('iphone') || modelLower.contains('ipad')) {
      return Icons.phone_iphone;
    }
    if (modelLower.contains('tablet')) {
      return Icons.tablet_android;
    }
    return Icons.phone_android;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.devices, color: Colors.purple[700], size: 24),
              const SizedBox(width: 12),
              Text(
                'Device Management',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (devices.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(Icons.devices_other,
                        size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 12),
                    Text(
                      'No devices registered',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...devices.map((device) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildDeviceCard(context, device),
                )),
        ],
      ),
    );
  }

  Widget _buildDeviceCard(BuildContext context, DeviceRegistration device) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: device.syncEnabled ? Colors.green[200]! : Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getDeviceIcon(device.deviceModel),
                  size: 24,
                  color: Colors.purple[700],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      device.deviceName,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    if (device.deviceModel != null)
                      Text(
                        device.deviceModel!,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                      ),
                  ],
                ),
              ),
              if (device.isTrusted)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Trusted',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.green[900],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 6),
              Text(
                _formatLastActive(device.lastActiveAt),
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.grey[700],
                ),
              ),
              const Spacer(),
              if (device.osVersion != null) ...[
                Icon(Icons.info_outline, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 6),
                Text(
                  device.osVersion!,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ],
          ),
          const Divider(height: 16),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(Icons.sync, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 6),
                    Text(
                      'Sync',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.grey[700],
                      ),
                    ),
                    const Spacer(),
                    Switch(
                      value: device.syncEnabled,
                      onChanged: (value) => onDevicePermissionsChanged(
                        device.id,
                        device.canRemoteWipe,
                        value,
                      ),
                      activeColor: Colors.green,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Row(
                  children: [
                    Icon(Icons.delete_forever,
                        size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 6),
                    Text(
                      'Remote Wipe',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.grey[700],
                      ),
                    ),
                    const Spacer(),
                    Switch(
                      value: device.canRemoteWipe,
                      onChanged: (value) => onDevicePermissionsChanged(
                        device.id,
                        value,
                        device.syncEnabled,
                      ),
                      activeColor: Colors.red,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
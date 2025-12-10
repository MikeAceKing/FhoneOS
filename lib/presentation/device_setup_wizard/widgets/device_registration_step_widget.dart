import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:device_info_plus/device_info_plus.dart';

class DeviceRegistrationStepWidget extends StatefulWidget {
  final VoidCallback onContinue;
  final VoidCallback onBack;

  const DeviceRegistrationStepWidget({
    super.key,
    required this.onContinue,
    required this.onBack,
  });

  @override
  State<DeviceRegistrationStepWidget> createState() =>
      _DeviceRegistrationStepWidgetState();
}

class _DeviceRegistrationStepWidgetState
    extends State<DeviceRegistrationStepWidget> {
  bool _isLoading = false;
  String _deviceModel = 'Unknown';
  String _deviceManufacturer = 'Unknown';
  String _androidVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
    _getDeviceInfo();
  }

  Future<void> _getDeviceInfo() async {
    setState(() => _isLoading = true);
    try {
      final deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        setState(() {
          _deviceModel = androidInfo.model;
          _deviceManufacturer = androidInfo.manufacturer;
          _androidVersion = androidInfo.version.release;
        });
      }
    } catch (e) {
      debugPrint('Error getting device info: $e');
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Center(
            child: Icon(
              Icons.smartphone,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Device Registration',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'We\'re registering your device with FhoneOS servers',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 32),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildInfoRow('Device Model', _deviceModel),
                  const Divider(height: 24),
                  _buildInfoRow('Manufacturer', _deviceManufacturer),
                  const Divider(height: 24),
                  _buildInfoRow('Android Version', _androidVersion),
                ],
              ),
            ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: widget.onBack,
                child: const Text('Back'),
              ),
              ElevatedButton(
                onPressed: _isLoading ? null : widget.onContinue,
                child: const Text('Continue'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[700],
                fontWeight: FontWeight.w600,
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }
}

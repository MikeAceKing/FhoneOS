import 'package:flutter/material.dart';

class PermissionsStepWidget extends StatefulWidget {
  final VoidCallback onContinue;
  final VoidCallback onBack;
  final VoidCallback onSkip;

  const PermissionsStepWidget({
    super.key,
    required this.onContinue,
    required this.onBack,
    required this.onSkip,
  });

  @override
  State<PermissionsStepWidget> createState() => _PermissionsStepWidgetState();
}

class _PermissionsStepWidgetState extends State<PermissionsStepWidget> {
  final Map<String, bool> _permissions = {
    'phone': false,
    'sms': false,
    'contacts': false,
    'storage': false,
    'camera': false,
    'microphone': false,
    'location': false,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.security,
            size: 64,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'Permission Setup',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Grant essential permissions for FhoneOS to function',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView(
              children: [
                _buildPermissionCard(
                  'Phone',
                  'Make and receive calls',
                  Icons.phone,
                  'phone',
                  isEssential: true,
                ),
                _buildPermissionCard(
                  'SMS',
                  'Send and receive messages',
                  Icons.message,
                  'sms',
                  isEssential: true,
                ),
                _buildPermissionCard(
                  'Contacts',
                  'Access your contact list',
                  Icons.contacts,
                  'contacts',
                  isEssential: true,
                ),
                _buildPermissionCard(
                  'Storage',
                  'Save files and media',
                  Icons.storage,
                  'storage',
                ),
                _buildPermissionCard(
                  'Camera',
                  'Take photos and videos',
                  Icons.camera_alt,
                  'camera',
                ),
                _buildPermissionCard(
                  'Microphone',
                  'Record audio',
                  Icons.mic,
                  'microphone',
                ),
                _buildPermissionCard(
                  'Location',
                  'Access device location',
                  Icons.location_on,
                  'location',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: widget.onBack,
                child: const Text('Back'),
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: widget.onSkip,
                    child: const Text('Skip'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: widget.onContinue,
                    child: const Text('Continue'),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionCard(
    String title,
    String description,
    IconData icon,
    String key, {
    bool isEssential = false,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary.withAlpha(26),
          child: Icon(icon, color: Theme.of(context).colorScheme.primary),
        ),
        title: Row(
          children: [
            Text(title),
            if (isEssential) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red[100],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Essential',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.red[800],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        subtitle: Text(description),
        trailing: Switch(
          value: _permissions[key] ?? false,
          onChanged: (value) {
            setState(() => _permissions[key] = value);
          },
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class ProfileSetupWidget extends StatefulWidget {
  final Function(Map<String, String>) onComplete;

  const ProfileSetupWidget({
    super.key,
    required this.onComplete,
  });

  @override
  State<ProfileSetupWidget> createState() => _ProfileSetupWidgetState();
}

class _ProfileSetupWidgetState extends State<ProfileSetupWidget> {
  final _displayNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _avatarUrl = '';

  @override
  void dispose() {
    _displayNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Setup Your Profile',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: () {
                // Avatar selection logic
              },
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey.shade300,
                backgroundImage:
                    _avatarUrl.isNotEmpty ? NetworkImage(_avatarUrl) : null,
                child: _avatarUrl.isEmpty
                    ? const Icon(Icons.person, size: 50)
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () {
                // Avatar upload logic
              },
              icon: const Icon(Icons.camera_alt),
              label: const Text('Upload Photo'),
            ),
            const SizedBox(height: 32),
            TextFormField(
              controller: _displayNameController,
              decoration: const InputDecoration(
                labelText: 'Display Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.badge),
              ),
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Please enter a display name' : null,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  widget.onComplete({
                    'displayName': _displayNameController.text,
                    'avatarUrl': _avatarUrl,
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
              ),
              child: const Text('Continue'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => widget.onComplete({}),
              child: const Text('Skip for now'),
            ),
          ],
        ),
      ),
    );
  }
}

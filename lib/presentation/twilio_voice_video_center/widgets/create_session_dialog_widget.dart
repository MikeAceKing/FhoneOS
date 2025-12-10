import 'package:flutter/material.dart';

class CreateSessionDialogWidget extends StatefulWidget {
  const CreateSessionDialogWidget({Key? key}) : super(key: key);

  @override
  State<CreateSessionDialogWidget> createState() =>
      _CreateSessionDialogWidgetState();
}

class _CreateSessionDialogWidgetState extends State<CreateSessionDialogWidget> {
  final _formKey = GlobalKey<FormState>();
  final _roomNameController = TextEditingController();
  DateTime? _scheduledAt;
  int _maxParticipants = 10;
  bool _isRecording = false;

  @override
  void dispose() {
    _roomNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Video Session'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _roomNameController,
                decoration: const InputDecoration(
                  labelText: 'Room Name',
                  hintText: 'Enter room name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a room name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Schedule for later'),
                subtitle: _scheduledAt != null
                    ? Text(
                        '${_scheduledAt!.day}/${_scheduledAt!.month}/${_scheduledAt!.year} ${_scheduledAt!.hour}:${_scheduledAt!.minute.toString().padLeft(2, '0')}',
                      )
                    : const Text('Start immediately'),
                trailing: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );

                    if (date != null) {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );

                      if (time != null) {
                        setState(() {
                          _scheduledAt = DateTime(
                            date.year,
                            date.month,
                            date.day,
                            time.hour,
                            time.minute,
                          );
                        });
                      }
                    }
                  },
                ),
              ),
              const SizedBox(height: 16),
              const Text('Max Participants'),
              Slider(
                value: _maxParticipants.toDouble(),
                min: 2,
                max: 50,
                divisions: 48,
                label: _maxParticipants.toString(),
                onChanged: (value) {
                  setState(() => _maxParticipants = value.toInt());
                },
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Enable Recording'),
                subtitle: const Text('Record this session'),
                value: _isRecording,
                onChanged: (value) {
                  setState(() => _isRecording = value);
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.of(context).pop({
                'roomName': _roomNameController.text,
                'scheduledAt': _scheduledAt,
                'maxParticipants': _maxParticipants,
                'isRecording': _isRecording,
              });
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0088CC),
          ),
          child: const Text('Create'),
        ),
      ],
    );
  }
}

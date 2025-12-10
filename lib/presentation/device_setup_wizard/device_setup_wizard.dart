import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import '../../routes/app_routes.dart';
import './widgets/completion_step_widget.dart';
import './widgets/device_registration_step_widget.dart';
import './widgets/permissions_step_widget.dart';
import './widgets/setup_step_indicator_widget.dart';
import './widgets/twilio_setup_step_widget.dart';
import './widgets/welcome_step_widget.dart';

class DeviceSetupWizard extends StatefulWidget {
  const DeviceSetupWizard({super.key});

  @override
  State<DeviceSetupWizard> createState() => _DeviceSetupWizardState();
}

class _DeviceSetupWizardState extends State<DeviceSetupWizard> {
  int _currentStep = 0;
  final List<String> _steps = [
    'Welcome',
    'Device Registration',
    'Permissions',
    'Twilio Setup',
    'Contact Backup',
    'SMS Backup',
    'Completion'
  ];

  void _nextStep() {
    if (_currentStep < _steps.length - 1) {
      setState(() => _currentStep++);
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.desktop);
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  void _skipStep() {
    _nextStep();
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return WelcomeStepWidget(onContinue: _nextStep);
      case 1:
        return DeviceRegistrationStepWidget(
            onContinue: _nextStep, onBack: _previousStep);
      case 2:
        return PermissionsStepWidget(
          onContinue: _nextStep,
          onBack: _previousStep,
          onSkip: _skipStep,
        );
      case 3:
        return TwilioSetupStepWidget(
          onContinue: _nextStep,
          onBack: _previousStep,
          onSkip: _skipStep,
        );
      case 4:
      case 5:
        return _buildBackupStep();
      case 6:
        return CompletionStepWidget(onFinish: _nextStep);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildBackupStep() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _currentStep == 4 ? Icons.contacts : Icons.sms,
            size: 80,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 24),
          Text(
            _currentStep == 4 ? 'Contact Backup' : 'SMS Backup',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Text(
            _currentStep == 4
                ? 'Securely backup your contacts to the cloud with end-to-end encryption'
                : 'Archive your messages with date range selection and cloud storage',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: _previousStep,
                child: const Text('Back'),
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: _skipStep,
                    child: const Text('Skip'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _nextStep,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _currentStep > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black87),
                onPressed: _previousStep,
              )
            : null,
        actions: [
          if (_currentStep < _steps.length - 1 && _currentStep > 0)
            TextButton(
              onPressed: _skipStep,
              child: Text(
                'Skip',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          SetupStepIndicatorWidget(
            currentStep: _currentStep,
            totalSteps: _steps.length,
            stepNames: _steps,
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _buildStepContent(),
            ),
          ),
        ],
      ),
    );
  }
}
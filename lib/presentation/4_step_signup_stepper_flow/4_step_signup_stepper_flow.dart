import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import '../../services/auth_service.dart';
import '../../services/fhoneos_subscription_service.dart';
import './widgets/step_1_account_widget.dart';
import './widgets/step_2_phone_plan_widget.dart';
import './widgets/step_3_ai_addons_widget.dart';
import './widgets/step_4_billing_widget.dart';

class SignupStepperFlow extends StatefulWidget {
  const SignupStepperFlow({Key? key}) : super(key: key);

  @override
  State<SignupStepperFlow> createState() => _SignupStepperFlowState();
}

class _SignupStepperFlowState extends State<SignupStepperFlow> {
  int _currentStep = 0;
  final _authService = AuthService.instance;
  final _subscriptionService = FhoneOSSubscriptionService();

  final SignupData _signupData = SignupData();

  List<String> get _stepTitles => [
    'Create Account',
    'Phone & Plan',
    'AI & Add-ons',
    'Billing & Review',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF334155)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildStepperIndicator(),
              Expanded(child: _buildStepContent()),
              _buildNavigationButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              if (_currentStep > 0) {
                setState(() => _currentStep--);
              } else {
                Navigator.pop(context);
              }
            },
          ),
          const Spacer(),
          Text(
            'FhoneOS Signup',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildStepperIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: List.generate(4, (index) {
          final isCompleted = index < _currentStep;
          final isCurrent = index == _currentStep;
          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color:
                          isCompleted || isCurrent
                              ? const Color(0xFF3B82F6)
                              : Colors.white.withAlpha(51),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                if (index < 3) const SizedBox(width: 4),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStepContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Step ${_currentStep + 1} of 4',
              style: GoogleFonts.inter(fontSize: 14, color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Text(
              _stepTitles[_currentStep],
              style: GoogleFonts.inter(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 32),
            _getStepWidget(),
          ],
        ),
      ),
    );
  }

  Widget _getStepWidget() {
    switch (_currentStep) {
      case 0:
        return Step1AccountWidget(
          signupData: _signupData,
          onNext: () => setState(() => _currentStep++),
        );
      case 1:
        return Step2PhonePlanWidget(
          signupData: _signupData,
          onNext: () => setState(() => _currentStep++),
          onBack: () => setState(() => _currentStep--),
        );
      case 2:
        return Step3AIAddonsWidget(
          signupData: _signupData,
          onNext: () => setState(() => _currentStep++),
          onBack: () => setState(() => _currentStep--),
        );
      case 3:
        return Step4BillingWidget(
          signupData: _signupData,
          onComplete: _handleSignupComplete,
          onBack: () => setState(() => _currentStep--),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(77),
        border: Border(
          top: BorderSide(color: Colors.white.withAlpha(26), width: 1),
        ),
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _currentStep--),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Colors.white30),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Back',
                  style: GoogleFonts.inter(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            child: TextButton(
              onPressed: () {
                Navigator.pushReplacementNamed(
                  context,
                  AppRoutes.fhoneOsAuthenticationGateway,
                );
              },
              child: Text(
                'Already a member? Sign In',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: const Color(0xFF3B82F6),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSignupComplete() async {
    try {
      await _authService.signUp(
        email: _signupData.email!,
        password: _signupData.password!,
        fullName: _signupData.fullName!,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account created successfully! Welcome to FhoneOS.'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushReplacementNamed(context, AppRoutes.fhoneOsDashboard);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Signup failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class SignupData {
  String? fullName;
  String? email;
  String? password;
  String? country;
  bool agreedToTerms = false;

  String? phoneNumberId;
  String? selectedPlanId;
  String? planName;
  double? planPrice;

  List<String> selectedAddons = [];
  List<String> selectedTwilioAddons = [];

  String? companyName;
  String? billingAddress;
  String? vatNumber;
  String? paymentMethod;
  bool agreedToSubscription = false;

  double get totalMonthly {
    double total = planPrice ?? 0.0;
    return total;
  }
}

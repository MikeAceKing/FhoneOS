import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/auth_service.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/account_step_widget.dart';
import './widgets/billing_review_step_widget.dart';
import './widgets/phone_plan_step_widget.dart';
import './widgets/signup_progress_indicator_widget.dart';
import './widgets/ai_addons_step_widget.dart';

/// FhoneOS Signup Flow - 4-step registration with phone number, plan, AI addons, and billing
class FhoneosSignupFlow extends StatefulWidget {
  const FhoneosSignupFlow({super.key});

  @override
  State<FhoneosSignupFlow> createState() => _FhoneosSignupFlowState();
}

class _FhoneosSignupFlowState extends State<FhoneosSignupFlow> {
  int _currentStep = 0;
  final PageController _pageController = PageController();
  bool _isLoading = false;

  // Step 1: Account data
  final _accountFormKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String _selectedCountry = 'Netherlands';
  bool _termsAccepted = false;

  // Step 2: Phone number & plan
  String? _selectedPhoneNumber;
  String? _selectedPlan;
  String _numberType = 'Mobile';
  String _countryPrefix = '+31';

  // Step 3: AI & Addons
  final Map<String, bool> _selectedAddons = {
    'ai_call_assistant': false,
    'ai_sms_copilot': false,
    'voicemail_to_text': false,
    'call_recording': false,
    'whatsapp_business': false,
    'verify_otp': false,
  };

  // Step 4: Billing
  final _companyNameController = TextEditingController();
  final _billingAddressController = TextEditingController();
  final _vatIdController = TextEditingController();
  String _paymentMethod = 'Card';

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _companyNameController.dispose();
    _billingAddressController.dispose();
    _vatIdController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 3) {
      if (_validateCurrentStep()) {
        setState(() => _currentStep++);
        _pageController.animateToPage(
          _currentStep,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        // Add null check before validate()
        final formState = _accountFormKey.currentState;
        if (formState == null) {
          _showError('Form initialization error. Please refresh the page.');
          return false;
        }
        if (!formState.validate()) return false;
        if (!_termsAccepted) {
          _showError('Please accept the Terms of Service');
          return false;
        }
        return true;
      case 1:
        if (_selectedPhoneNumber == null) {
          _showError('Please select a phone number');
          return false;
        }
        if (_selectedPlan == null) {
          _showError('Please select a plan');
          return false;
        }
        return true;
      case 2:
        return true;
      default:
        return true;
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _completeSignup() async {
    if (!_validateCurrentStep()) return;

    setState(() => _isLoading = true);

    try {
      await AuthService.instance.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: _fullNameController.text,
      );

      HapticFeedback.mediumImpact();

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/fhone-os-dashboard');
      }
    } catch (e) {
      _showError('Signup failed: ${e.toString()}');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _currentStep > 0
            ? IconButton(
                icon: CustomIconWidget(
                  iconName: 'arrow_back',
                  color: Colors.white,
                  size: 24.0,
                ),
                onPressed: _previousStep,
              )
            : null,
        title: Text(
          'Create FhoneOS Account',
          style: theme.textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            SignupProgressIndicatorWidget(
              currentStep: _currentStep,
              totalSteps: 4,
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() => _currentStep = index);
                },
                children: [
                  AccountStepWidget(
                    formKey: _accountFormKey,
                    fullNameController: _fullNameController,
                    emailController: _emailController,
                    passwordController: _passwordController,
                    confirmPasswordController: _confirmPasswordController,
                    selectedCountry: _selectedCountry,
                    termsAccepted: _termsAccepted,
                    onCountryChanged: (country) {
                      setState(() => _selectedCountry = country);
                    },
                    onTermsChanged: (value) {
                      setState(() => _termsAccepted = value);
                    },
                  ),
                  PhonePlanStepWidget(
                    countryPrefix: _countryPrefix,
                    numberType: _numberType,
                    selectedPhoneNumber: _selectedPhoneNumber,
                    selectedPlan: _selectedPlan,
                    onPrefixChanged: (prefix) {
                      setState(() => _countryPrefix = prefix);
                    },
                    onTypeChanged: (type) {
                      setState(() => _numberType = type);
                    },
                    onPhoneNumberSelected: (number) {
                      setState(() => _selectedPhoneNumber = number);
                    },
                    onPlanSelected: (plan) {
                      setState(() => _selectedPlan = plan);
                    },
                  ),
                  AiAddonsStepWidget(
                    selectedAddons: _selectedAddons,
                    onAddonToggle: (key, value) {
                      setState(() => _selectedAddons[key] = value);
                    },
                  ),
                  BillingReviewStepWidget(
                    companyNameController: _companyNameController,
                    billingAddressController: _billingAddressController,
                    vatIdController: _vatIdController,
                    paymentMethod: _paymentMethod,
                    selectedPhoneNumber: _selectedPhoneNumber ?? 'None',
                    selectedPlan: _selectedPlan ?? 'None',
                    selectedAddons: _selectedAddons,
                    onPaymentMethodChanged: (method) {
                      setState(() => _paymentMethod = method);
                    },
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: const Color(0xFF0A0E27),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 10.0,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  if (_currentStep > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isLoading ? null : _previousStep,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF00D9FF),
                          side: const BorderSide(
                            color: Color(0xFF00D9FF),
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                        ),
                        child: Text(
                          'Back',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: const Color(0xFF00D9FF),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  if (_currentStep > 0) const SizedBox(width: 16.0),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : (_currentStep == 3 ? _completeSignup : _nextStep),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00D9FF),
                        foregroundColor: const Color(0xFF0A0E27),
                        elevation: 4.0,
                        shadowColor: const Color(
                          0xFF00D9FF,
                        ).withValues(alpha: 0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 24.0,
                              width: 24.0,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFF0A0E27),
                                ),
                              ),
                            )
                          : Text(
                              _currentStep == 3
                                  ? 'Start FhoneOS'
                                  : _getNextButtonLabel(),
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: const Color(0xFF0A0E27),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getNextButtonLabel() {
    switch (_currentStep) {
      case 0:
        return 'Next: Phone & Plan';
      case 1:
        return 'Next: AI & Add-ons';
      case 2:
        return 'Next: Billing';
      default:
        return 'Next';
    }
  }
}

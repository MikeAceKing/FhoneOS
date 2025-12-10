import 'package:flutter/material.dart';

import '../../../widgets/custom_icon_widget.dart';

/// Step 1: Account creation with basic information
class AccountStepWidget extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController fullNameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final String selectedCountry;
  final bool termsAccepted;
  final Function(String) onCountryChanged;
  final Function(bool) onTermsChanged;

  const AccountStepWidget({
    super.key,
    required this.formKey,
    required this.fullNameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.selectedCountry,
    required this.termsAccepted,
    required this.onCountryChanged,
    required this.onTermsChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Create your FhoneOS account',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Enter your details to get started',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 32.0),
            _buildTextField(
              controller: fullNameController,
              label: 'Full Name',
              icon: 'person',
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Name is required';
                return null;
              },
            ),
            const SizedBox(height: 20.0),
            _buildTextField(
              controller: emailController,
              label: 'Work Email',
              icon: 'email',
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Email is required';
                if (!value!.contains('@')) return 'Invalid email format';
                return null;
              },
            ),
            const SizedBox(height: 20.0),
            _buildTextField(
              controller: passwordController,
              label: 'Password',
              icon: 'lock',
              obscureText: true,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Password is required';
                if (value!.length < 8) {
                  return 'Password must be at least 8 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 20.0),
            _buildTextField(
              controller: confirmPasswordController,
              label: 'Confirm Password',
              icon: 'lock',
              obscureText: true,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Please confirm password';
                }
                if (value != passwordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
            const SizedBox(height: 20.0),
            _buildCountryDropdown(theme),
            const SizedBox(height: 24.0),
            _buildTermsCheckbox(theme),
            const SizedBox(height: 16.0),
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(
                    context,
                    '/welcome-login-screen',
                  );
                },
                child: Text(
                  'Already a member? Sign In',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF00D9FF),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
        prefixIcon: CustomIconWidget(
          iconName: icon,
          color: const Color(0xFF00D9FF),
          size: 20.0,
        ),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: Color(0xFF00D9FF), width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: Colors.red, width: 2.0),
        ),
      ),
    );
  }

  Widget _buildCountryDropdown(ThemeData theme) {
    // Comprehensive list of European and worldwide countries
    final List<String> countries = [
      // European Countries
      'Austria',
      'Belgium',
      'Bulgaria',
      'Croatia',
      'Cyprus',
      'Czech Republic',
      'Denmark',
      'Estonia',
      'Finland',
      'France',
      'Germany',
      'Greece',
      'Hungary',
      'Ireland',
      'Italy',
      'Latvia',
      'Lithuania',
      'Luxembourg',
      'Malta',
      'Netherlands',
      'Poland',
      'Portugal',
      'Romania',
      'Slovakia',
      'Slovenia',
      'Spain',
      'Sweden',
      // Non-EU European Countries
      'Norway',
      'Switzerland',
      'United Kingdom',
      // North America
      'United States',
      'Canada',
      'Mexico',
      // Other Major Countries
      'Australia',
      'Brazil',
      'China',
      'India',
      'Japan',
      'South Korea',
      'Singapore',
      'United Arab Emirates',
    ]..sort(); // Sort alphabetically

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: 'public',
            color: const Color(0xFF00D9FF),
            size: 20.0,
          ),
          const SizedBox(width: 16.0),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedCountry,
                dropdownColor: const Color(0xFF1A1F3A),
                style: const TextStyle(color: Colors.white, fontSize: 16.0),
                icon: CustomIconWidget(
                  iconName: 'arrow_drop_down',
                  color: const Color(0xFF00D9FF),
                  size: 24.0,
                ),
                isExpanded: true,
                items: countries
                    .map(
                      (country) => DropdownMenuItem(
                        value: country,
                        child: Text(country),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) onCountryChanged(value);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermsCheckbox(ThemeData theme) {
    return Row(
      children: [
        Checkbox(
          value: termsAccepted,
          onChanged: (value) {
            if (value != null) onTermsChanged(value);
          },
          activeColor: const Color(0xFF00D9FF),
          checkColor: const Color(0xFF0A0E27),
          side: BorderSide(
            color: Colors.white.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () => onTermsChanged(!termsAccepted),
            child: Text.rich(
              TextSpan(
                text: 'I agree to the ',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.7),
                ),
                children: [
                  TextSpan(
                    text: 'Terms of Service',
                    style: TextStyle(
                      color: const Color(0xFF00D9FF),
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                      decorationColor: const Color(0xFF00D9FF),
                    ),
                  ),
                  const TextSpan(text: ' and '),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: TextStyle(
                      color: const Color(0xFF00D9FF),
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                      decorationColor: const Color(0xFF00D9FF),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

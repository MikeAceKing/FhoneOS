import 'package:flutter/material.dart';

class OAuthButtonsWidget extends StatefulWidget {
  final Function(String) onOAuthSignIn;
  final Function(String, String, String) onEmailSignUp;

  const OAuthButtonsWidget({
    super.key,
    required this.onOAuthSignIn,
    required this.onEmailSignUp,
  });

  @override
  State<OAuthButtonsWidget> createState() => _OAuthButtonsWidgetState();
}

class _OAuthButtonsWidgetState extends State<OAuthButtonsWidget> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _showEmailForm = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Choose your sign-up method',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          _buildOAuthButton(
            'Continue with Google',
            Icons.g_mobiledata,
            Colors.red,
            () => widget.onOAuthSignIn('google'),
          ),
          const SizedBox(height: 16),
          _buildOAuthButton(
            'Continue with Microsoft',
            Icons.business,
            Colors.blue,
            () => widget.onOAuthSignIn('microsoft'),
          ),
          const SizedBox(height: 16),
          _buildOAuthButton(
            'Continue with Apple',
            Icons.apple,
            Colors.black,
            () => widget.onOAuthSignIn('apple'),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              const Expanded(child: Divider()),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'OR',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ),
              const Expanded(child: Divider()),
            ],
          ),
          const SizedBox(height: 24),
          if (!_showEmailForm)
            OutlinedButton.icon(
              onPressed: () => setState(() => _showEmailForm = true),
              icon: const Icon(Icons.email),
              label: const Text('Sign up with Email'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            )
          else
            _buildEmailForm(),
        ],
      ),
    );
  }

  Widget _buildOAuthButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildEmailForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _fullNameController,
            decoration: const InputDecoration(
              labelText: 'Full Name',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person),
            ),
            validator: (value) =>
                value?.isEmpty ?? true ? 'Please enter your name' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.email),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value?.isEmpty ?? true) return 'Please enter your email';
              if (!value!.contains('@')) return 'Please enter a valid email';
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            decoration: const InputDecoration(
              labelText: 'Password',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.lock),
            ),
            obscureText: true,
            validator: (value) {
              if (value?.isEmpty ?? true) return 'Please enter a password';
              if (value!.length < 6)
                return 'Password must be at least 6 characters';
              return null;
            },
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                widget.onEmailSignUp(
                  _emailController.text,
                  _passwordController.text,
                  _fullNameController.text,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(16),
            ),
            child: const Text('Create Account'),
          ),
        ],
      ),
    );
  }
}

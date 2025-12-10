import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../services/auth_service.dart';
import './widgets/dashboard_app_bar_widget.dart';
import './widgets/welcome_section_widget.dart';
import './widgets/status_section_widget.dart';
import './widgets/apps_section_widget.dart';
import './widgets/store_section_widget.dart';
import './widgets/files_section_widget.dart';
import './widgets/activity_section_widget.dart';

/// FhoneOS Dashboard
/// Central hub providing comprehensive system overview and quick access to core functionalities
class FhoneOsDashboard extends StatefulWidget {
  const FhoneOsDashboard({super.key});

  @override
  State<FhoneOsDashboard> createState() => _FhoneOsDashboardState();
}

class _FhoneOsDashboardState extends State<FhoneOsDashboard> {
  Map<String, dynamic>? _userProfile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final profile = await AuthService.instance.getUserProfile();
      if (mounted) {
        setState(() {
          _userProfile = profile;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleLogout() async {
    try {
      await AuthService.instance.signOut();
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/fhone-os-login-screen');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Logout failed: ${e.toString()}'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF020617),
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
          ),
        ),
      );
    }

    final userName = _userProfile?['full_name'] ?? 'User';
    final userEmail = _userProfile?['email'] ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFF020617), // slate-950
      body: Column(
        children: [
          // Top App Bar
          DashboardAppBarWidget(userName: userName, onLogout: _handleLogout),

          // Main Content
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              children: [
                // Welcome Section
                WelcomeSectionWidget(userName: userName),
                SizedBox(height: 2.h),

                // Status Section
                const StatusSectionWidget(),
                SizedBox(height: 2.h),

                // Apps Grid Section
                const AppsSectionWidget(),
                SizedBox(height: 2.h),

                // Store Section
                const StoreSectionWidget(),
                SizedBox(height: 2.h),

                // Files Section
                const FilesSectionWidget(),
                SizedBox(height: 2.h),

                // Activity Section
                const ActivitySectionWidget(),
                SizedBox(height: 2.h),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

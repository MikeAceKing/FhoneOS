import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import './widgets/accent_color_picker_widget.dart';
import './widgets/device_card_widget.dart';
import './widgets/settings_item_widget.dart';
import './widgets/settings_section_widget.dart';
import './widgets/storage_usage_widget.dart';
import './widgets/theme_selector_widget.dart';

/// Settings Screen - Comprehensive app customization and system management
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Theme settings
  String _selectedTheme = 'dark';
  Color _accentColor = const Color(0xFF4A9EFF);

  // Language settings
  String _selectedLanguage = 'English';

  // Notification preferences
  bool _messagesNotifications = true;
  bool _callsNotifications = true;
  bool _socialUpdatesNotifications = true;
  bool _systemAlertsNotifications = false;

  // Privacy settings
  bool _dataSharing = false;
  bool _analyticsEnabled = true;

  // Storage data
  final Map<String, double> _storageData = {
    'Media': 2.4,
    'Messages': 0.8,
    'Cache': 0.5,
    'Documents': 0.3,
  };
  final double _totalStorage = 5.0;

  // Connected devices
  final List<Map<String, dynamic>> _connectedDevices = [
    {
      'name': 'iPhone 14 Pro',
      'type': 'mobile',
      'lastSync': '2 minutes ago',
      'isCurrent': true,
    },
    {
      'name': 'iPad Air',
      'type': 'tablet',
      'lastSync': '1 hour ago',
      'isCurrent': false,
    },
    {
      'name': 'MacBook Pro',
      'type': 'desktop',
      'lastSync': '3 hours ago',
      'isCurrent': false,
    },
  ];

  // User information
  final Map<String, String> _userInfo = {
    'name': 'Alex Johnson',
    'email': 'alex.johnson@cloudos.com',
    'subscription': 'Premium',
    'memberSince': 'January 2024',
  };

  // Search controller
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showLanguagePicker() {
    final languages = [
      'English',
      'Spanish',
      'French',
      'German',
      'Italian',
      'Portuguese',
      'Chinese',
      'Japanese',
      'Korean',
      'Arabic'
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (context) {
        final theme = Theme.of(context);
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Select Language',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: languages.length,
                  itemBuilder: (context, index) {
                    final language = languages[index];
                    final isSelected = language == _selectedLanguage;
                    return ListTile(
                      title: Text(
                        language,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                      trailing: isSelected
                          ? CustomIconWidget(
                              iconName: 'check',
                              color: theme.colorScheme.primary,
                              size: 24.0,
                            )
                          : null,
                      onTap: () {
                        setState(() => _selectedLanguage = language);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteAccountDialog() {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Account',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        content: Text(
          'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently removed.',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Account deletion initiated. You will receive a confirmation email.',
                    style: GoogleFonts.inter(fontSize: 14),
                  ),
                  backgroundColor: theme.colorScheme.error,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
            ),
            child: Text(
              'Delete',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _clearCache() {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Clear Cache',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        content: Text(
          'This will clear ${_storageData['Cache']?.toStringAsFixed(2)} GB of cached data. The app may take longer to load content temporarily.',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _storageData['Cache'] = 0.0;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Cache cleared successfully',
                    style: GoogleFonts.inter(fontSize: 14),
                  ),
                ),
              );
            },
            child: Text(
              'Clear',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _logoutDevice(int index) {
    final theme = Theme.of(context);
    final device = _connectedDevices[index];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Logout Device',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        content: Text(
          'Are you sure you want to logout from ${device['name']}?',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _connectedDevices.removeAt(index);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Device logged out successfully',
                    style: GoogleFonts.inter(fontSize: 14),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
            ),
            child: Text(
              'Logout',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 2.0,
        leading: IconButton(
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: theme.colorScheme.onSurface,
            size: 24.0,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: theme.colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  hintText: 'Search settings...',
                  hintStyle: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  setState(() {});
                },
              )
            : Text(
                'Settings',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
        actions: [
          IconButton(
            icon: CustomIconWidget(
              iconName: _isSearching ? 'close' : 'search',
              color: theme.colorScheme.onSurface,
              size: 24.0,
            ),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                }
              });
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16.0),

              // Account Section
              SettingsSectionWidget(
                title: 'ACCOUNT',
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 32.0,
                          backgroundColor: theme.colorScheme.primaryContainer,
                          child: Text(
                            _userInfo['name']!.substring(0, 1),
                            style: GoogleFonts.inter(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _userInfo['name']!,
                                style: GoogleFonts.inter(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 4.0),
                              Text(
                                _userInfo['email']!,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 4.0),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                  vertical: 2.0,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF00D4AA),
                                  borderRadius: BorderRadius.circular(4.0),
                                ),
                                child: Text(
                                  _userInfo['subscription']!,
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SettingsItemWidget(
                    iconName: 'edit',
                    title: 'Edit Profile',
                    subtitle: 'Update your personal information',
                    onTap: () {
                      Navigator.pushNamed(context, '/user-profile-screen');
                    },
                  ),
                ],
              ),

              // Theme Customization Section
              SettingsSectionWidget(
                title: 'APPEARANCE',
                children: [
                  ThemeSelectorWidget(
                    currentTheme: _selectedTheme,
                    onThemeChanged: (theme) {
                      setState(() => _selectedTheme = theme);
                    },
                  ),
                  const Divider(height: 1.0),
                  AccentColorPickerWidget(
                    currentColor: _accentColor,
                    onColorChanged: (color) {
                      setState(() => _accentColor = color);
                    },
                  ),
                ],
              ),

              // Language Settings
              SettingsSectionWidget(
                title: 'LANGUAGE & REGION',
                children: [
                  SettingsItemWidget(
                    iconName: 'language',
                    title: 'Language',
                    subtitle: _selectedLanguage,
                    onTap: _showLanguagePicker,
                    showDivider: false,
                  ),
                ],
              ),

              // Notification Preferences
              SettingsSectionWidget(
                title: 'NOTIFICATIONS',
                children: [
                  SettingsItemWidget(
                    iconName: 'message',
                    title: 'Messages',
                    subtitle: 'Receive notifications for new messages',
                    trailing: Switch(
                      value: _messagesNotifications,
                      onChanged: (value) {
                        setState(() => _messagesNotifications = value);
                      },
                    ),
                  ),
                  SettingsItemWidget(
                    iconName: 'call',
                    title: 'Calls',
                    subtitle: 'Receive notifications for incoming calls',
                    trailing: Switch(
                      value: _callsNotifications,
                      onChanged: (value) {
                        setState(() => _callsNotifications = value);
                      },
                    ),
                  ),
                  SettingsItemWidget(
                    iconName: 'notifications',
                    title: 'Social Updates',
                    subtitle: 'Receive notifications for social activity',
                    trailing: Switch(
                      value: _socialUpdatesNotifications,
                      onChanged: (value) {
                        setState(() => _socialUpdatesNotifications = value);
                      },
                    ),
                  ),
                  SettingsItemWidget(
                    iconName: 'info',
                    title: 'System Alerts',
                    subtitle: 'Receive important system notifications',
                    trailing: Switch(
                      value: _systemAlertsNotifications,
                      onChanged: (value) {
                        setState(() => _systemAlertsNotifications = value);
                      },
                    ),
                    showDivider: false,
                  ),
                ],
              ),

              // Privacy Section
              SettingsSectionWidget(
                title: 'PRIVACY & SECURITY',
                children: [
                  SettingsItemWidget(
                    iconName: 'lock',
                    title: 'Privacy Policy',
                    subtitle: 'View our privacy policy',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Opening privacy policy...',
                            style: GoogleFonts.inter(fontSize: 14),
                          ),
                        ),
                      );
                    },
                  ),
                  SettingsItemWidget(
                    iconName: 'share',
                    title: 'Data Sharing',
                    subtitle: 'Share usage data to improve the app',
                    trailing: Switch(
                      value: _dataSharing,
                      onChanged: (value) {
                        setState(() => _dataSharing = value);
                      },
                    ),
                  ),
                  SettingsItemWidget(
                    iconName: 'analytics',
                    title: 'Analytics',
                    subtitle: 'Help us improve with anonymous analytics',
                    trailing: Switch(
                      value: _analyticsEnabled,
                      onChanged: (value) {
                        setState(() => _analyticsEnabled = value);
                      },
                    ),
                  ),
                  SettingsItemWidget(
                    iconName: 'delete_forever',
                    title: 'Delete Account',
                    subtitle: 'Permanently delete your account and data',
                    onTap: _showDeleteAccountDialog,
                    showDivider: false,
                  ),
                ],
              ),

              // Device Management
              SettingsSectionWidget(
                title: 'CONNECTED DEVICES',
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: _connectedDevices.asMap().entries.map((entry) {
                        final index = entry.key;
                        final device = entry.value;
                        return DeviceCardWidget(
                          deviceName: device['name'] as String,
                          deviceType: device['type'] as String,
                          lastSync: device['lastSync'] as String,
                          isCurrentDevice: device['isCurrent'] as bool,
                          onLogout: device['isCurrent'] as bool
                              ? null
                              : () => _logoutDevice(index),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),

              // Storage Management
              SettingsSectionWidget(
                title: 'STORAGE',
                children: [
                  StorageUsageWidget(
                    storageData: _storageData,
                    totalStorage: _totalStorage,
                  ),
                  const Divider(height: 1.0),
                  SettingsItemWidget(
                    iconName: 'delete_sweep',
                    title: 'Clear Cache',
                    subtitle:
                        'Free up ${_storageData['Cache']?.toStringAsFixed(2)} GB',
                    onTap: _clearCache,
                  ),
                  SettingsItemWidget(
                    iconName: 'cloud_sync',
                    title: 'Cloud Sync',
                    subtitle: 'Manage cloud synchronization',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Cloud sync settings coming soon',
                            style: GoogleFonts.inter(fontSize: 14),
                          ),
                        ),
                      );
                    },
                    showDivider: false,
                  ),
                ],
              ),

              // Accessibility
              SettingsSectionWidget(
                title: 'ACCESSIBILITY',
                children: [
                  SettingsItemWidget(
                    iconName: 'text_fields',
                    title: 'Font Size',
                    subtitle: 'Adjust text size for better readability',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Font size adjustment coming soon',
                            style: GoogleFonts.inter(fontSize: 14),
                          ),
                        ),
                      );
                    },
                  ),
                  SettingsItemWidget(
                    iconName: 'contrast',
                    title: 'High Contrast',
                    subtitle: 'Increase contrast for better visibility',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'High contrast mode coming soon',
                            style: GoogleFonts.inter(fontSize: 14),
                          ),
                        ),
                      );
                    },
                    showDivider: false,
                  ),
                ],
              ),

              // About Section
              SettingsSectionWidget(
                title: 'ABOUT',
                children: [
                  SettingsItemWidget(
                    iconName: 'info',
                    title: 'App Version',
                    subtitle: '1.0.0 (Build 100)',
                  ),
                  SettingsItemWidget(
                    iconName: 'description',
                    title: 'Terms of Service',
                    subtitle: 'View terms and conditions',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Opening terms of service...',
                            style: GoogleFonts.inter(fontSize: 14),
                          ),
                        ),
                      );
                    },
                  ),
                  SettingsItemWidget(
                    iconName: 'support',
                    title: 'Support',
                    subtitle: 'Get help and contact support',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Opening support center...',
                            style: GoogleFonts.inter(fontSize: 14),
                          ),
                        ),
                      );
                    },
                  ),
                  SettingsItemWidget(
                    iconName: 'star',
                    title: 'Rate App',
                    subtitle: 'Share your feedback on the app store',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Opening app store...',
                            style: GoogleFonts.inter(fontSize: 14),
                          ),
                        ),
                      );
                    },
                    showDivider: false,
                  ),
                ],
              ),

              const SizedBox(height: 32.0),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Navigation item configuration for bottom bar
class CustomBottomBarItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final String route;

  const CustomBottomBarItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.route,
  });
}

/// Custom bottom navigation bar widget for Cloud OS application
/// Implements thumb-zone optimized navigation with platform-adaptive behavior
class CustomBottomBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<CustomBottomBarItem> items;

  const CustomBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    List<CustomBottomBarItem>? items,
  }) : items = items ?? _defaultItems;

  // Default navigation items based on Mobile Navigation Hierarchy
  static const List<CustomBottomBarItem> _defaultItems = [
    CustomBottomBarItem(
      label: 'Social',
      icon: Icons.explore_outlined,
      activeIcon: Icons.explore,
      route: '/social-hub',
    ),
    CustomBottomBarItem(
      label: 'Messages',
      icon: Icons.chat_bubble_outline,
      activeIcon: Icons.chat_bubble,
      route: '/messaging-interface',
    ),
    CustomBottomBarItem(
      label: 'Desktop',
      icon: Icons.apps_outlined,
      activeIcon: Icons.apps,
      route: '/app-launcher-desktop',
    ),
    CustomBottomBarItem(
      label: 'Profile',
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      route: '/user-profile-screen',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.1),
            blurRadius: 8.0,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64.0, // Optimized for thumb reach
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              items.length,
              (index) => _buildNavigationItem(
                context: context,
                item: items[index],
                index: index,
                isSelected: currentIndex == index,
                colorScheme: colorScheme,
                isDark: isDark,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationItem({
    required BuildContext context,
    required CustomBottomBarItem item,
    required int index,
    required bool isSelected,
    required ColorScheme colorScheme,
    required bool isDark,
  }) {
    final selectedColor = colorScheme.primary;
    final unselectedColor = colorScheme.onSurfaceVariant;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            onTap(index);
            // Haptic feedback for better UX
            // HapticFeedback.selectionClick(); // Uncomment if needed
          },
          splashColor: selectedColor.withValues(alpha: 0.1),
          highlightColor: selectedColor.withValues(alpha: 0.05),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon with scale animation
                AnimatedScale(
                  scale: isSelected ? 1.1 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  child: Icon(
                    isSelected ? item.activeIcon : item.icon,
                    size: 24.0,
                    color: isSelected ? selectedColor : unselectedColor,
                  ),
                ),
                const SizedBox(height: 4.0),
                // Label with fade animation
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  style: GoogleFonts.inter(
                    fontSize: 12.0,
                    fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                    color: isSelected ? selectedColor : unselectedColor,
                    letterSpacing: 0.5,
                  ),
                  child: Text(
                    item.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Active indicator
                if (isSelected)
                  Container(
                    margin: const EdgeInsets.only(top: 2.0),
                    height: 2.0,
                    width: 20.0,
                    decoration: BoxDecoration(
                      color: selectedColor,
                      borderRadius: BorderRadius.circular(1.0),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Variant of bottom bar with floating action button integration
class CustomBottomBarWithFAB extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final VoidCallback onFABPressed;
  final IconData fabIcon;
  final String fabTooltip;
  final List<CustomBottomBarItem> items;

  const CustomBottomBarWithFAB({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.onFABPressed,
    this.fabIcon = Icons.camera_alt,
    this.fabTooltip = 'Camera',
    List<CustomBottomBarItem>? items,
  }) : items = items ?? CustomBottomBar._defaultItems;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        // Bottom navigation bar with center gap
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.3)
                    : Colors.black.withValues(alpha: 0.1),
                blurRadius: 8.0,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 64.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // First two items
                  ...List.generate(
                    2,
                    (index) => _buildNavigationItem(
                      context: context,
                      item: items[index],
                      index: index,
                      isSelected: currentIndex == index,
                      colorScheme: colorScheme,
                      isDark: isDark,
                    ),
                  ),
                  // Center spacer for FAB
                  const Expanded(child: SizedBox()),
                  // Last two items
                  ...List.generate(
                    2,
                    (index) {
                      final itemIndex = index + 2;
                      return _buildNavigationItem(
                        context: context,
                        item: items[itemIndex],
                        index: itemIndex,
                        isSelected: currentIndex == itemIndex,
                        colorScheme: colorScheme,
                        isDark: isDark,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        // Floating Action Button
        Positioned(
          bottom: 20.0,
          child: FloatingActionButton(
            onPressed: onFABPressed,
            tooltip: fabTooltip,
            elevation: 4.0,
            child: Icon(fabIcon, size: 28.0),
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationItem({
    required BuildContext context,
    required CustomBottomBarItem item,
    required int index,
    required bool isSelected,
    required ColorScheme colorScheme,
    required bool isDark,
  }) {
    final selectedColor = colorScheme.primary;
    final unselectedColor = colorScheme.onSurfaceVariant;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onTap(index),
          splashColor: selectedColor.withValues(alpha: 0.1),
          highlightColor: selectedColor.withValues(alpha: 0.05),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedScale(
                  scale: isSelected ? 1.1 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  child: Icon(
                    isSelected ? item.activeIcon : item.icon,
                    size: 24.0,
                    color: isSelected ? selectedColor : unselectedColor,
                  ),
                ),
                const SizedBox(height: 4.0),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  style: GoogleFonts.inter(
                    fontSize: 12.0,
                    fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                    color: isSelected ? selectedColor : unselectedColor,
                    letterSpacing: 0.5,
                  ),
                  child: Text(
                    item.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isSelected)
                  Container(
                    margin: const EdgeInsets.only(top: 2.0),
                    height: 2.0,
                    width: 20.0,
                    decoration: BoxDecoration(
                      color: selectedColor,
                      borderRadius: BorderRadius.circular(1.0),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

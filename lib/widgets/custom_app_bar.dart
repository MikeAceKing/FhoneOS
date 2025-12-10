import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// App bar style variants
enum CustomAppBarStyle {
  standard,
  transparent,
  elevated,
  search,
}

/// Custom app bar widget for Cloud OS application
/// Implements platform-aware top navigation with contextual actions
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final CustomAppBarStyle style;
  final VoidCallback? onBackPressed;
  final double elevation;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool centerTitle;
  final PreferredSizeWidget? bottom;

  const CustomAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.style = CustomAppBarStyle.standard,
    this.onBackPressed,
    this.elevation = 2.0,
    this.backgroundColor,
    this.foregroundColor,
    this.centerTitle = false,
    this.bottom,
  });

  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight + (bottom?.preferredSize.height ?? 0.0),
      );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    // Determine colors based on style
    final effectiveBackgroundColor = _getBackgroundColor(
      colorScheme: colorScheme,
      isDark: isDark,
    );
    final effectiveForegroundColor = _getForegroundColor(
      colorScheme: colorScheme,
      isDark: isDark,
    );

    return AppBar(
      title: titleWidget ?? (title != null ? _buildTitle(context) : null),
      leading: leading ?? _buildLeading(context),
      automaticallyImplyLeading: automaticallyImplyLeading,
      actions: actions != null ? _buildActions(context) : null,
      backgroundColor: effectiveBackgroundColor,
      foregroundColor: effectiveForegroundColor,
      elevation: style == CustomAppBarStyle.transparent ? 0 : elevation,
      centerTitle: centerTitle,
      bottom: bottom,
      surfaceTintColor:
          style == CustomAppBarStyle.transparent ? Colors.transparent : null,
      shadowColor: isDark
          ? Colors.black.withValues(alpha: 0.3)
          : Colors.black.withValues(alpha: 0.1),
    );
  }

  Widget _buildTitle(BuildContext context) {
    final theme = Theme.of(context);

    return Text(
      title!,
      style: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
        color: foregroundColor ?? theme.colorScheme.onSurface,
      ),
    );
  }

  Widget? _buildLeading(BuildContext context) {
    if (!automaticallyImplyLeading) return null;

    final canPop = Navigator.of(context).canPop();
    if (!canPop) return null;

    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
      tooltip: 'Back',
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    return actions!.map((action) {
      if (action is IconButton) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: action,
        );
      }
      return action;
    }).toList();
  }

  Color _getBackgroundColor({
    required ColorScheme colorScheme,
    required bool isDark,
  }) {
    if (backgroundColor != null) return backgroundColor!;

    switch (style) {
      case CustomAppBarStyle.transparent:
        return Colors.transparent;
      case CustomAppBarStyle.elevated:
        return colorScheme.surface;
      case CustomAppBarStyle.standard:
      case CustomAppBarStyle.search:
      default:
        return colorScheme.surface;
    }
  }

  Color _getForegroundColor({
    required ColorScheme colorScheme,
    required bool isDark,
  }) {
    if (foregroundColor != null) return foregroundColor!;
    return colorScheme.onSurface;
  }
}

/// Search app bar variant with integrated search field
class CustomSearchAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String hintText;
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onSearchSubmitted;
  final TextEditingController? controller;
  final List<Widget>? actions;
  final bool autofocus;

  const CustomSearchAppBar({
    super.key,
    this.hintText = 'Search...',
    this.onSearchChanged,
    this.onSearchSubmitted,
    this.controller,
    this.actions,
    this.autofocus = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<CustomSearchAppBar> createState() => _CustomSearchAppBarState();
}

class _CustomSearchAppBarState extends State<CustomSearchAppBar> {
  late TextEditingController _controller;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _hasText = _controller.text.isNotEmpty;
    });
    widget.onSearchChanged?.call(_controller.text);
  }

  void _clearSearch() {
    _controller.clear();
    widget.onSearchChanged?.call('');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return AppBar(
      backgroundColor: colorScheme.surface,
      elevation: 2.0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(),
        tooltip: 'Back',
      ),
      title: Container(
        height: 40.0,
        decoration: BoxDecoration(
          color: isDark
              ? colorScheme.surfaceContainerHighest
              : colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: TextField(
          controller: _controller,
          autofocus: widget.autofocus,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: colorScheme.onSurfaceVariant,
            ),
            prefixIcon: Icon(
              Icons.search,
              color: colorScheme.onSurfaceVariant,
              size: 20.0,
            ),
            suffixIcon: _hasText
                ? IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: colorScheme.onSurfaceVariant,
                      size: 20.0,
                    ),
                    onPressed: _clearSearch,
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 10.0,
            ),
          ),
          onSubmitted: (_) => widget.onSearchSubmitted?.call(),
        ),
      ),
      actions: widget.actions,
    );
  }
}

/// App bar with profile avatar and notification badge
class CustomProfileAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final String? title;
  final String? profileImageUrl;
  final VoidCallback? onProfileTap;
  final VoidCallback? onNotificationTap;
  final int notificationCount;
  final List<Widget>? additionalActions;

  const CustomProfileAppBar({
    super.key,
    this.title,
    this.profileImageUrl,
    this.onProfileTap,
    this.onNotificationTap,
    this.notificationCount = 0,
    this.additionalActions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppBar(
      backgroundColor: colorScheme.surface,
      elevation: 2.0,
      title: title != null
          ? Text(
              title!,
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.15,
              ),
            )
          : null,
      actions: [
        if (additionalActions != null) ...additionalActions!,
        // Notification button with badge
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: onNotificationTap ??
                  () {
                    Navigator.pushNamed(context, '/notifications-screen');
                  },
              tooltip: 'Notifications',
            ),
            if (notificationCount > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4.0),
                  decoration: BoxDecoration(
                    color: colorScheme.error,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    notificationCount > 99 ? '99+' : '$notificationCount',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onError,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 8.0),
        // Profile avatar
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: GestureDetector(
            onTap: onProfileTap ??
                () {
                  Navigator.pushNamed(context, '/user-profile-screen');
                },
            child: CircleAvatar(
              radius: 18.0,
              backgroundColor: colorScheme.primaryContainer,
              backgroundImage: profileImageUrl != null
                  ? NetworkImage(profileImageUrl!)
                  : null,
              child: profileImageUrl == null
                  ? Icon(
                      Icons.person,
                      size: 20.0,
                      color: colorScheme.onPrimaryContainer,
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}

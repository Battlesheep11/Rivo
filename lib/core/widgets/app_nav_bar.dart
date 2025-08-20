import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:rivo_app_beta/core/localization/generated/app_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rivo_app_beta/core/presentation/providers/nav_bar_provider.dart';
import 'package:flutter/cupertino.dart';

class _NavItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;

  _NavItem({required this.label, required this.icon, required this.activeIcon});
}

/// A draggable, glass-style navigation bar with four buttons.
/// A draggable, glass-style navigation bar with four buttons, supporting animated
/// show/hide and respecting device safe area.
class AppNavBar extends ConsumerStatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const AppNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  ConsumerState<AppNavBar> createState() => _AppNavBarState();
}

class _AppNavBarState extends ConsumerState<AppNavBar> {


  void _handleTap(int index) {
    if (widget.currentIndex == index) return;
    widget.onTap(index);
  }

  List<_NavItem> get _navItems {
    final localizations = AppLocalizations.of(context)!;
    return [
      _NavItem(
        label: localizations.navBarHome, 
        icon: CupertinoIcons.collections, 
        activeIcon: CupertinoIcons.collections_solid
      ),
      _NavItem(
        label: localizations.navBarSearch, 
        icon: CupertinoIcons.news, 
        activeIcon: CupertinoIcons.news_solid
      ),
      _NavItem(
        label: localizations.navBarProfile, 
        icon: CupertinoIcons.person, 
        activeIcon: CupertinoIcons.person_fill
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isVisible = ref.watch(navBarVisibilityProvider);

    // Use SafeArea to avoid system UI overlap
    return Align(
      alignment: Alignment.bottomCenter,
      child: SafeArea(
        bottom: true,
        child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
          child: isVisible
              ? _buildNavBar(context, Theme.of(context), _navItems)
              : _buildMinimizedIcon(context),
        ),
      ),
    );
  }

  /// Builds the minimized floating icon
  Widget _buildMinimizedIcon(BuildContext context) {
    // Get the active tab's icon
    final activeIcon = _navItems[widget.currentIndex].activeIcon;
    
    return Align(
      alignment: Alignment.bottomLeft,
      child: Container(
        margin: const EdgeInsets.only(left: 16, bottom: 20),
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: Colors.white.withAlpha(200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(30),
              blurRadius: 10,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                color: Colors.white.withAlpha(180),
              ),
              child: Icon(
                activeIcon,
                color: const Color(0xFF0088FF),
                size: 28,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the main nav bar UI with glass effect and animated indicator
  Widget _buildNavBar(BuildContext context, ThemeData theme, List<_NavItem> navItems) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: Container(
          height: 54,
          width: 286,
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(180),
            borderRadius: BorderRadius.circular(100),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(20),
                blurRadius: 10,
                spreadRadius: 0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Selection highlight
              AnimatedPositioned(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                left: (widget.currentIndex * (286.0 / navItems.length)) + 4,
                width: (286.0 / navItems.length) - 8,
                top: 4,
                bottom: 4,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDEDED).withAlpha(200),
                    borderRadius: BorderRadius.circular(100),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(30),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
              // Navigation items
              Row(
                children: List.generate(
                  navItems.length,
                  (index) => _buildNavButton(
                    index,
                    navItems[index].label,
                    navItems[index].icon,
                    navItems[index].activeIcon,
                    theme,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  /// Builds a single navigation button with icon and label
  Widget _buildNavButton(int index, String label, IconData icon, IconData activeIcon, ThemeData theme) {
    final bool isActive = widget.currentIndex == index;
    // Ensure the tab bar items are in the correct order (left to right)
    final int displayIndex = widget.currentIndex;
    final bool isCorrectlyPositioned = index == displayIndex;
    final activeColor = const Color(0xFF0088FF);
    final inactiveColor = const Color(0xFF404040);

    return Expanded(
      child: GestureDetector(
        onTap: () => _handleTap(index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive ? activeColor : inactiveColor,
              size: isActive ? 24.0 : 22.0,
            ),
            const SizedBox(height: 1),
            Text(
              label,
              style: TextStyle(
                color: isActive ? activeColor : inactiveColor,
                fontSize: 10,
                height: 1.2,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                fontFamily: 'SF Pro', 
              ),
            ),
          ],
        ),
      ),
    );
  }
}

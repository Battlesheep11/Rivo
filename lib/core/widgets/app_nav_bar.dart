import 'package:flutter/material.dart';
import 'package:glass_kit/glass_kit.dart';
import 'package:rivo_app_beta/core/localization/generated/app_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rivo_app_beta/core/presentation/providers/nav_bar_provider.dart';

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
  bool _isHolding = false;
  double _dragPosition = 0.0;

  void _handleTap(int index) {
    if (widget.currentIndex == index) {
      setState(() {
        _isHolding = false;
      });
      return;
    }
    widget.onTap(index);
    setState(() {
      _isHolding = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Listen to navBarVisibilityProvider for minimized/expanded state
    final localizations = AppLocalizations.of(context)!;
    final navItems = [
      _NavItem(label: localizations.navBarHome, icon: Icons.home_outlined, activeIcon: Icons.home),
      _NavItem(label: localizations.navBarSearch, icon: Icons.search_outlined, activeIcon: Icons.search),

      _NavItem(label: localizations.navBarProfile, icon: Icons.person_outline, activeIcon: Icons.person),
    ];

    final isVisible = ref.watch(navBarVisibilityProvider);
    final theme = Theme.of(context);

    // Use SafeArea to avoid system UI overlap
    return SafeArea(
      bottom: true,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        child: isVisible
            ? _buildNavBar(context, theme, navItems)
            : _buildMinimizedIcon(context),
      ),
    );
  }

  /// Builds the minimized floating home icon
  Widget _buildMinimizedIcon(BuildContext context) {
    final theme = Theme.of(context);
    // Move minimized icon to bottom left
    return Align(
      alignment: Alignment.bottomLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 18.0),
        child: GestureDetector(
          onTap: () => ref.read(navBarVisibilityProvider.notifier).state = true,
          child: Material(
            color: Colors.transparent,
            elevation: 8,
            shape: const CircleBorder(),
            child: GlassContainer(
              height: 56,
              width: 56,
              borderRadius: BorderRadius.circular(28),
              blur: 25,
              borderWidth: 0,
              color: Colors.white.withAlpha(120),
              borderGradient: LinearGradient(
                colors: [Colors.white.withAlpha(60), Colors.white.withAlpha(20)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              child: Icon(
                Icons.home,
                color: theme.colorScheme.primary,
                size: 32,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the main nav bar UI with glass effect and animated indicator
  Widget _buildNavBar(BuildContext context, ThemeData theme, List<_NavItem> navItems) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final navBarWidth = constraints.maxWidth;
        final buttonWidth = navBarWidth / navItems.length;

        final double selectedPosition = widget.currentIndex * buttonWidth;

        final double indicatorPosition = _isHolding
            ? _dragPosition - (buttonWidth / 2)
            : selectedPosition;

        final clampedPosition = indicatorPosition.clamp(0.0, navBarWidth - buttonWidth);

        return GestureDetector(
          onHorizontalDragStart: (details) {
            setState(() {
              _isHolding = true;
              _dragPosition = details.localPosition.dx;
            });
          },
          onHorizontalDragUpdate: (details) {
            setState(() {
              _dragPosition = details.localPosition.dx;
            });
          },
          onHorizontalDragEnd: (details) {
            // Calculate the center position of each button
            double minDistance = double.infinity;
            int selectedIndex = widget.currentIndex; // Default to current index if no better match found
            
            for (int i = 0; i < navItems.length; i++) {
              // Calculate the center x-coordinate of this button
              final buttonCenter = (i * buttonWidth) + (buttonWidth / 2);
              // Calculate distance from touch position to button center
              final distance = (_dragPosition - buttonCenter).abs();
              
              // If this button is closer than any previous one, select it
              if (distance < minDistance) {
                minDistance = distance;
                selectedIndex = i;
              }
            }
            
            // Clamp the index to be safe (shouldn't be needed but good practice)
            selectedIndex = selectedIndex.clamp(0, navItems.length - 1);
            
            // Only trigger a change if we're selecting a different index
            if (selectedIndex != widget.currentIndex) {
              widget.onTap(selectedIndex);
            }
            
            // Reset the holding state
            setState(() {
              _isHolding = false;
            });
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              GlassContainer(
                height: 70,
                width: double.infinity,
                borderRadius: BorderRadius.circular(50),
                blur: 25,
                borderWidth: 0,
                color: Colors.white.withAlpha(75), // 30% opacity
                borderGradient: LinearGradient(
                  colors: [Colors.white.withAlpha(25), Colors.white.withAlpha(12)], // 10% and 5% opacity
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              AnimatedPositioned(
                duration: _isHolding ? Duration.zero : const Duration(milliseconds: 120),
                curve: Curves.easeOutQuad,
                left: clampedPosition,  // Always use left positioning
                width: buttonWidth,
                height: 70,
                child: Container(
                  margin: const EdgeInsets.all(5.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: Colors.white.withAlpha(50), // 20% opacity
                    border: Border.all(
                      color: Colors.white.withAlpha(75), // 30% opacity
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              Directionality(
                // Force LTR for the navigation items to maintain order
                textDirection: TextDirection.ltr,
                child: Row(
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
              ),
            ],
          ),
        );
      },
    );
  }


  /// Builds a single navigation button with icon and label
  Widget _buildNavButton(int index, String label, IconData icon, IconData activeIcon, ThemeData theme) {
    final bool isActive = widget.currentIndex == index;
    final activeColor = const Color(0xFF007AFF);
    final inactiveColor = theme.textTheme.bodyLarge?.color?.withAlpha((255 * 0.7).round()) ?? Colors.black54;

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
              size: isActive ? 28.0 : 22.0,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: isActive ? activeColor : inactiveColor,
                fontSize: isActive ? 12.0 : 10.0,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


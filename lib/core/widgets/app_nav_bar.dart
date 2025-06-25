import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class AppNavBar extends ConsumerWidget {
  final int currentIndex;
  final Function(int) onTap;

  const AppNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(
              context,
              index: 0,
              icon: Icons.home_outlined,
              activeIcon: Icons.home,
            ),
            _navItem(
              context,
              index: 1,
              icon: Icons.search,
              activeIcon: Icons.search,
            ),
            const SizedBox(width: 48), // Notch spacer for FAB
            _navItem(
              context,
              index: 3,
              icon: Icons.favorite_border,
              activeIcon: Icons.favorite,
            ),
            _navItem(
              context,
              index: 4,
              icon: Icons.person_outline,
              activeIcon: Icons.person,
            ),
          ],
        ),
      ),
    );
  }

  Widget _navItem(
    BuildContext context, {
    required int index,
    required IconData icon,
    required IconData activeIcon,
  }) {
    final isSelected = index == currentIndex;
    return IconButton(
      onPressed: () => onTap(index),
      icon: Icon(
        isSelected ? activeIcon : icon,
        color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey,
      ),
    );
  }
}

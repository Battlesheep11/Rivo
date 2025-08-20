import 'package:flutter/material.dart';
import 'dart:ui';

/// A circular glass-style action button with icon and optional count
class ActionGlassButton extends StatelessWidget {
  final IconData icon;
  final int? count;
  final Color? iconColor;
  final Color? backgroundColor;
  final bool isActive;
  final VoidCallback onPressed;
  
  const ActionGlassButton({
    super.key,
    required this.icon,
    this.count,
    this.iconColor,
    this.backgroundColor,
    this.isActive = false,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = const Color(0xFF0088FF);
    final defaultColor = const Color(0xFF404040);
    final currentIconColor = isActive ? activeColor : (iconColor ?? defaultColor);
    final currentBgColor = backgroundColor ?? Colors.white.withAlpha(180);

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 50,
        height: 50,
        margin: const EdgeInsets.only(bottom: 12),
        child: Stack(
          children: [
            // Background blur effect
            ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  decoration: BoxDecoration(
                    color: currentBgColor,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: Colors.white.withAlpha(120),
                      width: 1,
                    ),
                  ),
                ),
              ),
            ),
            
            // Icon and count
            Positioned.fill(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: currentIconColor, size: 24),
                  if (count != null && count! > 0) ...[
                    const SizedBox(height: 2),
                    Text(
                      _formatCount(count!),
                      style: TextStyle(
                        color: currentIconColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(0)}K';
    }
    return count.toString();
  }
}

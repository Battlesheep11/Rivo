import 'package:flutter/material.dart';
import 'dart:ui'; // For ImageFilter

/// A circular solid white action button with icon and optional count.
class ActionGlassButton extends StatelessWidget {
  final IconData icon;
  final int? count;
  final Color iconColor;
  final Color backgroundColor;
  final VoidCallback onPressed;
  
  const ActionGlassButton({
    super.key,
    required this.icon,
    this.count,
    this.iconColor = Colors.white,
    this.backgroundColor = Colors.white,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    // Reverted to a simpler button style to fix theming issues.
    // Re-introducing glass effect as requested.
    return GestureDetector(
      onTap: onPressed,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.0), // Half of width/height to make it circular
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              // Semi-transparent white for the glass effect
              color: Colors.white.withAlpha(51), // 0.2 * 255 ≈ 51 alpha value
              shape: BoxShape.circle,
            ),
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 24),
            if (icon != Icons.comment_bank_outlined && (count ?? 0) > 0)
              Padding(
                padding: const EdgeInsets.only(top: 2.0),
                child: Text(
                  _formatCount(count!),
                  style: TextStyle(
                    color: iconColor.withAlpha(51), // 80% opacity of the original color
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ), // Close Column
          ), // Close Container
        ), // Close BackdropFilter
      ), // Close ClipRRect
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }
}

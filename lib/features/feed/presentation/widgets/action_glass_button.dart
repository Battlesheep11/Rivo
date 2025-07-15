import 'package:flutter/material.dart';

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
    this.iconColor = Colors.black87,
    this.backgroundColor = Colors.white,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 48,
        width: 48,
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((255 * 0.1).round()),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
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
                    color: iconColor.withAlpha((255 * 0.8).round()),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
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
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }
}

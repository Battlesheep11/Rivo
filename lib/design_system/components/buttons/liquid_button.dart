import 'package:flutter/material.dart';

class LiquidButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final List<Color>? gradientColors;

  const LiquidButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.borderRadius = 24.0,
    this.padding = const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
    this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    final colors = gradientColors ??
        [
          const Color(0xFF6EE7B7),
          const Color(0xFF3B82F6),
        ];

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(borderRadius),
      child: Ink(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: colors.last.withAlpha((0.4 * 255).round()),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: padding,
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

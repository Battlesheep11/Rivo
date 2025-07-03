import 'package:flutter/material.dart';



enum AppButtonVariant {
  primary,
  secondary,
  outline,
  overlay, 
}
Color _getBackgroundColor(AppButtonVariant variant) {
  switch (variant) {
    case AppButtonVariant.primary:
      return Colors.black;
    case AppButtonVariant.secondary:
      return Colors.grey.shade200;
    case AppButtonVariant.outline:
      return Colors.transparent;
    case AppButtonVariant.overlay:
      return Colors.white.withAlpha((0.15 * 255).round()); 
  }
}

Color _getTextColor(AppButtonVariant variant) {
  switch (variant) {
    case AppButtonVariant.primary:
      return Colors.white;
    case AppButtonVariant.secondary:
      return Colors.black;
    case AppButtonVariant.outline:
      return Colors.black;
    case AppButtonVariant.overlay:
      return Colors.white; 
  }
}

class AppButton extends StatelessWidget {
  final String? label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isDisabled;
  final Widget? child;

  const AppButton({
    super.key,
    this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isDisabled = false,
    this.child,
  }) : assert(label != null || child != null, 'Either label or child must be provided');

  @override
  Widget build(BuildContext context) {
    final bgColor = _getBackgroundColor(variant);
    final textColor = _getTextColor(variant);


    return ElevatedButton(
      onPressed: isDisabled ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        foregroundColor: textColor,
        disabledBackgroundColor: bgColor.withAlpha((0.5 * 255).round()),
        disabledForegroundColor: textColor.withAlpha((0.5 * 255).round()),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        side: variant == AppButtonVariant.outline
            ? const BorderSide(color: Colors.black12)
            : BorderSide.none,
      ),
      child: child ?? Text(label!),
    );
  }
}

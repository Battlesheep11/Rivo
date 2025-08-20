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
  final String? text; // backward-compat alias
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isDisabled;
  final bool isLoading; // backward-compat optional
  final Widget? child;

  const AppButton({
    super.key,
    this.label,
    this.text,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isDisabled = false,
    this.isLoading = false,
    this.child,
  }) : assert(label != null || text != null || child != null, 'Provide label/text or child');

  @override
  Widget build(BuildContext context) {
    final bgColor = _getBackgroundColor(variant);
    final textColor = _getTextColor(variant);
    final effectiveLabel = label ?? text; // prefer label, else alias
    final disabled = isDisabled || isLoading;

    return ElevatedButton(
      onPressed: disabled ? null : onPressed,
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
      child: child ??
          (isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : Text(effectiveLabel!)),
    );
  }
}

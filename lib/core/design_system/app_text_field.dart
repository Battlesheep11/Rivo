import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final String? errorText;
  final TextInputType? keyboardType;
  final int? maxLines;
  final int? minLines; // for multiline sizing control
  final int? maxLength;
  final ValueChanged<String>? onChanged;

  const AppTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.obscureText = false,
    this.errorText,
    this.keyboardType,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Slightly reduce bottom padding for multiline fields so the maxLength counter
    // has enough space and avoids tiny pixel overflows on some devices.
    final bool isMultiline = (maxLines ?? 1) > 1;
    final EdgeInsets contentPadding = isMultiline
        ? const EdgeInsets.fromLTRB(16, 12, 16, 8)
        : const EdgeInsets.symmetric(horizontal: 16, vertical: 12);

    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      maxLines: maxLines,
      minLines: minLines,
      maxLength: maxLength,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
        errorText: errorText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: contentPadding,
      ),
    );
  }
}

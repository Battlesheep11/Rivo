import 'package:flutter/material.dart';

class LoadingOverlayController {
  static final LoadingOverlayController _instance = LoadingOverlayController._internal();

  factory LoadingOverlayController() => _instance;

  LoadingOverlayController._internal();

  OverlayEntry? _overlayEntry;

  void show(BuildContext context) {
    if (_overlayEntry != null) return;

    _overlayEntry = OverlayEntry(
      builder: (context) => Container(
        color: Colors.black.withAlpha((0.3 * 255).round()),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );

    Overlay.of(context, rootOverlay: true).insert(_overlayEntry!);
  }

  void hide() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}

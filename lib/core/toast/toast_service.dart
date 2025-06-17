import 'package:flutter/material.dart';

class ToastService {
  static final ToastService _instance = ToastService._internal();

  factory ToastService() => _instance;

  ToastService._internal();

  late GlobalKey<ScaffoldMessengerState> messengerKey;

  void init(GlobalKey<ScaffoldMessengerState> key) {
    messengerKey = key;
  }

  void showSuccess(String message) {
    _show(message, Colors.green);
  }

  void showError(String message) {
    _show(message, Colors.red);
  }

  void showInfo(String message) {
    _show(message, Colors.blue);
  }

  void _show(String message, Color color) {
    messengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

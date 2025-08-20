import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Riverpod provider that exposes current connectivity status (true = online, false = offline)
/// and updates reactively when connectivity changes.
final connectivityStatusProvider =
    StateNotifierProvider.autoDispose<ConnectivityController, bool>((ref) {
  final controller = ConnectivityController();
  // Ensure resources are cleaned up
  ref.onDispose(controller.dispose);
  return controller;
});

class ConnectivityController extends StateNotifier<bool> {
  ConnectivityController() : super(true) {
    _init();
  }

  StreamSubscription<List<ConnectivityResult>>? _subscription;

  Future<void> _init() async {
    // Initial check
    final initial = await Connectivity().checkConnectivity();
    state = _isOnline(initial);

    // Subscribe to ongoing changes
    _subscription = Connectivity().onConnectivityChanged.listen((results) {
      state = _isOnline(results);
    });
  }

  /// Manual retry trigger – useful for a Retry button.
  Future<void> retryCheck() async {
    final results = await Connectivity().checkConnectivity();
    state = _isOnline(results);
  }

  bool _isOnline(List<ConnectivityResult> results) {
    // connectivity_plus v6 returns a list; online if any result is not 'none'.
    return results.any((r) => r != ConnectivityResult.none);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

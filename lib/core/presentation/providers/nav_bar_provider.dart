import 'package:flutter_riverpod/flutter_riverpod.dart';

/// This provider holds the boolean state for the navigation bar's visibility.
///
/// Widgets can watch this provider to react to changes in visibility.
final navBarVisibilityProvider = StateProvider<bool>((ref) => true);

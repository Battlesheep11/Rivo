import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'loading_overlay_controller.dart';

final loadingOverlayProvider = Provider<LoadingOverlayController>((ref) {
  return LoadingOverlayController();
});

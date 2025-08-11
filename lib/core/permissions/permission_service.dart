import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  /// Ask for camera (and mic if you’re about to record video).
  /// Returns true if all required permissions are granted.
  Future<bool> requestCamera({bool includeMic = false}) async {
    final cam = await Permission.camera.request();
    if (!cam.isGranted) return false;

    if (includeMic) {
      final mic = await Permission.microphone.request();
      if (!mic.isGranted) return false;
    }
    return true;
  }

  /// Returns true when user chose “Don’t ask again” (iOS: denied twice / restricted).
  Future<bool> isPermanentlyDenied({bool includeMic = false}) async {
    final cam = await Permission.camera.status;
    final mic = includeMic ? await Permission.microphone.status : null;
    final camLocked = cam.isPermanentlyDenied || cam.isRestricted;
    final micLocked = includeMic ? (mic!.isPermanentlyDenied || mic.isRestricted) : false;
    return camLocked || micLocked;
  }

  Future<bool> openAppSettingsNow() => openAppSettings();
}

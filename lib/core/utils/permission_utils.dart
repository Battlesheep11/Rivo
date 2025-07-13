import 'package:permission_handler/permission_handler.dart';

class PermissionUtils {
  static Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return _handleStatus(status);
  }

  static Future<bool> requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    return _handleStatus(status);
  }

  static Future<bool> requestPhotoLibraryPermission() async {
    final status = await Permission.photos.request(); // iOS
    return _handleStatus(status);
  }

  static Future<bool> requestStoragePermission() async {
    final status = await Permission.storage.request(); // Android < 13
    return _handleStatus(status);
  }

  static Future<bool> _handleStatus(PermissionStatus status) async {
    if (status.isGranted) return true;

    if (status.isPermanentlyDenied) {
      // פתח את ההגדרות כדי לאפשר הרשאה מחדש
      await openAppSettings();
    }

    return false;
  }
}

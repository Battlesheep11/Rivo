import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io'; // נדרש בשביל Platform
import 'package:flutter/foundation.dart'; // נדרש בשביל debugPrint


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

  static Future<bool> requestPhotoManagerPermission() async {
    final permission = await PhotoManager.requestPermissionExtend();

    if (permission.isAuth || permission == PermissionState.limited) {
      return true;
    }

    await PhotoManager.openSetting();
    return false;
  }

static Future<bool> requestMediaAccessPermission() async {
  final androidInfo = await DeviceInfoPlugin().androidInfo;
  bool granted = true;

  if (Platform.isAndroid) {
    final sdkInt = androidInfo.version.sdkInt;

    if (sdkInt >= 33) {
      final images = await Permission.photos.request();
      final videos = await Permission.videos.request();
      granted &= images.isGranted && videos.isGranted;
    } else {
      final storage = await Permission.storage.request();
      granted &= storage.isGranted;
    }

    final photoManager = await PhotoManager.requestPermissionExtend();
    granted &= photoManager.isAuth || photoManager == PermissionState.limited;
  } else {
    final photos = await Permission.photos.request(); // iOS
    granted &= photos.isGranted;
  }

  debugPrint("📷 Permissions granted? $granted");
  return granted;
}



}

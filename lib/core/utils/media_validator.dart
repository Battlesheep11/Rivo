// media_validator.dart

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:mime/mime.dart';
import 'package:rivo_app_beta/core/constants/media_constraints.dart';
import 'package:result_dart/result_dart.dart';
import 'package:rivo_app_beta/core/media/domain/entities/uploadable_media.dart'; // בשביל MediaType

enum MediaValidationError {
  unsupportedFormat,
  fileTooLarge, // נשתמש בזה רק לתמונות בשלב הזה
  fileNotFound,
}

class MediaValidator {
  /// אם אין סיומת/‏MIME (נפוץ במדיה שצולמה עכשיו) – נשתמש ב-type כ-fallback.
  static Result<String, MediaValidationError> validateSource(
    File file, {
    MediaType? type,
  }) {
    if (!file.existsSync()) {
      debugPrint('❌ Validation failed: File not found: ${file.path}');
      return Failure(MediaValidationError.fileNotFound);
    }

    String? mimeType = lookupMimeType(file.path);

    // fallback לפי ה-type מהשכבה הדומיינית (כשאין סיומת/‏MIME)
    mimeType ??= (type == MediaType.video ? 'video/mp4' : 'image/jpeg');

    final isImage = MediaConstraints.supportedImageFormats.contains(mimeType);
    final isVideo = MediaConstraints.supportedVideoFormats.contains(mimeType);

    if (!isImage && !isVideo) {
      debugPrint('❌ Validation failed: Unsupported format: $mimeType');
      return Failure(MediaValidationError.unsupportedFormat);
    }

    final fileSize = file.lengthSync();
    debugPrint('📦 Source file size: $fileSize bytes | Type: $mimeType');

    // תמונות מוגבלות בשלב הזה; וידאו נבדוק אחרי דחיסה (אם תרצה).
    if (isImage && fileSize > MediaConstraints.maxImageSizeInBytes) {
      debugPrint('❌ Image too large ($fileSize > ${MediaConstraints.maxImageSizeInBytes})');
      return Failure(MediaValidationError.fileTooLarge);
    }

    debugPrint('✅ Source validation passed: $mimeType');
    return Success("valid");
  }
}

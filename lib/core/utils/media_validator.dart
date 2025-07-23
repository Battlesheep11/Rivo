import 'dart:io';
import 'package:flutter/foundation.dart'; // ← נדרש בשביל debugPrint
import 'package:mime/mime.dart';
import 'package:rivo_app_beta/core/constants/media_constraints.dart';
import 'package:result_dart/result_dart.dart';

enum MediaValidationError {
  unsupportedFormat,
  fileTooLarge,
  fileNotFound,
}

class MediaValidator {
  static Result<String, MediaValidationError> validate(File file) {
    if (!file.existsSync()) {
      debugPrint('❌ Validation failed: File not found: ${file.path}');
      return Failure(MediaValidationError.fileNotFound);
    }

    final mimeType = lookupMimeType(file.path);
    if (mimeType == null) {
      debugPrint('❌ Validation failed: Unknown MIME type for ${file.path}');
      return Failure(MediaValidationError.unsupportedFormat);
    }

    final isImage = MediaConstraints.supportedImageFormats.contains(mimeType);
    final isVideo = MediaConstraints.supportedVideoFormats.contains(mimeType);

    if (!isImage && !isVideo) {
      debugPrint('❌ Validation failed: Unsupported format: $mimeType');
      return Failure(MediaValidationError.unsupportedFormat);
    }

    final fileSize = file.lengthSync();
    debugPrint('📦 File size: $fileSize bytes | Type: $mimeType');

    if (isImage && fileSize > MediaConstraints.maxImageSizeInBytes) {
      debugPrint('❌ Validation failed: Image too large ($fileSize > ${MediaConstraints.maxImageSizeInBytes})');
      return Failure(MediaValidationError.fileTooLarge);
    }
    if (isVideo && fileSize > MediaConstraints.maxVideoSizeInBytes) {
      debugPrint('❌ Validation failed: Video too large ($fileSize > ${MediaConstraints.maxVideoSizeInBytes})');
      return Failure(MediaValidationError.fileTooLarge);
    }

    debugPrint('✅ Validation passed: $mimeType');
    return Success("valid");
  }
}

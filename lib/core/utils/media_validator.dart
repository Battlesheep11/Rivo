import 'dart:io';
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
      return Failure(MediaValidationError.fileNotFound);
    }

    final mimeType = lookupMimeType(file.path);
    if (mimeType == null) {
      return Failure(MediaValidationError.unsupportedFormat);
    }

    final isImage = MediaConstraints.supportedImageFormats.contains(mimeType);
    final isVideo = MediaConstraints.supportedVideoFormats.contains(mimeType);

    if (!isImage && !isVideo) {
      return Failure(MediaValidationError.unsupportedFormat);
    }

    final fileSize = file.lengthSync();
    if (isImage && fileSize > MediaConstraints.maxImageSizeInBytes) {
      return Failure(MediaValidationError.fileTooLarge);
    }
    if (isVideo && fileSize > MediaConstraints.maxVideoSizeInBytes) {
      return Failure(MediaValidationError.fileTooLarge);
    }

    return Success("valid"); 
  }
}

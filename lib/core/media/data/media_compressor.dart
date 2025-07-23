import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:result_dart/result_dart.dart';
import 'package:video_compress/video_compress.dart';
import 'package:rivo_app_beta/core/error_handling/app_exception.dart'; 

class MediaCompressor {
  /// Compress image file using flutter_image_compress.
  static Future<Result<File, AppException>> compressImageFile(File file, {int quality = 80}) async {
    try {
      final ext = file.path.split('.').last.toLowerCase();
      final tempDir = await getTemporaryDirectory();
      final targetPath = '${tempDir.path}/${const Uuid().v4()}.$ext';

      final compressedBytes = await FlutterImageCompress.compressWithFile(
        file.absolute.path,
        quality: quality,
        format: _getFormat(ext),
      );

      if (compressedBytes == null) {
        return Failure(AppException.unexpected("Image compression failed"));
      }

      final result = await File(targetPath).writeAsBytes(compressedBytes, flush: true);
      return Success(result);
    } catch (e, stack) {
      return Failure(AppException.unexpected("Image compression error", stackTrace: stack));
    }
  }

  /// Compress video file using video_compress.
  static Future<Result<File, AppException>> compressVideoFile(File file) async {
    try {
      VideoCompress.setLogLevel(0); // Disable logs

      final info = await VideoCompress.compressVideo(
        file.path,
        quality: VideoQuality.MediumQuality,
        deleteOrigin: false,
        includeAudio: true,
      );

      if (info == null || info.file == null) {
        return Failure(AppException.unexpected("Video compression failed"));
      }

      final tempDir = await getTemporaryDirectory();
      final targetPath = '${tempDir.path}/${const Uuid().v4()}.mp4';

      final compressedFile = await info.file!.copy(targetPath);
      await info.file!.delete();

      return Success(compressedFile);
    } catch (e, stack) {
      return Failure(AppException.unexpected("Video compression error", stackTrace: stack));
    } finally {
      VideoCompress.dispose();
    }
  }

  static CompressFormat _getFormat(String ext) {
    switch (ext) {
      case 'png':
        return CompressFormat.png;
      case 'webp':
        return CompressFormat.webp;
      default:
        return CompressFormat.jpeg;
    }
  }

  static void disposeVideoCompressor() {
    VideoCompress.dispose();
  }
}

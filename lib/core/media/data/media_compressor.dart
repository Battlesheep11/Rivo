import 'dart:io';
import 'dart:math' as math;
import 'dart:developer' as developer;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:result_dart/result_dart.dart';
import 'package:video_compress/video_compress.dart';
import 'package:rivo_app_beta/core/error_handling/app_exception.dart';

class MediaCompressor {
  /// Compress image file using flutter_image_compress.
  static Future<Result<File, AppException>> compressImageFile(
    File file, {
    int quality = 88, // ⬆️ middle-ground for images
  }) async {
    try {
      final ext = file.path.split('.').last.toLowerCase();
      final tempDir = await getTemporaryDirectory();
      final targetPath = '${tempDir.path}/${const Uuid().v4()}.$ext';

      final originalSize = await file.length();
      developer.log('🖼️ Starting image compression - Original size: ${_formatBytes(originalSize)}');
      developer.log('📁 Original path: ${file.path}');

      final stopwatch = Stopwatch()..start();
      final compressedBytes = await FlutterImageCompress.compressWithFile(
        file.absolute.path,
        quality: quality,
        format: _getFormat(ext),
      );
      stopwatch.stop();

      if (compressedBytes == null) {
        developer.log('❌ Image compression failed - no output');
        return Failure(AppException.unexpected("Image compression failed"));
      }

      final result = await File(targetPath).writeAsBytes(compressedBytes, flush: true);
      final compressedSize = await result.length();

      developer.log('✅ Image compression completed in ${stopwatch.elapsedMilliseconds}ms');
      developer.log('📊 Compression ratio: ${(compressedSize / originalSize * 100).toStringAsFixed(2)}%');
      developer.log('📦 Original: ${_formatBytes(originalSize)} → Compressed: ${_formatBytes(compressedSize)}');
      developer.log('💾 Saved to: $targetPath\n');

      return Success(result);
    } catch (e, stack) {
      developer.log('❌ Image compression error: $e\n$stack');
      return Failure(AppException.unexpected("Image compression error", stackTrace: stack));
    }
  }

  /// Compress video file using video_compress.
  /// Middle-ground presets:
  ///   0–60MB   → MediumQuality
  ///   60MB+    → DefaultQuality  (שמירה טובה יותר על פרטים)
  /// מחזיר תמיד MP4 אם הצליח, ואם יצא גדול יותר – חוזר למקור.
  static Future<Result<File, AppException>> compressVideoFile(File file) async {
    try {
      VideoCompress.setLogLevel(0);

      final originalSize = await file.length();
      developer.log('🎥 Starting video compression - Original size: ${_formatBytes(originalSize)}');
      developer.log('📁 Original path: ${file.path}');

      final VideoQuality preset =
          (originalSize <= 60 * 1024 * 1024) ? VideoQuality.MediumQuality : VideoQuality.DefaultQuality;

      final stopwatch = Stopwatch()..start();
      final info = await VideoCompress.compressVideo(
        file.path,
        quality: preset,
        deleteOrigin: false,
        includeAudio: true,
      );
      stopwatch.stop();

      if (info == null || info.file == null) {
        developer.log('❌ Video compression failed - no output');
        return Failure(AppException.unexpected("Video compression failed"));
      }

      final tempDir = await getTemporaryDirectory();
      final targetPath = '${tempDir.path}/${const Uuid().v4()}.mp4';
      final compressedFile = await info.file!.copy(targetPath);
      final compressedSize = await compressedFile.length();

      try { await info.file!.delete(); } catch (_) {}

      developer.log('✅ Video compression completed in ${stopwatch.elapsedMilliseconds}ms');
      developer.log('📊 Compression ratio: ${(compressedSize / originalSize * 100).toStringAsFixed(2)}%');
      developer.log('📦 Original: ${_formatBytes(originalSize)} → Compressed: ${_formatBytes(compressedSize)}');
      developer.log('💾 Saved to: $targetPath\n');

      if (compressedSize >= originalSize) {
        return Success(file);
      }

      return Success(compressedFile);
    } catch (e, stack) {
      developer.log('❌ Video compression error: $e\n$stack');
      return Failure(AppException.unexpected("Video compression error", stackTrace: stack));
    } finally {
      VideoCompress.dispose();
    }
  }

  // --- helpers ---

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

  static String _formatBytes(int bytes, {int decimals = 2}) {
    if (bytes <= 0) return '0 B';
    const k = 1024;
    const sizes = ['B', 'KB', 'MB', 'GB'];
    final i = (math.log(bytes) / math.log(k)).floor();
    return '${(bytes / math.pow(k, i)).toStringAsFixed(decimals)} ${sizes[i]}';
  }

  static void disposeVideoCompressor() {
    VideoCompress.dispose();
  }
}

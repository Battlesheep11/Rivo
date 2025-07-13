import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:video_compress/video_compress.dart';

class VideoUtils {
  static Future<Uint8List> compressVideo(Uint8List originalBytes) async {
    VideoCompress.setLogLevel(0); // Disable logs

    final tempDir = await getTemporaryDirectory();
    final inputFile = File('${tempDir.path}/input.mp4');
    await inputFile.writeAsBytes(originalBytes);

    try {
      final info = await VideoCompress.compressVideo(
        inputFile.path,
        quality: VideoQuality.MediumQuality,
        deleteOrigin: false,
        includeAudio: true,
      );

      if (info == null || info.file == null) {
        throw Exception('Video compression failed.');
      }

      final resultBytes = await info.file!.readAsBytes();

      // Cleanup
      await inputFile.delete();
      await info.file!.delete();

      return resultBytes;
    } finally {
      VideoCompress.dispose();
    }
  }
}

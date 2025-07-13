import 'dart:io';
import 'dart:typed_data';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:path_provider/path_provider.dart';

class VideoUtils {
  static Future<Uint8List> convertToWebm(Uint8List originalBytes) async {
    final tempDir = await getTemporaryDirectory();

    final inputFile = File('${tempDir.path}/input.mp4');
    final outputFile = File('${tempDir.path}/output.webm');

    await inputFile.writeAsBytes(originalBytes);

    final session = await FFmpegKit.execute(
      '-i "${inputFile.path}" -c:v libvpx-vp9 -b:v 1M -c:a libopus "${outputFile.path}"',
    );

    final returnCode = await session.getReturnCode();

    if (returnCode == null || !returnCode.isValueSuccess()) {
      throw Exception('Video conversion to WEBM failed.');
    }

    final convertedBytes = await outputFile.readAsBytes();

    await inputFile.delete();
    await outputFile.delete();

    return convertedBytes;
  }
}

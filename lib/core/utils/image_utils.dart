import 'dart:typed_data';
import 'package:image/image.dart' as img;

class ImageUtils {
  static Future<Uint8List> compressImage(Uint8List originalBytes) async {
    final decoded = img.decodeImage(originalBytes);
    if (decoded == null) return originalBytes;

    final resized = img.copyResize(
      decoded,
      width: decoded.width > 1080 ? 1080 : decoded.width,
    );

    final compressed = img.encodeJpg(resized, quality: 75);

    return Uint8List.fromList(compressed);
  }
}

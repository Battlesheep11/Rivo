import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';

class TempFileUtils {
  static Future<File> saveBytesAsTempFile(Uint8List bytes, String extension) async {
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.$extension');
    return file.writeAsBytes(bytes, flush: true);
  }
}

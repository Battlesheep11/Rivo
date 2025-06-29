import 'dart:typed_data';
import 'package:photo_manager/photo_manager.dart';

class MediaFile {
  final String? id;
  final String? url;
  final String? type; // 'image' or 'video'
  final int? sortOrder;
  final AssetEntity asset;
  final Uint8List bytes;

  MediaFile({
    required this.asset,
    required this.bytes,
    this.id,
    this.url,
    this.type,
    this.sortOrder,
  });

  factory MediaFile.fromAsset(AssetEntity asset, Uint8List bytes) {
    return MediaFile(
      asset: asset,
      bytes: bytes,
      id: asset.id,
      type: asset.type.toString().split('.').last,
      url: '', // יתעדכן לאחר העלאה ל־Storage
    );
  }
}

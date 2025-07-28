import 'dart:io';
import 'package:photo_manager/photo_manager.dart';
import 'package:equatable/equatable.dart';
import 'dart:typed_data';


enum MediaType { image, video }

enum UploadMediaStatus {
  initial,
  validating,
  valid,
  compressing,
  compressed,
  uploading,
  uploaded,
  failed,
  invalid,
}

class UploadableMedia extends Equatable {
  final String id;
  final AssetEntity asset;
  final File? file;
  final Uint8List? bytes;
  final MediaType type;
  final UploadMediaStatus status;
  final String? uploadedUrl;
  final int? sortOrder;
  final String? errorMessage;

  const UploadableMedia({
    required this.id,
    required this.asset,
    required this.type,
    this.file,
    this.bytes,
    this.status = UploadMediaStatus.initial,
    this.uploadedUrl,
    this.sortOrder,
    this.errorMessage,
  });

  UploadableMedia copyWith({
    File? file,
    Uint8List? bytes,
    UploadMediaStatus? status,
    String? uploadedUrl,
    int? sortOrder,
    String? errorMessage,
  }) {
    return UploadableMedia(
      id: id,
      asset: asset,
      type: type,
      file: file ?? this.file,
      bytes: bytes ?? this.bytes,
      status: status ?? this.status,
      uploadedUrl: uploadedUrl ?? this.uploadedUrl,
      sortOrder: sortOrder ?? this.sortOrder,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  /// Used as unique identifier for UI (e.g. for progress tracking)
  String get path => asset.id;

  @override
  List<Object?> get props => [id, type, status, uploadedUrl, sortOrder, errorMessage, file, bytes];
}

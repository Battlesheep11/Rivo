import 'dart:io';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:rivo_app_beta/features/post/domain/entities/media_file.dart';

part 'uploadable_media.freezed.dart';

enum UploadMediaStatus {
  initial,
  valid,
  invalid,
  uploading,
  uploaded,
  failed,
}

@freezed
class UploadableMedia with _$UploadableMedia {
  const factory UploadableMedia({
    required MediaFile media,
    required UploadMediaStatus status,
    File? file, //direct access to file
    String? errorMessage,
  }) = _UploadableMedia;
}

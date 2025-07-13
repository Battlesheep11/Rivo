import 'package:freezed_annotation/freezed_annotation.dart';
import 'media_file.dart';
import 'tag_entity.dart';

part 'upload_post_payload.freezed.dart';

@freezed
class UploadPostPayload with _$UploadPostPayload {
  const factory UploadPostPayload({
    required bool hasProduct,
    String? productTitle,
    String? productDescription,
    double? productPrice,
    String? categoryId,
    double? chest,
    double? waist,
    double? length,
    String? caption,
    required List<MediaFile> media,
    required List<TagEntity> tags,
  }) = _UploadPostPayload;
}

extension UploadPostPayloadX on UploadPostPayload {
  bool get isValid =>
      media.isNotEmpty &&
      (hasProduct
          ? productTitle != null &&
              productPrice != null &&
              categoryId != null
          : true);
}

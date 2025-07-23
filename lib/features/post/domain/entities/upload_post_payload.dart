import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:rivo_app_beta/core/media/domain/entities/uploadable_media.dart';
import 'package:rivo_app_beta/features/post/domain/entities/tag_entity.dart';

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
    required List<UploadableMedia> media,
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

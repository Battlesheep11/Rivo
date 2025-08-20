import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:rivo_app_beta/core/media/domain/entities/uploadable_media.dart';
import 'package:rivo_app_beta/features/post/domain/entities/tag_entity.dart';

part 'upload_post_payload.freezed.dart';

@freezed
class UploadPostPayload with _$UploadPostPayload {
  const factory UploadPostPayload({
    // Controls if we create a product or just a post
    required bool hasProduct,

    // --- Product basics ---
    String? productTitle,
    String? productDescription,
    double? productPrice,
    String? categoryId,

    // --- Measurements ---
    double? chest,
    double? waist,
    double? length,
    double? sleeveLength,     
    double? shoulderWidth,     

    // --- Brand / Size ---
    String? brand,
    String? size,

    // --- Legacy display strings (kept so UI doesn’t break) ---
    String? material,
    String? condition,

    // --- Schema-aligned codes (persist these) ---
    String? conditionCode,             // 'never_worn' | 'as_new' | 'good' | 'fair'
    List<String>? defectCodes,         // product_defects.defect_code
    List<String>? materialCodes,       // product_materials.material_code
    List<String>? colorCodes,          // product_colors.color_code
    required String statusCode,
    String? otherMaterial,
    String? otherDefectNote,


    // --- Post ---
    String? caption,

    // --- Media & Tags ---
    required List<UploadableMedia> media,
    required List<TagEntity> tags,
  }) = _UploadPostPayload;
}

extension UploadPostPayloadX on UploadPostPayload {
  /// Minimal client-side validation. (Deeper rules live in ViewModel)
  bool get isValid {
    final hasBasicProduct =
        !hasProduct ||
        (productTitle != null &&
         productTitle!.trim().isNotEmpty &&
         productPrice != null &&
         (productPrice ?? 0) > 1 &&
         categoryId != null && categoryId!.trim().isNotEmpty);

    return media.isNotEmpty && hasBasicProduct;
  }
}

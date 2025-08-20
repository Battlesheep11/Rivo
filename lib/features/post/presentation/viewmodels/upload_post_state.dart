import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:rivo_app_beta/core/media/domain/entities/uploadable_media.dart';
import 'package:rivo_app_beta/features/post/presentation/viewmodels/form_status.dart';

part 'upload_post_state.freezed.dart';

@freezed
class UploadPostState with _$UploadPostState {
  const UploadPostState._();

  const factory UploadPostState({
    // ---------- Basic info ----------
    String? title,
    String? description,
    double? productPrice,

    // ---------- Category ----------
    String? categoryId,

    // ---------- Measurements ----------
    double? chest,
    double? waist,
    double? length,
    double? sleeveLength,
    double? shoulderWidth,

    // ---------- New schema codes ----------
    String? conditionCode,
    @Default(<String>[]) List<String> defectCodes,
    @Default(<String>[]) List<String> materialCodes,
    @Default(<String>[]) List<String> colorCodes,
    @Default('') String statusCode,
    String? otherMaterial,
    String? otherDefectNote,

    // ---------- Legacy display strings ----------
    String? brand,
    String? size,

    // ---------- Post ----------
    String? caption,

    // ---------- Media & tags ----------
    @Default(<UploadableMedia>[]) List<UploadableMedia> media,
    @Default(<String>[]) List<String> tagNames,
    @Default(0) int coverImageIndex,

    // ---------- UI state ----------
    @Default(false) bool isSubmitting,
    @Default(FormStatus.initial) FormStatus status,
    @Default(0) int uploadedMediaCount,
    @Default(0) int totalMediaCount,
  }) = _UploadPostState;

  bool get isValid =>
      productPrice != null &&
      categoryId != null &&
      media.isNotEmpty &&
      (caption?.trim().isNotEmpty ?? false) &&
      (title?.trim().isNotEmpty ?? false) &&
      (description?.trim().isNotEmpty ?? false);
}

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:rivo_app_beta/features/post/presentation/viewmodels/form_status.dart';
import 'package:rivo_app_beta/core/media/domain/entities/uploadable_media.dart';
part 'upload_post_state.freezed.dart';

@freezed
class UploadPostState with _$UploadPostState {
  const UploadPostState._();
  const factory UploadPostState({
    @Default('') String? title,
    String? description,
    double? price,
    double? chest,
    double? waist,
    double? length,
    String? caption,
    String? categoryId,
    @Default('') String? brand, // brand of the item
    @Default('') String? material, // material description
    @Default('') String? condition, // item condition (e.g. New, Used)
    @Default('') String? size, // item size
    @Default([]) List<UploadableMedia> media,
    @Default([]) List<String> tagNames,
    @Default(0) int coverImageIndex, // Index of the selected cover image
    @Default(false) bool isSubmitting,
    @Default(FormStatus.initial) FormStatus status,
    @Default(0) int uploadedMediaCount,
    @Default(0) int totalMediaCount,
  }) = _UploadPostState;
  // Require price, category, at least one media, and non-empty caption for a valid upload
  bool get isValid =>
      price != null &&
      categoryId != null &&
      media.isNotEmpty &&
      caption != null &&
      caption!.trim().isNotEmpty;
}

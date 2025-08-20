import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivo_app_beta/core/error_handling/app_exception.dart';
import 'package:rivo_app_beta/core/media/domain/entities/uploadable_media.dart';
import 'package:rivo_app_beta/features/post/domain/entities/upload_post_payload.dart';
import 'package:rivo_app_beta/features/post/domain/usecases/upload_post_use_case.dart';
import 'package:rivo_app_beta/features/post/domain/entities/tag_entity.dart';
import 'package:rivo_app_beta/features/post/presentation/viewmodels/upload_post_state.dart';
import 'package:rivo_app_beta/features/post/domain/providers/post_providers.dart';
import 'package:rivo_app_beta/core/utils/media_validator.dart';
import 'package:rivo_app_beta/core/utils/input_sanitizer.dart';
import 'package:flutter/foundation.dart';


class UploadPostViewModel extends StateNotifier<UploadPostState> {
  final UploadPostUseCase useCase;

  UploadPostViewModel({required this.useCase}) : super(const UploadPostState());

  void setTitle(String? value) =>
      state = state.copyWith(title: value == null ? null : InputSanitizer.sanitizeTitle(value));

  void setDescription(String? value) =>
      state = state.copyWith(description: value == null ? null : InputSanitizer.sanitizeDescription(value));

  void setPrice(double? value) {
    if (value == null) {
      state = state.copyWith(productPrice: null);
    } else {
      final sanitized = InputSanitizer.sanitizePrice(value.toString());
      final parsed = double.tryParse(sanitized);
      state = state.copyWith(productPrice: parsed);
    }
  }

  void setCategory(String? id) => state = state.copyWith(categoryId: id);

  void setTags(List<String> tagNames) =>
      state = state.copyWith(tagNames: InputSanitizer.sanitizeTags(tagNames));

  void setCaption(String? value) =>
      state = state.copyWith(caption: value == null ? null : InputSanitizer.sanitizeDescription(value));

  void setOtherMaterial(String? value) => state = state.copyWith(otherMaterial: value);

  void setConditionCode(String? code) => state = state.copyWith(conditionCode: code);

  void setDefectCodes(List<String> codes) =>
      state = state.copyWith(defectCodes: List<String>.from(codes));

  void setOtherDefectNote(String? note) => state = state.copyWith(otherDefectNote: note);

  void setMaterialCodes(List<String> codes) =>
      state = state.copyWith(materialCodes: List<String>.from(codes));

  void setColorCodes(List<String> codes) =>
      state = state.copyWith(colorCodes: List<String>.from(codes));

  void setStatusCode(String code) => state = state.copyWith(statusCode: code);

  void setChest(double? value) => state = state.copyWith(chest: value);
  void setWaist(double? value) => state = state.copyWith(waist: value);
  void setLength(double? value) => state = state.copyWith(length: value);
  void setSleeveLength(double? value) => state = state.copyWith(sleeveLength: value);
  void setShoulderWidth(double? value) => state = state.copyWith(shoulderWidth: value);

  void reset() => state = const UploadPostState();

  void setBrand(String? value) {
    if (value == null) {
      state = state.copyWith(brand: null);
    } else {
      state = state.copyWith(brand: InputSanitizer.sanitizeSimpleField(value));
    }
  }

  void setSize(String? value) {
    if (value == null) {
      state = state.copyWith(size: null);
    } else {
      state = state.copyWith(size: InputSanitizer.sanitizeSimpleField(value));
    }
  }

  Future<void> setMedia(List<UploadableMedia> selectedMedia) async {
    final processed = <UploadableMedia>[];

    for (var i = 0; i < selectedMedia.length; i++) {
      final media = selectedMedia[i];
      final file = await media.asset.file;

      if (file == null) {
        processed.add(media.copyWith(
          status: UploadMediaStatus.invalid,
          errorMessage: 'Media file not found',
          sortOrder: i,
        ));
        continue;
      }

      final validation = MediaValidator.validateSource(file, type: media.type);

      final validatedMedia = await validation.fold(
        (_) async {
          final maybeBytes = media.type == MediaType.image ? await media.asset.originBytes : null;
          return media.copyWith(
            file: file,
            bytes: maybeBytes,
            status: UploadMediaStatus.valid,
            errorMessage: null,
            sortOrder: i,
          );
        },
        (error) async => media.copyWith(
          file: file,
          status: UploadMediaStatus.invalid,
          errorMessage: error.toString(),
          sortOrder: i,
        ),
      );

      processed.add(validatedMedia);
    }

    state = state.copyWith(media: processed);
  }

  void reorderMedia(int oldIndex, int newIndex) {
    final items = List<UploadableMedia>.from(state.media);
    final item = items.removeAt(oldIndex);
    items.insert(newIndex, item);

    final reindexed = <UploadableMedia>[];
    for (var i = 0; i < items.length; i++) {
      reindexed.add(items[i].copyWith(sortOrder: i));
    }

    state = state.copyWith(media: reindexed);
  }

  void removeMedia(UploadableMedia file) {
    final remaining = List<UploadableMedia>.from(state.media)..removeWhere((m) => m.path == file.path);

    final reindexed = <UploadableMedia>[];
    for (var i = 0; i < remaining.length; i++) {
      reindexed.add(remaining[i].copyWith(sortOrder: i));
    }

    state = state.copyWith(media: reindexed);
  }

  void updateMediaStatus(String mediaPath, UploadMediaStatus status) {
    final updated = state.media.map((item) => item.path == mediaPath ? item.copyWith(status: status) : item).toList();
    state = state.copyWith(media: updated);
  }

  void setCoverImageIndex(int index) {
    if (index >= 0 && index < state.media.length) {
      state = state.copyWith(coverImageIndex: index);
    }
  }

  Future<String> submit() async {
    try {
      if (state.media.isEmpty) throw AppException.validation('uploadMediaRequired');
      if (state.categoryId == null || state.categoryId!.isEmpty) throw AppException.validation('uploadCategoryRequired');
      if (state.conditionCode == null) throw AppException.validation('uploadConditionRequired');
      if (state.caption == null || state.caption!.trim().isEmpty) throw AppException.validation('uploadCaptionRequiredBackend');
      if (state.productPrice == null) throw AppException.validation('uploadPriceRequiredBackend');
      if (state.productPrice != null && state.productPrice! <= 1) {
        debugPrint("❌ [${DateTime.now()}] Validation failed: Price must be > 1 ILS");
        throw AppException.validation('price_must_be_above_min');
      }
      if ((state.conditionCode == 'good' || state.conditionCode == 'fair') && state.defectCodes.isEmpty) {
        throw AppException.validation('defects_required_for_condition');
      }
      if (state.title == null || state.title!.trim().isEmpty) throw AppException.validation('uploadTitleRequiredBackend');
      if (state.description == null || state.description!.trim().isEmpty) throw AppException.validation('uploadDescriptionRequiredBackend');
      if (!state.isValid) throw AppException.validation('upload.required_fields_missing');

      state = state.copyWith(isSubmitting: true);

      final validMedia = state.media.where((m) => m.status == UploadMediaStatus.valid).toList();

      debugPrint("🔎 codes check → "
          "defects=${state.defectCodes} "
          "materials=${state.materialCodes} "
          "colors=${state.colorCodes}");

      final payload = UploadPostPayload(
        hasProduct: true,
        productTitle: state.title!,
        productDescription: state.description!,
        productPrice: state.productPrice!,
        categoryId: state.categoryId!,
        chest: state.chest,
        waist: state.waist,
        length: state.length,
        brand: state.brand,
        size: state.size,
        sleeveLength: state.sleeveLength,
        shoulderWidth: state.shoulderWidth,
        conditionCode: state.conditionCode,
        defectCodes: state.defectCodes,
        materialCodes: state.materialCodes,
        colorCodes: state.colorCodes,
        statusCode: state.statusCode,
        otherMaterial: state.otherMaterial,
        otherDefectNote: state.otherDefectNote,
        caption: state.caption,
        media: validMedia,
        tags: state.tagNames.map((name) => TagEntity(name: name)).toList(),
      );

      final result = await useCase(
        payload,
        onMediaUploaded: (current, total) => state = state.copyWith(uploadedMediaCount: current, totalMediaCount: total),
        onMediaStatusChanged: updateMediaStatus,
      );

      return result.fold((failure) => throw failure, (postId) => postId);
    } finally {
      state = state.copyWith(isSubmitting: false);
    }
  }
}

final uploadPostViewModelProvider =
    StateNotifierProvider<UploadPostViewModel, UploadPostState>(
  (ref) {
    final useCase = ref.watch(uploadPostUseCaseProvider);
    return UploadPostViewModel(useCase: useCase);
  },
);

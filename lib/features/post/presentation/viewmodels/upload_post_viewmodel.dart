import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivo_app_beta/core/error_handling/app_exception.dart';
import 'package:rivo_app_beta/core/media/domain/entities/uploadable_media.dart';
import 'package:rivo_app_beta/features/post/domain/entities/upload_post_payload.dart';
import 'package:rivo_app_beta/features/post/domain/usecases/upload_post_use_case.dart';
import 'package:rivo_app_beta/features/post/domain/entities/tag_entity.dart';
import 'package:rivo_app_beta/features/post/data/datasources/upload_post_state.dart';
import 'package:rivo_app_beta/features/post/domain/providers/post_providers.dart';
import 'package:flutter/foundation.dart';

import 'package:rivo_app_beta/core/utils/media_validator.dart';
import 'package:rivo_app_beta/core/utils/input_sanitizer.dart'; // For input sanitization

class UploadPostViewModel extends StateNotifier<UploadPostState> {
  final UploadPostUseCase useCase;

  UploadPostViewModel({required this.useCase}) : super(const UploadPostState());

  // Sanitize and set title
  void setTitle(String? value) => state = state.copyWith(title: value != null ? InputSanitizer.sanitizeTitle(value) : null);
  // Sanitize and set description
  void setDescription(String? value) => state = state.copyWith(description: value != null ? InputSanitizer.sanitizeDescription(value) : null);
  // Sanitize and set price (convert to string, sanitize, then parse back)
  void setPrice(double? value) {
    if (value == null) {
      state = state.copyWith(price: null);
    } else {
      final sanitized = InputSanitizer.sanitizePrice(value.toString());
      final parsed = double.tryParse(sanitized);
      state = state.copyWith(price: parsed);
    }
  }
  // Set category ID directly as it comes from a controlled dropdown
  void setCategory(String? id) => state = state.copyWith(categoryId: id);
  // Sanitize and set tags
  void setTags(List<String> tagNames) => state = state.copyWith(tagNames: InputSanitizer.sanitizeTags(tagNames));
  // Chest, waist, length: only numbers, no need for string sanitization
  void setChest(double? value) => state = state.copyWith(chest: value);
  void setWaist(double? value) => state = state.copyWith(waist: value);
  void setLength(double? value) => state = state.copyWith(length: value);
  // Sanitize and set caption
  void setCaption(String? value) => state = state.copyWith(caption: value != null ? InputSanitizer.sanitizeDescription(value) : null);
  // Sanitize and set condition
  void setCondition(String? value) => state = state.copyWith(condition: value != null ? InputSanitizer.sanitizeSimpleField(value) : null);
  // Sanitize and set size
  void setSize(String? value) => state = state.copyWith(size: value != null ? InputSanitizer.sanitizeSimpleField(value) : null);
  // Sanitize and set brand
  void setBrand(String? value) => state = state.copyWith(brand: value != null ? InputSanitizer.sanitizeSimpleField(value) : null);
  // Sanitize and set material
  void setMaterial(String? value) => state = state.copyWith(material: value != null ? InputSanitizer.sanitizeSimpleField(value) : null);
  
  /// Resets the form to its initial state
  void reset() {
    state = const UploadPostState();
  }


Future<void> setMedia(List<UploadableMedia> selectedMedia) async {
  final processed = <UploadableMedia>[];

  for (var i = 0; i < selectedMedia.length; i++) {
    final media = selectedMedia[i];

    // לוקחים את הקובץ הפיזי מה-Asset; לא טוענים originBytes עבור וידאו
    final file = await media.asset.file;
    if (file == null) {
      processed.add(
        media.copyWith(
          status: UploadMediaStatus.invalid,
          errorMessage: 'Media file not found',
          sortOrder: i,
        ),
      );
      continue;
    }

final validation = MediaValidator.validateSource(file, type: media.type);

    final validatedMedia = validation.fold(
      // Success path → מסמנים כ-valid; bytes רק לתמונה (חוסך זיכרון לוידאו)
      (_) async {
        final maybeBytes =
            media.type == MediaType.image ? await media.asset.originBytes : null;

        return media.copyWith(
          file: file,
          bytes: maybeBytes,
          status: UploadMediaStatus.valid,
          errorMessage: null,
          sortOrder: i,
        );
      },
      // Failure path → invalid עם הודעת שגיאה
      (error) async => media.copyWith(
        file: file,
        status: UploadMediaStatus.invalid,
        errorMessage: error.toString(),
        sortOrder: i,
      ),
    );

    // כי fold מחזיר Future<UploadableMedia>
    processed.add(await validatedMedia);
  }

  state = state.copyWith(media: processed);
}





  void reorderMedia(int oldIndex, int newIndex) {
  final items = List<UploadableMedia>.from(state.media);
  final item = items.removeAt(oldIndex);
  items.insert(newIndex, item);

  // עדכון sortOrder לפי הסדר החדש
  final reindexed = <UploadableMedia>[];
  for (var i = 0; i < items.length; i++) {
    reindexed.add(items[i].copyWith(sortOrder: i));
  }

  state = state.copyWith(media: reindexed);
}


  void removeMedia(UploadableMedia file) {
  final remaining = List<UploadableMedia>.from(state.media)
    ..removeWhere((m) => m.path == file.path);

  final reindexed = <UploadableMedia>[];
  for (var i = 0; i < remaining.length; i++) {
    reindexed.add(remaining[i].copyWith(sortOrder: i));
  }

  state = state.copyWith(media: reindexed);
}


  void updateMediaStatus(String mediaPath, UploadMediaStatus status) {
  final updated = state.media.map((item) {
    if (item.path == mediaPath) {
      return item.copyWith(status: status);
    }
    return item;
  }).toList();

  state = state.copyWith(media: updated);
}



  Future<String> submit() async {
    // Throw specific validation errors for missing caption or price
    if (state.caption == null || state.caption!.trim().isEmpty) {
      throw AppException.validation('uploadCaptionRequiredBackend');
    }
    if (state.price == null) {
      throw AppException.validation('uploadPriceRequiredBackend');
    }
    if (!state.isValid) {
      throw AppException.validation('upload.required_fields_missing');
    }

    state = state.copyWith(isSubmitting: true);

    try {
      final validMedia = state.media
          .where((m) => m.status == UploadMediaStatus.valid)
          .toList();
      debugPrint("🧪 Media in state: ${state.media.length} total, ${validMedia.length} valid");
      final payload = UploadPostPayload(
        hasProduct: true,
        productTitle: state.title!,
        productDescription: state.description ?? '',
        productPrice: state.price!,
        categoryId: state.categoryId!,
        chest: state.chest,
        waist: state.waist,
        length: state.length,
        brand: state.brand?.isEmpty == true ? null : state.brand,
        material: state.material?.isEmpty == true ? null : state.material,
        condition: state.condition?.isEmpty == true ? null : state.condition,
        size: state.size?.isEmpty == true ? null : state.size,
        caption: state.caption,
        media: validMedia.map((m) => m).toList(),
        tags: state.tagNames.map((name) => TagEntity(name: name)).toList(),
      );

      final result = await useCase(
        payload,
        onMediaUploaded: (current, total) {
          state = state.copyWith(
            uploadedMediaCount: current,
            totalMediaCount: total,
          );
        },
        onMediaStatusChanged: updateMediaStatus, 
      );

      return result.fold(
        (failure) => throw failure,
        (postId) {
          debugPrint("✅ Upload success, post ID: $postId");
          return postId;
        },
      );
    } on AppException {
      rethrow;
    } catch (_) {
      throw AppException.unexpected('upload.unexpected_error');
    } finally {
      state = state.copyWith(isSubmitting: false);
    }
  }
}

final uploadPostViewModelProvider =
    StateNotifierProvider.autoDispose<UploadPostViewModel, UploadPostState>(
  (ref) {
    final useCase = ref.watch(uploadPostUseCaseProvider);
    return UploadPostViewModel(useCase: useCase);
  },
);

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

class UploadPostViewModel extends StateNotifier<UploadPostState> {
  final UploadPostUseCase useCase;

  UploadPostViewModel({required this.useCase}) : super(const UploadPostState());

  void setTitle(String? value) => state = state.copyWith(title: value);
  void setDescription(String? value) => state = state.copyWith(description: value);
  void setPrice(double? value) => state = state.copyWith(price: value);
  void setCategory(String? id) => state = state.copyWith(categoryId: id);
  void setTags(List<String> tagNames) => state = state.copyWith(tagNames: tagNames);
  void setChest(double? value) => state = state.copyWith(chest: value);
  void setWaist(double? value) => state = state.copyWith(waist: value);
  void setLength(double? value) => state = state.copyWith(length: value);
  void setCaption(String? value) => state = state.copyWith(caption: value);


  Future<void> setMedia(List<UploadableMedia> selectedMedia) async {
  final processed = <UploadableMedia>[];

  for (final media in selectedMedia) {
    final file = await media.asset.file;

    if (file == null) {
      processed.add(media.copyWith(
        status: UploadMediaStatus.invalid,
        errorMessage: 'Media file not found',
      ));
      continue;
    }

    final validation = MediaValidator.validate(file);

    final validatedMedia = validation.fold(
      (_) => media.copyWith(
        file: file,
        status: UploadMediaStatus.valid,
      ),
      (error) => media.copyWith(
        file: file,
        status: UploadMediaStatus.invalid,
        errorMessage: error.toString(),
      ),
    );

    processed.add(validatedMedia);
  }

  state = state.copyWith(media: processed);
}



  void removeMedia(UploadableMedia file) {
    state = state.copyWith(
      media: List.from(state.media)..removeWhere((m) => m.path == file.path),
    );
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



  Future<void> submit() async {
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


      result.fold(
  (failure) => throw failure,
  (_) => debugPrint("✅ Upload success"),
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

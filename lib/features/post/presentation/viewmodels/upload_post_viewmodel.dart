import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivo_app/core/error_handling/app_exception.dart';
import 'package:rivo_app/features/post/domain/entities/media_file.dart';
import 'package:rivo_app/features/post/domain/entities/upload_post_payload.dart';
import 'package:rivo_app/features/post/domain/usecases/upload_post_use_case.dart';
import 'package:rivo_app/features/post/domain/entities/tag_entity.dart';
import 'package:rivo_app/features/post/domain/providers/post_providers.dart';

class UploadPostState {
  final String? title;
  final String? description;
  final double? price;
  final String? categoryId;
  final List<String> tagNames;
  final double? chest;
  final double? waist;
  final double? length;
  final List<MediaFile> media;
  final String? caption;
  final bool isSubmitting;

  const UploadPostState({
    this.title,
    this.description,
    this.price,
    this.categoryId,
    this.tagNames = const [],
    this.chest,
    this.waist,
    this.length,
    this.media = const [],
    this.caption,
    this.isSubmitting = false,
  });

  bool get isValid =>
      price != null && categoryId != null && media.isNotEmpty;

  UploadPostState copyWith({
    String? title,
    String? description,
    double? price,
    String? categoryId,
    List<String>? tagNames,
    double? chest,
    double? waist,
    double? length,
    List<MediaFile>? media,
    String? caption,
    bool? isSubmitting,
  }) {
    return UploadPostState(
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      categoryId: categoryId ?? this.categoryId,
      tagNames: tagNames ?? this.tagNames,
      chest: chest ?? this.chest,
      waist: waist ?? this.waist,
      length: length ?? this.length,
      media: media ?? this.media,
      caption: caption ?? this.caption,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

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

  // 📌 זו הפונקציה היחידה שצריכה להיקרא מה־MediaPicker
  void setMedia(List<MediaFile> media) => state = state.copyWith(media: media);

  Future<void> submit() async {
    if (!state.isValid) {
      throw AppException.validation('upload.required_fields_missing');
    }

    state = state.copyWith(isSubmitting: true);

    try {
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
        media: state.media,
        tags: state.tagNames.map((name) => TagEntity(name: name)).toList(),
      );

      final result = await useCase(payload);
      result.fold((failure) => throw failure, (_) {});
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

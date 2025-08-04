import 'package:dartz/dartz.dart';
import 'package:rivo_app_beta/core/error_handling/app_exception.dart';
import 'package:rivo_app_beta/features/post/domain/entities/upload_post_payload.dart';
import 'package:rivo_app_beta/features/post/domain/repositories/post_repository.dart';
import 'package:rivo_app_beta/core/media/domain/entities/uploadable_media.dart';

class UploadPostUseCase {
  final PostRepository repository;

  UploadPostUseCase(this.repository);

  Future<Either<AppException, String>> call(
  UploadPostPayload payload, {
  void Function(int current, int total)? onMediaUploaded,
  void Function(String mediaPath, UploadMediaStatus status)? onMediaStatusChanged,
}) async {
  try {
    final postId = await repository.uploadPost(
      payload,
      onMediaUploaded: onMediaUploaded,
      onMediaStatusChanged: onMediaStatusChanged,
    );
    return right(postId);
  } catch (e) {
    if (e is AppException) return left(e);
    return left(AppException.unexpected('upload.unknown'));
  }
}

}

import 'package:dartz/dartz.dart';
import 'package:rivo_app_beta/core/error_handling/app_exception.dart';
import 'package:rivo_app_beta/features/post/domain/entities/upload_post_payload.dart';
import 'package:rivo_app_beta/features/post/domain/repositories/post_repository.dart';

class UploadPostUseCase {
  final PostRepository repository;

  UploadPostUseCase(this.repository);

  Future<Either<AppException, void>> call(UploadPostPayload payload) {
    return repository.uploadPost(payload);
  }
}

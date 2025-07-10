import 'package:dartz/dartz.dart';
import 'package:rivo_app_beta/core/error_handling/app_exception.dart';
import 'package:rivo_app_beta/features/post/domain/entities/upload_post_payload.dart';

abstract class PostRepository {
  Future<Either<AppException, void>> uploadPost(UploadPostPayload payload);
}

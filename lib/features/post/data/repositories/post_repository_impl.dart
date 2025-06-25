import 'package:dartz/dartz.dart';
import 'package:rivo_app/core/error_handling/app_exception.dart';
import 'package:rivo_app/features/post/domain/entities/upload_post_payload.dart';
import 'package:rivo_app/features/post/domain/repositories/post_repository.dart';
import 'package:rivo_app/features/post/data/datasources/post_remote_data_source.dart';

class PostRepositoryImpl implements PostRepository {
  final PostRemoteDataSource remoteDataSource;

  PostRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<AppException, void>> uploadPost(UploadPostPayload payload) async {
    try {
      await remoteDataSource.uploadPost(payload);
      return right(null);
    } on AppException catch (e) {
      return left(e);
    } catch (e) {
      return left(AppException.unexpected('Unexpected error occurred'));
    }
  }
}

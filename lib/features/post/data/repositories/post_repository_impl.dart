
import 'package:rivo_app_beta/features/post/domain/entities/upload_post_payload.dart';
import 'package:rivo_app_beta/features/post/domain/repositories/post_repository.dart';
import 'package:rivo_app_beta/features/post/data/datasources/post_remote_data_source.dart';
import 'package:rivo_app_beta/core/media/domain/entities/uploadable_media.dart';


class PostRepositoryImpl implements PostRepository {
  final PostRemoteDataSource remoteDataSource;

  PostRepositoryImpl({required this.remoteDataSource});

  @override
  Future<String> uploadPost(
    UploadPostPayload payload, {
    void Function(int uploaded, int total)? onMediaUploaded,
    void Function(String mediaPath, UploadMediaStatus status)? onMediaStatusChanged, 
  }) async {
    return await remoteDataSource.uploadPost(
      payload,
      onMediaUploaded: onMediaUploaded,
      onMediaStatusChanged: onMediaStatusChanged, 
    );
  }


}

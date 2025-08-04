import 'package:rivo_app_beta/features/post/domain/entities/upload_post_payload.dart';
import 'package:rivo_app_beta/core/media/domain/entities/uploadable_media.dart';

abstract class PostRepository {
  Future<String> uploadPost(
    UploadPostPayload payload, {
    void Function(int uploaded, int total)? onMediaUploaded,
    void Function(String mediaPath, UploadMediaStatus status)? onMediaStatusChanged, 
  });
}



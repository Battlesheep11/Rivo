import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rivo_app_beta/core/error_handling/app_exception.dart';
import 'package:rivo_app_beta/features/post/domain/entities/upload_post_payload.dart';
import 'package:rivo_app_beta/features/post/domain/entities/uploadable_media.dart';
import 'package:rivo_app_beta/core/utils/image_utils.dart';
import 'package:rivo_app_beta/core/utils/video_utils.dart';

class PostRemoteDataSource {
  final SupabaseClient client;

  PostRemoteDataSource({required this.client});

  Future<void> uploadPost(
    UploadPostPayload payload, {
    void Function(int uploaded, int total)? onMediaUploaded,
    void Function(String mediaPath, UploadMediaStatus status)? onMediaStatusChanged,
  }) async {
    try {
      final userId = client.auth.currentUser?.id;
      if (userId == null) {
        throw AppException.unauthorized('User not logged in');
      }

      String? productId;

      if (payload.hasProduct) {
        productId = await _uploadProduct(
          payload,
          userId,
          onMediaUploaded,
          onMediaStatusChanged,
        );
      }

      await _uploadFeedPost(payload, userId, productId);
    } on PostgrestException catch (e) {
      throw AppException.unexpected(
        'Supabase error: ${e.message}',
        code: 'upload_post_error',
      );
    } catch (e) {
      throw AppException.unexpected(
        'Unexpected error occurred',
        code: 'upload_post_error',
      );
    }
  }

  Future<String> _uploadProduct(
    UploadPostPayload payload,
    String userId,
    void Function(int uploaded, int total)? onMediaUploaded,
    void Function(String mediaPath, UploadMediaStatus status)? onMediaStatusChanged,
  ) async {
    final productResponse = await client
        .from('products')
        .insert({
          'seller_id': userId,
          'title': payload.productTitle,
          'description': payload.productDescription,
          'price': payload.productPrice,
          'chest': payload.chest,
          'waist': payload.waist,
          'length': payload.length,
          'category_id': payload.categoryId,
        })
        .select('id')
        .single();

    final productId = productResponse['id'] as String;

    for (int i = 0; i < payload.media.length; i++) {
      final media = payload.media[i];
      String? mediaUrl = media.url;

      try {
        onMediaStatusChanged?.call(media.path, UploadMediaStatus.uploading);

        if (mediaUrl.isEmpty) {
          final ext = media.type == 'video' ? 'webm' : 'jpg';
          final uniqueId = DateTime.now().millisecondsSinceEpoch.toString();
          final filename = '${userId}_$uniqueId.$ext';
          final path = 'media/$filename';

          Uint8List bytesToUpload = media.bytes;

          if (media.type == 'image') {
            bytesToUpload = await ImageUtils.compressImage(media.bytes);
          } else if (media.type == 'video') {
            try {
              bytesToUpload = await VideoUtils.compressVideo(media.bytes);
            } catch (_) {
              bytesToUpload = media.bytes;
            }
          }

          await client.storage.from('media').uploadBinary(
            path,
            bytesToUpload,
            fileOptions: FileOptions(
              contentType: media.type == 'video' ? 'video/webm' : 'image/jpeg',
              upsert: true,
            ),
          );

          mediaUrl = client.storage.from('media').getPublicUrl(path);
        }

        final mediaInsert = await client
            .from('media')
            .insert({
              'media_url': mediaUrl,
              'media_type': media.type,
            })
            .select('id')
            .single();

        final mediaId = mediaInsert['id'] as String;

        await client.from('product_media').insert({
          'product_id': productId,
          'media_id': mediaId,
          'sort_order': media.sortOrder ?? 0,
        });

        onMediaUploaded?.call(i + 1, payload.media.length);
        onMediaStatusChanged?.call(media.path, UploadMediaStatus.uploaded);
      } catch (e) {
        onMediaStatusChanged?.call(media.path, UploadMediaStatus.failed);
        continue;
      }
    }

    for (final tag in payload.tags) {
      final tagId = await _getOrCreateTagByName(tag.name);

      await client.from('product_tags').insert({
        'product_id': productId,
        'tag_id': tagId,
      });
    }

    return productId;
  }

  Future<void> _uploadFeedPost(
    UploadPostPayload payload,
    String userId,
    String? productId,
  ) async {
    final postResponse = await client
        .from('feed_post')
        .insert({
          'creator_id': userId,
          'product_id': productId,
          'caption': payload.caption,
        })
        .select('id')
        .single();

    final postId = postResponse['id'] as String;

    for (final tag in payload.tags) {
      final tagId = await _getOrCreateTagByName(tag.name);

      await client.from('post_tags').insert({
        'post_id': postId,
        'tag_id': tagId,
      });
    }
  }

  Future<String> _getOrCreateTagByName(String tagName) async {
    final existing = await client
        .from('tags')
        .select('id')
        .eq('name', tagName)
        .maybeSingle();

    if (existing != null) {
      return existing['id'] as String;
    }

    final created = await client
        .from('tags')
        .insert({
          'name': tagName,
          'is_visible': true,
        })
        .select('id')
        .single();

    return created['id'] as String;
  }
}

import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rivo_app_beta/core/error_handling/app_exception.dart';
import 'package:rivo_app_beta/features/post/domain/entities/upload_post_payload.dart';
import 'package:rivo_app_beta/core/media/domain/entities/uploadable_media.dart';
import 'package:rivo_app_beta/core/media/data/media_compressor.dart';
import 'package:flutter/foundation.dart';

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
      File? fileToUpload = media.file;

      try {
        onMediaStatusChanged?.call(media.path, UploadMediaStatus.uploading);

        final ext = media.type == MediaType.video ? 'webm' : 'jpg';
        final uniqueId = DateTime.now().millisecondsSinceEpoch.toString();
        final filename = '${userId}_$uniqueId.$ext';
        final path = 'media/$filename';

        if (fileToUpload == null) {
          final originFile = await media.asset.file;
          if (originFile == null) {
            throw AppException.unexpected("Cannot access original file from asset");
          }

          final result = media.type == MediaType.image
              ? await MediaCompressor.compressImageFile(originFile)
              : await MediaCompressor.compressVideoFile(originFile);

          result.fold(
            (file) => fileToUpload = file,
            (error) => throw error,
          );
        }

        final confirmedFile = fileToUpload;
        if (confirmedFile == null || !confirmedFile.existsSync()) {
          throw AppException.unexpected("File does not exist before uploadBinary");
        }

        final fileBytes = await confirmedFile.readAsBytes();

        await client.storage.from('media').uploadBinary(
          path,
          fileBytes,
          fileOptions: FileOptions(
            contentType: media.type == MediaType.video ? 'video/webm' : 'image/jpeg',
            upsert: true,
          ),
        );

        final mediaUrl = client.storage.from('media').getPublicUrl(path);

        final mediaInsert = await client
            .from('media')
            .insert({
              'media_url': mediaUrl,
              'media_type': media.type.name,
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

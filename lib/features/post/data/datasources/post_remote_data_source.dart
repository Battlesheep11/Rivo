import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rivo_app_beta/core/error_handling/app_exception.dart';
import 'package:rivo_app_beta/features/post/domain/entities/upload_post_payload.dart';

class PostRemoteDataSource {
  final SupabaseClient client;

  PostRemoteDataSource({required this.client});

  Future<void> uploadPost(UploadPostPayload payload) async {
    try {
      final userId = client.auth.currentUser?.id;
      if (userId == null) {
        throw AppException.unauthorized('User not logged in');
      }

      String? productId;

      if (payload.hasProduct) {
        productId = await _uploadProduct(payload, userId);
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

  Future<String> _uploadProduct(UploadPostPayload payload, String userId) async {
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

    for (final media in payload.media) {
      String? mediaUrl = media.url;

      if (mediaUrl == null || mediaUrl.isEmpty) {
        final ext = media.type == 'video' ? 'mp4' : 'jpg';
        final filename = '${DateTime.now().millisecondsSinceEpoch}.$ext';
        final path = 'media/$filename';

        await client.storage.from('media').uploadBinary(
          path,
          media.bytes,
          fileOptions: FileOptions(contentType: '${media.type}/$ext'),
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

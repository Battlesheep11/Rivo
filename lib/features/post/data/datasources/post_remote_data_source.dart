import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rivo_app/core/error_handling/app_exception.dart';
import 'package:rivo_app/features/post/domain/entities/upload_post_payload.dart';

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
    // 1. Insert product
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

    // 2. Insert media → media + product_media
    for (final media in payload.media) {
      final mediaInsert = await client
          .from('media')
          .insert({
            'media_url': media.url,
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

    // 3. Insert tags → product_tags
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
  // 1. Insert post
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

  // 2. Insert post_tags
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

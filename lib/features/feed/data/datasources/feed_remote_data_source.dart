import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rivo_app/core/error_handling/app_exception.dart';
import 'package:rivo_app/features/feed/domain/entities/feed_post_entity.dart';

class FeedRemoteDataSource {
  final SupabaseClient _client;

  FeedRemoteDataSource({required SupabaseClient client}) : _client = client;

  Future<List<FeedPostEntity>> getFeedPosts() async {
    try {
      const query = '''
        id,
        created_at,
        like_count,
        caption,
        creator_id,
        product_id,
        product:product_id (
          id,
          title,
          description,
          price,
          product_media:product_media (
            media_id (
              media_url
            ),
            sort_order
          )
        ),
        creator:creator_id (
          id,
          username,
          avatar_url
        )
      ''';

      final response = await _client
          .from('feed_post')
          .select(query)
          .order('created_at', ascending: false);

      final posts = (response as List).map((json) {
        final product = json['product'] as Map<String, dynamic>? ?? {};
        final productMediaList = (product['product_media'] as List<dynamic>? ?? [])
            .cast<Map<String, dynamic>>();

        final productMediaUrls = productMediaList
            .map((m) => m['media_id']?['media_url'] as String?)
            .whereType<String>()
            .toList();

        return FeedPostEntity(
          id: json['id'] as String,
          createdAt: DateTime.parse(json['created_at']),
          likeCount: (json['like_count'] ?? 0) as int,
          creatorId: json['creator_id'] as String,
          caption: json['caption'] as String?,
          productId: json['product_id'] as String,
          username: json['creator']?['username'] ?? 'Unknown',
          avatarUrl: json['creator']?['avatar_url'],
          productTitle: product['title'] ?? '',
          productDescription: product['description'],
          productPrice: (product['price'] ?? 0).toDouble(),
          mediaUrls: productMediaUrls,
          tags: [],
        );
      }).toList();

      return posts;
    } on PostgrestException catch (e) {
      throw AppException.network('Failed to fetch feed: ${e.message}');
    } catch (e) {
      throw AppException.unexpected('An unexpected error occurred: $e');
    }
  }
}

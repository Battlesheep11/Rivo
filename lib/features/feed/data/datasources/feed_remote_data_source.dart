import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rivo_app_beta/core/error_handling/app_exception.dart';
import 'package:rivo_app_beta/features/feed/domain/entities/feed_post_entity.dart';

class FeedRemoteDataSource {
  final SupabaseClient _client;

  FeedRemoteDataSource({required SupabaseClient client}) : _client = client;


  
Future<void> likePost(String postId) async {
  final userId = _client.auth.currentUser?.id;
  if (userId == null) throw Exception('User not authenticated');

  await _client.from('post_likes').insert({
    'user_id': userId,
    'post_id': postId,
  });
}

Future<void> unlikePost(String postId) async {
  final userId = _client.auth.currentUser?.id;
  if (userId == null) throw Exception('User not authenticated');

  await _client
      .from('post_likes')
      .delete()
      .match({'user_id': userId, 'post_id': postId});
}


  Future<List<FeedPostEntity>> getFeedPosts() async {
  try {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw AppException.unauthorized('User not logged in');
    }

    // 1. Get posts
    const postQuery = '''
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

    final postResponse = await _client
        .from('feed_post')
        .select(postQuery)
        .order('created_at', ascending: false);

    // 2. Get likes by current user
    final likesResponse = await _client
        .from('post_likes')
        .select('post_id')
        .eq('user_id', userId);

    final likedPostIds = (likesResponse as List)
        .map((e) => e['post_id'] as String)
        .toSet();


        


    // 3. Map to FeedPostEntity
    final posts = (postResponse as List).map((json) {
      final product = json['product'] as Map<String, dynamic>? ?? {};
      final productMediaList = (product['product_media'] as List<dynamic>? ?? [])
          .cast<Map<String, dynamic>>();

      final productMediaUrls = productMediaList
          .map((m) => m['media_id']?['media_url'] as String?)
          .whereType<String>()
          .toList();

      final postId = json['id'] as String;

      return FeedPostEntity(
        id: postId,
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
        isLikedByMe: likedPostIds.contains(postId),
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

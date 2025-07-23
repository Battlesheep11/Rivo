import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rivo_app_beta/core/error_handling/app_exception.dart';
import 'package:rivo_app_beta/features/feed/domain/entities/feed_post_entity.dart';

/// A data source that handles remote feed-related operations.
/// 
/// This class is responsible for all feed-related network operations including:
/// - Fetching feed posts
/// - Managing post likes/unlikes
/// - Interacting with the Supabase backend
class FeedRemoteDataSource {
  /// The Supabase client used for database operations
  final SupabaseClient _client;

  /// Creates a new [FeedRemoteDataSource] instance.
  /// 
  /// [client]: The Supabase client to use for database operations
  FeedRemoteDataSource({required SupabaseClient client}) : _client = client;



  Future<List<FeedPostEntity>> getPostsByCreator(String userId) async {
  final res = await _client
      .from('feed_post')
      .select('*, product(*, media(*))') 
      .eq('creator_id', userId)
      .order('created_at', ascending: false);

  return (res as List).map((item) => FeedPostEntity.fromMap(item)).toList();
}

Future<List<FeedPostEntity>> getPostsByIds(List<String> postIds) async {
  if (postIds.isEmpty) return [];

  final res = await _client
      .from('feed_post')
      .select('*, product(*, media(*))') 
      .inFilter('id', postIds)
      .order('created_at', ascending: false);
  return (res as List).map((item) => FeedPostEntity.fromMap(item)).toList();
}


  
  /// Likes a post on behalf of the current user.
  /// 
  /// This method adds a like to the specified post for the currently
  /// authenticated user.
  /// 
  /// [postId]: The ID of the post to like
  /// 
  /// Throws an [Exception] if:
  /// - The user is not authenticated
  /// - The database operation fails
  Future<void> likePost(String postId) async {
  final userId = _client.auth.currentUser?.id;
  if (userId == null) throw Exception('User not authenticated');

  await _client.from('post_likes').insert({
    'user_id': userId,
    'post_id': postId,
  });
}

  /// Removes a like from a post for the current user.
  /// 
  /// This method removes the like from the specified post for the currently
  /// authenticated user.
  /// 
  /// [postId]: The ID of the post to unlike
  /// 
  /// Throws an [Exception] if:
  /// - The user is not authenticated
  /// - The database operation fails
  Future<void> unlikePost(String postId) async {
  final userId = _client.auth.currentUser?.id;
  if (userId == null) throw Exception('User not authenticated');

  await _client
      .from('post_likes')
      .delete()
      .match({'user_id': userId, 'post_id': postId});
}


  /// Fetches a list of feed posts for the current user.
  /// 
  /// This method retrieves posts along with related data including:
  /// - Post details (ID, creation time, like count, etc.)
  /// - Product information for each post
  /// - Creator information
  /// - Media URLs for products
  /// - Like status for the current user
  /// 
  /// Returns a [List] of [FeedPostEntity] objects.
  /// 
  /// Throws an [AppException] if:
  /// - The user is not authenticated (unauthorized)
  /// - There's a network error (network)
  /// - An unexpected error occurs (unexpected)
  Future<List<FeedPostEntity>> getFeedPosts() async {
  try {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw AppException.unauthorized('User not logged in');
    }

    // 1. Get posts with related data using a single query with joins
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

    // 2. Get all post IDs that the current user has liked
    final likesResponse = await _client
        .from('post_likes')
        .select('post_id')
        .eq('user_id', userId);

    final likedPostIds = (likesResponse as List)
        .map((e) => e['post_id'] as String)
        .toSet();


        


    // 3. Transform raw database response into domain entities in FeedPostEntity
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

Future<bool> isCurrentUserSeller() async {
    final user = _client.auth.currentUser;
    if (user == null) return false;

    final profile = await _client
        .from('profiles')
        .select('is_seller')
        .eq('id', user.id)
        .maybeSingle();

    return profile != null && profile['is_seller'] == true;
  }

}

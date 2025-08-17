import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rivo_app_beta/core/error_handling/app_exception.dart';
import 'package:rivo_app_beta/core/security/input_validator.dart';
import 'package:rivo_app_beta/core/security/rate_limiter.dart';
import 'package:rivo_app_beta/features/feed/domain/entities/feed_post_entity.dart';
import 'package:logger/logger.dart';

/// A data source that handles remote feed-related operations.
///
/// This class is responsible for all feed-related network operations including:
/// - Fetching feed posts
/// - Managing post likes/unlikes
/// - Interacting with the Supabase backend
class FeedRemoteDataSource with RateLimited {
  static const _rateLimitKey = 'feed_requests';
  static const _maxRequestsPerMinute = 60; // Adjust based on your API limits

  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 50,
      colors: true,
      printEmojis: true,
    ),
  );

  /// The Supabase client used for database operations
  final SupabaseClient _client;

  /// Creates a new [FeedRemoteDataSource] instance.
  ///
  /// [client]: The Supabase client to use for database operations
  FeedRemoteDataSource({required SupabaseClient client}) : _client = client;

  Future<List<FeedPostEntity>> getPostsByTag(String tagId) async {
    // שלב 1 – שליפת postIds מה-tag
    final postIdResults = await _client
        .from('post_tags')
        .select('post_id')
        .eq('tag_id', tagId);

    final postIds =
        (postIdResults as List).map((e) => e['post_id'] as String).toList();

    if (postIds.isEmpty) return [];

    // שלב 2 – שימוש בפונקציה קיימת
    return await getPostsByIds(postIds);
  }

  Future<List<FeedPostEntity>> getPostsByCollection(String collectionId) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw AppException.unauthorized('User not logged in');
      }

      await checkRateLimit(
        key: '${_rateLimitKey}_collection_$collectionId',
        maxRequests: _maxRequestsPerMinute,
      );

      // שלב 1: שליפת כל post_id לפי collection
      final postIdsResponse = await _client
          .from('curated_collection_posts')
          .select('post_id')
          .eq('collection_id', collectionId);

      final postIds =
          (postIdsResponse as List).map((e) => e['post_id'] as String).toList();

      if (postIds.isEmpty) return [];

      // שלב 2: שימוש בפונקציה קיימת
      return await getPostsByIds(postIds);
    } catch (e) {
      _logger.e('Error in getPostsByCollection: $e');
      throw AppException.unexpected('Failed to load posts for collection');
    }
  }

  /// Fetches posts created by a specific user.
  ///
  /// [userId]: The ID of the user whose posts to fetch
  ///
  /// Returns a list of [FeedPostEntity] objects.
 Future<List<FeedPostEntity>> getPostsByCreator(String userId) async {
  try {
    final validatedUserId = InputValidator.validateId(userId, fieldName: 'User ID');

    final callerId = _client.auth.currentUser?.id;
    if (callerId == null) {
      throw AppException.unauthorized('User not authenticated');
    }
    await checkRateLimit(
      key: '${_rateLimitKey}_getPostsByCreator_$callerId',
      maxRequests: _maxRequestsPerMinute,
    );

    _logger.d('Fetching posts for user: $validatedUserId');

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

    final res = await _client
        .from('feed_post')
        .select(postQuery)
        .eq('creator_id', validatedUserId)
        .eq('is_deleted', false)
        .order('created_at', ascending: false);

    if (res.isEmpty) {
      _logger.w('No posts found for user: $validatedUserId');
      return [];
    }

    // Optionally: which of these posts the caller liked
    final likesResponse = await _client
        .from('post_likes')
        .select('post_id')
        .eq('user_id', callerId);

    final likedPostIds =
        (likesResponse as List).map((e) => e['post_id'] as String).toSet();

    return (res as List).map((json) {
      final product = json['product'] as Map<String, dynamic>? ?? {};
      final mediaList =
          (product['product_media'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
      final mediaUrls = mediaList
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
        productId: json['product_id'] as String?,
        username: json['creator']?['username'] ?? '',
        avatarUrl: json['creator']?['avatar_url'], // ← same source as profile
        productTitle: product['title'] ?? '',
        productDescription: product['description'],
        productPrice: (product['price'] ?? 0).toDouble(),
        mediaUrls: mediaUrls,
        tags: const [],
        isLikedByMe: likedPostIds.contains(postId),
      );
    }).toList();
  } on PostgrestException catch (e) {
    _logger.e('Database error fetching posts: ${e.message}');
    throw AppException.network('Failed to fetch posts: ${e.message}');
  } catch (e) {
    _logger.e('Unexpected error in getPostsByCreator: $e');
    throw AppException.unexpected('An error occurred while fetching posts');
  }
}


  /// Fetches posts by their IDs.
  ///
  /// [postIds]: A list of post IDs to fetch
  Future<List<FeedPostEntity>> getPostsByIds(List<String> postIds) async {
    try {
      if (postIds.isEmpty) {
        _logger.d('Empty post IDs list provided');
        return [];
      }

      final validatedPostIds = InputValidator.validateIdList(
        postIds,
        fieldName: 'Post ID',
      );

      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw AppException.unauthorized('User not logged in');
      }

      await checkRateLimit(
        key: '${_rateLimitKey}_get_by_ids',
        maxRequests: _maxRequestsPerMinute,
      );

      _logger.d('Fetching ${validatedPostIds.length} posts by IDs');

      final res = await _client
          .from('feed_post')
          .select('''
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
        ''')
          .filter('id', 'in', '(${validatedPostIds.map((e) => "'$e'").join(",")})')
          .order('created_at', ascending: false);

      final likesResponse = await _client
          .from('post_likes')
          .select('post_id')
          .eq('user_id', userId);

      final likedPostIds =
          (likesResponse as List).map((e) => e['post_id'] as String).toSet();

      return (res as List).map((json) {
        final product = json['product'] ?? {};
        final mediaList =
            (product['product_media'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
        final mediaUrls = mediaList
            .map((m) => m['media_id']?['media_url'] as String?)
            .whereType<String>()
            .toList();

        final postId = json['id'] as String;

        return FeedPostEntity(
          id: postId,
          createdAt: DateTime.parse(json['created_at']),
          likeCount: json['like_count'] ?? 0,
          creatorId: json['creator_id'],
          caption: json['caption'],
          productId: json['product_id'],
          username: json['creator']?['username'] ?? '',
          avatarUrl: json['creator']?['avatar_url'],
          productTitle: product['title'] ?? '',
          productDescription: product['description'],
          productPrice: (product['price'] ?? 0).toDouble(),
          mediaUrls: mediaUrls,
          tags: [],
          isLikedByMe: likedPostIds.contains(postId),
        );
      }).toList();
    } catch (e) {
      _logger.e('Error in getPostsByIds: $e');
      throw AppException.unexpected('Failed to load posts');
    }
  }

  /// Likes a post on behalf of the current user.
  Future<void> likePost(String postId) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw AppException.unauthorized('User not authenticated');
      }

      // Validate input
      final validatedPostId =
          InputValidator.validateId(postId, fieldName: 'Post ID');

      // Check rate limit
      await checkRateLimit(
        key: '${_rateLimitKey}_like_$userId',
        maxRequests: 30, // Lower limit for like actions
      );

      _logger.d('User $userId liking post $validatedPostId');

      await _client.from('post_likes').insert({
        'user_id': userId,
        'post_id': validatedPostId,
      });

      _logger.i('Successfully liked post $validatedPostId');
    } on PostgrestException catch (e) {
      _logger.e('Database error liking post: ${e.message}');
      throw AppException.network('Failed to like post: ${e.message}');
    } catch (e) {
      _logger.e('Unexpected error in likePost: $e');
      rethrow; // Let the error bubble up with the original exception
    }
  }

  /// Removes a like from a post for the current user.
  Future<void> unlikePost(String postId) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw AppException.unauthorized('User not authenticated');
      }

      // Validate input
      final validatedPostId =
          InputValidator.validateId(postId, fieldName: 'Post ID');

      // Check rate limit
      await checkRateLimit(
        key: '${_rateLimitKey}_unlike_$userId',
        maxRequests: 30, // Lower limit for unlike actions
      );

      _logger.d('User $userId unliking post $validatedPostId');

      await _client
          .from('post_likes')
          .delete()
          .match({'user_id': userId, 'post_id': validatedPostId});

      _logger.i('Successfully unliked post $validatedPostId');
    } on PostgrestException catch (e) {
      _logger.e('Database error unliking post: ${e.message}');
      throw AppException.network('Failed to unlike post: ${e.message}');
    } catch (e) {
      _logger.e('Unexpected error in unlikePost: $e');
      rethrow; // Let the error bubble up with the original exception
    }
  }

  /// Fetches a list of feed posts for the current user.
  Future<List<FeedPostEntity>> getFeedPosts() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw AppException.unauthorized('User not logged in');
      }

      await checkRateLimit(
        key: '${_rateLimitKey}_feed_$userId',
        maxRequests: _maxRequestsPerMinute,
      );

      _logger.d('Fetching feed for user: $userId');

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
          .isFilter('deleted_at', null) // exclude soft-deleted
          .order('created_at', ascending: false);

      final likesResponse = await _client
          .from('post_likes')
          .select('post_id')
          .eq('user_id', userId);

      final likedPostIds =
          (likesResponse as List).map((e) => e['post_id'] as String).toSet();

      final posts = (postResponse as List).map((json) {
        final product = json['product'] as Map<String, dynamic>? ?? {};
        final productMediaList =
            (product['product_media'] as List<dynamic>? ?? [])
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
    try {
      final user = _client.auth.currentUser;
      if (user == null) return false;

      // Check rate limit
      await checkRateLimit(
        key: '${_rateLimitKey}_seller_check_${user.id}',
        maxRequests: 10, // Very low limit for this endpoint
      );

      _logger.d('Checking if user ${user.id} is a seller');

      final profile = await _client
          .from('profiles')
          .select('is_seller')
          .eq('id', user.id)
          .maybeSingle();

      final isSeller = profile != null && profile['is_seller'] == true;

      if (isSeller) {
        _logger.d('User ${user.id} is a seller');
      } else {
        _logger.d('User ${user.id} is not a seller');
      }

      return isSeller;
    } on PostgrestException catch (e) {
      _logger.e('Database error checking seller status: ${e.message}');
      throw AppException.network('Failed to verify seller status');
    } catch (e) {
      _logger.e('Unexpected error in isCurrentUserSeller: $e');
      return false; // Fail safely to non-seller status
    }
  }

  /// Delete a post (soft by default; hard delete optionally).
  Future<void> deletePost({
    required String postId,
    bool hard = false,
    bool deleteProduct = false,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw AppException.unauthorized('User not logged in');
    }
    final res = await _client.functions.invoke('delete_post', body: {
      'post_id': postId,
      if (hard) 'mode': 'hard',
      if (hard) 'delete_product': deleteProduct,
    });
    if (res.status != 200) {
      throw AppException.unexpected('delete_post_failed', code: 'delete_post_failed');
    }
  }
}

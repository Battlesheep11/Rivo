import '../entities/feed_post_entity.dart';

/// A repository interface for feed-related operations.
/// 
/// This abstract class defines the contract for feed operations that can be performed,
/// allowing for different implementations while maintaining a consistent API.
/// 
/// Implementations of this interface should handle:
/// - Fetching feed posts with all necessary data
/// - Managing post likes and unlikes
/// - Error handling and data transformation
abstract class FeedRepository {
  /// Fetches a list of feed posts for the current user.
  /// 
  /// This method should retrieve all feed posts along with their associated data
  /// including post details, creator information, product details, and media.
  /// 
  /// Returns a [Future] that completes with a list of [FeedPostEntity] objects.
  /// 
  /// Throws an [AppException] if:
  /// - The user is not authenticated
  /// - There's a network error
  /// - The data cannot be retrieved for any reason
  Future<List<FeedPostEntity>> getFeedPosts();
  /// Likes a specific post on behalf of the current user.
  /// 
  /// [postId]: The unique identifier of the post to like
  /// 
  /// Returns a [Future] that completes when the operation is done.
  /// 
  /// Throws an [AppException] if:
  /// - The user is not authenticated
  /// - The post doesn't exist
  /// - The operation fails
  Future<void> likePost(String postId);
  /// Removes a like from a specific post for the current user.
  /// 
  /// [postId]: The unique identifier of the post to unlike
  /// 
  /// Returns a [Future] that completes when the operation is done.
  /// 
  /// Throws an [AppException] if:
  /// - The user is not authenticated
  /// - The post doesn't exist
  /// - The operation fails
  Future<void> unlikePost(String postId);

  Future<bool> isCurrentUserSeller();
}

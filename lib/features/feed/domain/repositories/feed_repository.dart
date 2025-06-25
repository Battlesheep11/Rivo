import '../entities/feed_post_entity.dart';

abstract class FeedRepository {
  Future<List<FeedPostEntity>> getFeedPosts();
  Future<void> likePost(String postId);
  Future<void> unlikePost(String postId);
}

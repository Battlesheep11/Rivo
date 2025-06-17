import '../entities/feed_post_entity.dart';

abstract class FeedRepository {
  Future<List<FeedPostEntity>> getFeedPosts();
}

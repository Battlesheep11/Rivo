import '../../domain/entities/feed_post_entity.dart';
import '../../domain/repositories/feed_repository.dart';
import '../datasources/feed_remote_data_source.dart';

class FeedRepositoryImpl implements FeedRepository {
  final FeedRemoteDataSource remoteDataSource;

  FeedRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<FeedPostEntity>> getFeedPosts() {
    return remoteDataSource.getFeedPosts();
  }
}

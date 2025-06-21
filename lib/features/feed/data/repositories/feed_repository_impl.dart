import 'package:rivo_app/core/error_handling/app_exception.dart';
import 'package:rivo_app/features/feed/domain/entities/feed_post_entity.dart';
import 'package:rivo_app/features/feed/domain/repositories/feed_repository.dart';
import '../datasources/feed_remote_data_source.dart';

class FeedRepositoryImpl implements FeedRepository {
  final FeedRemoteDataSource remoteDataSource;

  FeedRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<FeedPostEntity>> getFeedPosts() async {
    try {
      final result = await remoteDataSource.getFeedPosts();
      return result;
    } on AppException {
      rethrow;
    } catch (e, stackTrace) {
      throw AppException.unexpected('Failed to load feed: $e', stackTrace: stackTrace);
    }
  }
}

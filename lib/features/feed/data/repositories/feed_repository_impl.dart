import 'package:rivo_app_beta/core/error_handling/app_exception.dart';
import 'package:rivo_app_beta/features/feed/domain/entities/feed_post_entity.dart';
import 'package:rivo_app_beta/features/feed/domain/repositories/feed_repository.dart';
import '../datasources/feed_remote_data_source.dart';

/// Implementation of the [FeedRepository] interface.
/// 
/// This class serves as the concrete implementation of the feed repository,
/// acting as an intermediary between the domain layer and data sources.
/// It handles the business logic and error handling for feed-related operations.
/// 
/// The implementation delegates most operations to a [FeedRemoteDataSource]
/// and adds appropriate error handling and data transformation.
/// 
/// This class is part of the data layer and should only be instantiated
/// through dependency injection (e.g., via the [feedRepositoryProvider]).
class FeedRepositoryImpl implements FeedRepository {
  /// The remote data source used to fetch and modify feed data.
  final FeedRemoteDataSource remoteDataSource;

  /// Creates a new [FeedRepositoryImpl] instance.
  /// 
  /// [remoteDataSource]: The data source used for remote feed operations.
  FeedRepositoryImpl({required this.remoteDataSource});

  @override
  /// {@macro feed_repository.likePost}
  /// 
  /// This implementation delegates the operation to [FeedRemoteDataSource.likePost]
  /// and propagates any exceptions that may occur during the process.
  Future<void> likePost(String postId) => remoteDataSource.likePost(postId);

  @override
  /// {@macro feed_repository.unlikePost}
  /// 
  /// This implementation delegates the operation to [FeedRemoteDataSource.unlikePost]
  /// and propagates any exceptions that may occur during the process.
  Future<void> unlikePost(String postId) => remoteDataSource.unlikePost(postId);


  @override
  /// {@macro feed_repository.getFeedPosts}
  /// 
  /// This implementation:
  /// 1. Fetches posts from the remote data source
  /// 2. Returns the result directly if successful
  /// 3. Handles and transforms any exceptions into appropriate [AppException]s
  /// 
  /// The method preserves the original [AppException] if one is thrown by the
  /// remote data source, but wraps other exceptions in an [AppException.unexpected].
  Future<List<FeedPostEntity>> getFeedPosts() async {
    try {
      // Delegate to the remote data source and return the result directly
      final result = await remoteDataSource.getFeedPosts();
      return result;
    } on AppException {
      // Re-throw any expected application exceptions
      rethrow;
    } catch (e, stackTrace) {
      // Wrap unexpected errors in an AppException with context
      throw AppException.unexpected(
        'Failed to load feed: $e',
        stackTrace: stackTrace,
      );
    }
  }
}

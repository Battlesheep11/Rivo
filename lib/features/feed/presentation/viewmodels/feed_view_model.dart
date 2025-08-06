import 'dart:developer' as developer;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivo_app_beta/core/error_handling/app_exception.dart';
import 'package:rivo_app_beta/features/feed/domain/entities/feed_post_entity.dart';
import 'package:rivo_app_beta/features/feed/domain/repositories/feed_repository_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


/// Represents the state of the feed in the application.
///
/// This class holds all the necessary state information needed to render the feed,
/// including the list of posts, loading state, and any error messages.
class FeedState {
  /// Indicates whether the feed is currently loading data.
  final bool isLoading;
  
  /// The list of feed posts, or null if no posts have been loaded yet.
  final List<FeedPostEntity>? posts;
  
  /// An error message if an error occurred while loading the feed, or null if no error occurred.
  final String? error;

  /// Creates a new [FeedState] with the given values.
  /// 
  /// All parameters are optional and have sensible defaults.
  const FeedState({
    this.isLoading = false,
    this.posts,
    this.error,
  });

  /// Creates a copy of this state with the given fields replaced by the new values.
  /// 
  /// This is used to immutably update the state.
  FeedState copyWith({
    bool? isLoading,
    List<FeedPostEntity>? posts,
    String? error,
  }) {
    return FeedState(
      isLoading: isLoading ?? this.isLoading,
      posts: posts ?? this.posts,
      error: error,
    );
  }
}

/// Manages the state and business logic for the feed screen.
/// 
/// This view model is responsible for:
/// - Loading and managing the list of feed posts
/// - Handling like/unlike actions
/// - Managing loading and error states
/// - Coordinating with the repository for data operations
class FeedViewModel extends StateNotifier<FeedState> {
  /// The Riverpod container for accessing providers
  final Ref ref;
  
  /// The name used for logging purposes
  static const _logName = 'FeedViewModel';

  /// Creates a new [FeedViewModel] instance.
  /// 
  /// [ref]: The Riverpod container for accessing providers
  FeedViewModel(this.ref) : super(const FeedState(isLoading: true)) {
    loadFeed();
  }

  Future<List<FeedPostEntity>> loadPostsByTag(String tagId) async {
final repository = ref.read(feedRepositoryProvider);
  return await repository.getPostsByTag(tagId);
}

Future<List<FeedPostEntity>> loadPostsByCollection(String collectionId) async {
  final repository = ref.read(feedRepositoryProvider);
  return await repository.getPostsByCollection(collectionId);
}

  /// Loads the feed posts from the repository.
  /// 
  /// This method:
  /// 1. Sets the loading state to true
  /// 2. Fetches posts from the repository
  /// 3. Updates the state with the fetched posts or an error message
  /// 
  /// The method handles different types of errors and updates the state accordingly.
  Future<void> loadFeed() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final repository = ref.read(feedRepositoryProvider);
      final posts = await repository.getFeedPosts();

      state = state.copyWith(
        isLoading: false,
        posts: posts,
        error: null,
      );
    } on AppException catch (e) {
      final error = 'Failed to load feed: ${e.message}';
      developer.log(' $error', name: _logName);
      state = state.copyWith(
        isLoading: false,
        error: error,
      );
    } catch (e, stackTrace) {
      final error = 'An unexpected error occurred: $e';
      developer.log(' $error', name: _logName, error: e, stackTrace: stackTrace);
      state = state.copyWith(
        isLoading: false,
        error: error,
      );
    }
  }


  Future<bool> isCurrentUserSeller() async {
    final repository = ref.read(feedRepositoryProvider);
    return await repository.isCurrentUserSeller();
  }

  /// Refreshes the feed by reloading the posts.
  /// 
  /// This is typically called when the user pulls down to refresh the feed.
  /// It simply delegates to [loadFeed()] but is exposed as a separate method
  /// for better semantics in the UI layer.
  Future<void> refresh() async {
    await loadFeed();
  }

  /// Toggles the like status of a post.
  /// 
  /// This method implements an optimistic UI update pattern:
  /// 1. Immediately updates the UI to reflect the like/unlike action
  /// 2. Sends the request to the server
  /// 3. Reverts the UI if the request fails
  /// 
  /// [postId]: The ID of the post to like/unlike
  Future<void> toggleLike(String postId) async {
    final repository = ref.read(feedRepositoryProvider);
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    final posts = state.posts;
    if (posts == null) return;

  final index = posts.indexWhere((p) => p.id == postId);
  if (index == -1) return;

  final currentPost = posts[index];
  final isLiked = currentPost.isLikedByMe;

  // אופטימיסטי: עדכון מיידי של UI
  final updatedPost = currentPost.copyWith(
    isLikedByMe: !isLiked,
    likeCount: currentPost.likeCount + (isLiked ? -1 : 1),
  );
  final updatedPosts = [...posts]..[index] = updatedPost;
  state = state.copyWith(posts: updatedPosts);

  try {
    if (isLiked) {
      await repository.unlikePost(postId);
    } else {
      await repository.likePost(postId);
    }
  } catch (e, stackTrace) {
    developer.log('Failed to toggle like: $e', name: _logName, error: e, stackTrace: stackTrace);
    // במקרה של כשלון – חזרה למצב הקודם
    final revertedPosts = [...posts]..[index] = currentPost;
    state = state.copyWith(posts: revertedPosts);
  }
}



  


}

/// A Riverpod provider that creates and manages the [FeedViewModel] instance.
///
/// This provider is responsible for:
/// - Creating the [FeedViewModel] instance
/// - Managing its lifecycle
/// - Providing error handling for view model creation
final feedViewModelProvider =
    StateNotifierProvider<FeedViewModel, FeedState>((ref) {
  try {
    return FeedViewModel(ref);
  } catch (e, stackTrace) {
    developer.log(' Error creating FeedViewModel', 
        name: 'FeedViewModel', error: e, stackTrace: stackTrace);
    rethrow;
  }
});

/// A Riverpod provider that provides the list of feed posts.
///
/// This provider is used to access the feed posts from anywhere in the app.
/// It automatically disposes of the cached data when no longer needed.
///
/// The provider handles the loading state and errors internally.
final feedPostsProvider = FutureProvider.autoDispose<List<FeedPostEntity>>((ref) {
  final repository = ref.read(feedRepositoryProvider);
  return repository.getFeedPosts();
});



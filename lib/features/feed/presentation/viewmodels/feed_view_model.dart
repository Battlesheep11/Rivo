import 'dart:developer' as developer;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivo_app/core/error_handling/app_exception.dart';
import 'package:rivo_app/features/feed/domain/entities/feed_post_entity.dart';
import 'package:rivo_app/features/feed/domain/repositories/feed_repository_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class FeedState {
  final bool isLoading;
  final List<FeedPostEntity>? posts;
  final String? error;

  const FeedState({
    this.isLoading = false,
    this.posts,
    this.error,
  });

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

class FeedViewModel extends StateNotifier<FeedState> {
  final Ref ref;
  static const _logName = 'FeedViewModel';

  FeedViewModel(this.ref) : super(const FeedState(isLoading: true)) {
    loadFeed();
  }

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

  Future<void> refresh() async {
    await loadFeed();
  }

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
    print('🔴 LIKE FAILED: $e');
    developer.log('Failed to toggle like: $e', name: _logName, error: e, stackTrace: stackTrace);
    // במקרה של כשלון – חזרה למצב הקודם
    final revertedPosts = [...posts]..[index] = currentPost;
    state = state.copyWith(posts: revertedPosts);
  }
}



  


}

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

final feedPostsProvider = FutureProvider.autoDispose<List<FeedPostEntity>>((ref) {
  final repository = ref.read(feedRepositoryProvider);
  return repository.getFeedPosts();
});

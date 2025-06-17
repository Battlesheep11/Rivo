import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/feed_post_entity.dart';
import '../../domain/repositories/feed_repository_provider.dart';

final feedViewModelProvider = FutureProvider.autoDispose<List<FeedPostEntity>>((ref) async {
  final repository = ref.read(feedRepositoryProvider);
  return repository.getFeedPosts();
});


import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/feed_view_model.dart';
import '../../domain/entities/feed_post_entity.dart';
import 'package:rivo_app/core/widgets/media_renderer_widget.dart';

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(feedViewModelProvider.notifier).loadFeed();
    });
  }

  @override
  Widget build(BuildContext context) {


    final state = ref.watch(feedViewModelProvider);
    final viewModel = ref.read(feedViewModelProvider.notifier);



    return Scaffold(
      extendBody: true,
      body: _buildBody(state, viewModel, context),
    );
  }



  Widget _buildBody(FeedState state, FeedViewModel viewModel, BuildContext context) {
    if (state.isLoading && state.posts == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading feed...'),
          ],
        ),
      );
    }

    if (state.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                'Error loading feed:',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                state.error!,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => viewModel.loadFeed(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final posts = state.posts ?? [];

    if (posts.isEmpty) {
      return const Center(child: Text('No posts available'));
    }

    return RefreshIndicator(
      onRefresh: () => viewModel.refresh(),
      child: PageView.builder(
        scrollDirection: Axis.vertical,
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          return _buildPostItem(post, context);
        },
      ),
    );
  }

  Widget _buildPostItem(FeedPostEntity post, BuildContext context) {
    return Stack(
      children: [
        if (post.mediaUrls.isNotEmpty)
          MediaRendererWidget(
urls: post.mediaUrls,
          ),
        Positioned(
          bottom: 40,
          left: 16,
          right: 16,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              CircleAvatar(
                backgroundImage: post.avatarUrl != null ? NetworkImage(post.avatarUrl!) : null,
                child: post.avatarUrl == null ? const Icon(Icons.person) : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      post.username,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (post.caption != null && post.caption!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        post.caption!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.favorite_border, color: Colors.white),
                    onPressed: () {
                      // TODO: Implement like functionality
                    },
                  ),
                  Text(
                    '${post.likeCount}',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

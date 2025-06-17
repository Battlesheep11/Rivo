import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/feed_view_model.dart';
import '../../domain/entities/feed_post_entity.dart';
import 'package:rivo_app/features/feed/presentation/widgets/video_player_widget.dart';

class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedAsync = ref.watch(feedViewModelProvider);

    return Scaffold(
      body: feedAsync.when(
        data: (posts) => PageView.builder(
          scrollDirection: Axis.vertical,
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final FeedPostEntity post = posts[index];
            return Stack(
              children: [
                PageView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: post.mediaUrls.length,
                  itemBuilder: (context, mediaIndex) {
                    final mediaUrl = post.mediaUrls[mediaIndex];

                    if (isVideo(mediaUrl)) {
                      return VideoPlayerWidget(url: mediaUrl);
                    } else {
                      return Image.network(
                        mediaUrl,
                        fit: BoxFit.cover,
                        height: double.infinity,
                        width: double.infinity,
                      );
                    }
                  },
                ),
                Positioned(
                  bottom: 40,
                  left: 16,
                  right: 16,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(post.avatarUrl),
                        radius: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              post.username,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                shadows: [Shadow(blurRadius: 5, color: Colors.black)],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              post.caption,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                shadows: [Shadow(blurRadius: 5, color: Colors.black)],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      FloatingActionButton(
                        onPressed: () {
                          // נכניס לוגיקה של Add to Cart בהמשך
                        },
                        mini: true,
                        backgroundColor: Colors.white,
                        child: const Icon(Icons.shopping_cart, color: Colors.black),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  bool isVideo(String url) {
    return url.toLowerCase().endsWith('.mp4');
  }
}

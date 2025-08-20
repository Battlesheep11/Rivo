import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivo_app_beta/core/localization/generated/app_localizations.dart';
import 'package:rivo_app_beta/features/feed/presentation/viewmodels/feed_view_model.dart';
import 'package:rivo_app_beta/features/feed/domain/entities/feed_post_entity.dart';
import 'package:rivo_app_beta/core/widgets/media_renderer_widget.dart';
import 'package:rivo_app_beta/features/feed/presentation/widgets/image_gallery.dart';
import 'package:rivo_app_beta/features/feed/presentation/widgets/caption_glass_box.dart';
import 'package:rivo_app_beta/features/feed/presentation/widgets/post_action_column.dart';
import 'package:go_router/go_router.dart';

class FilteredFeedScreen extends ConsumerStatefulWidget {
  final String? tagId;
  final String? collectionId;

  const FilteredFeedScreen({
    super.key,
    this.tagId,
    this.collectionId,
  }) : assert(tagId != null || collectionId != null,
        'Either tagId or collectionId must be provided');

  @override
  ConsumerState<FilteredFeedScreen> createState() => _FilteredFeedScreenState();
}

class _FilteredFeedScreenState extends ConsumerState<FilteredFeedScreen> {
  final Map<String, bool> _postTextBoxVisibility = {};
  final PageController _pageController = PageController();
  late Future<List<FeedPostEntity>> _postsFuture;

  @override
  void initState() {
    super.initState();
    final viewModel = ref.read(feedViewModelProvider.notifier);
    if (widget.tagId != null) {
      _postsFuture = viewModel.loadPostsByTag(widget.tagId!);
    } else {
      _postsFuture = viewModel.loadPostsByCollection(widget.collectionId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      extendBody: true,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.trendingNow),
      ),
      body: FutureBuilder<List<FeedPostEntity>>(
        future: _postsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.data!.isEmpty) {
            return Center(child: Text(AppLocalizations.of(context)!.noPostsAvailable));
          }

          final posts = snapshot.data!;
          return PageView.builder(
            scrollDirection: Axis.vertical,
            controller: _pageController,
            itemCount: posts.length,
            itemBuilder: (context, index) {
              return _buildPostItem(posts[index], context);
            },
            key: const PageStorageKey('filtered_feed_page_view'),
          );
        },
      ),
    );
  }

  Widget _buildPostItem(FeedPostEntity post, BuildContext context) {
    final isVisible = _postTextBoxVisibility.putIfAbsent(post.id, () => true);

    return GestureDetector(
      onTap: () {
        setState(() {
          _postTextBoxVisibility[post.id] = !isVisible;
        });
      },
      onDoubleTap: () {
        if (post.productId != null) {
          context.push('/product/${post.id}');
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black.withAlpha(13), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(26),
              blurRadius: 25,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: Colors.black.withAlpha(26),
              blurRadius: 10,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (post.mediaUrls.length > 1)
                Positioned.fill(
                  child: ImageGallery(
                    urls: post.mediaUrls.reversed.toList(),
                  ),
                ),
              if (post.mediaUrls.length == 1)
                MediaRendererWidget(
                  urls: post.mediaUrls,
                ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: AnimatedOpacity(
                  opacity: isVisible ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: CaptionGlassBox(
                    title: post.productTitle,
                    seller: post.username,
                    price: '\$${post.productPrice.toStringAsFixed(2)}',
                    height: MediaQuery.of(context).size.height / 3.5,
                  ),
                ),
              ),
              Positioned(
                right: 10,
                bottom: 20,
                child: PostActionColumn(
                  isLikedByMe: post.isLikedByMe,
                  likeCount: post.likeCount,
                  onLike: () => ref.read(feedViewModelProvider.notifier).toggleLike(post.id),
                  onComment: () {},
                  onAdd: () {},
                  avatarUrl: post.avatarUrl,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

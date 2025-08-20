import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivo_app_beta/core/localization/generated/app_localizations.dart';
import '../viewmodels/feed_view_model.dart';
import '../../domain/entities/feed_post_entity.dart';
import 'package:rivo_app_beta/core/widgets/media_renderer_widget.dart';
import '../widgets/image_gallery.dart';
import '../widgets/caption_glass_box.dart';
import '../widgets/post_action_column.dart';
import 'package:rivo_app_beta/core/presentation/providers/nav_bar_provider.dart';
import 'custom_page_scroll_physics.dart';
import 'package:go_router/go_router.dart';

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({
    super.key,
    this.onGlassBoxToggled,
  });

  final VoidCallback? onGlassBoxToggled;

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  final Map<String, bool> _postTextBoxVisibility = {};
  final PageController _pageController = PageController();
  double _lastScrollPosition = 0;
  bool _isUserDragging = false;
  bool _isGalleryScrolling = false;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (!_pageController.hasClients) return;

    final currentPage = _pageController.page ?? _lastScrollPosition;
    final scrollDelta = currentPage - _lastScrollPosition;
    const scrollThreshold = 0.01;

    final isNavBarVisible = ref.read(navBarVisibilityProvider);

    if (_isUserDragging && !_isGalleryScrolling) {
      if (scrollDelta > scrollThreshold && isNavBarVisible) {
        ref.read(navBarVisibilityProvider.notifier).state = false;
      } else if (scrollDelta < -scrollThreshold && !isNavBarVisible) {
        ref.read(navBarVisibilityProvider.notifier).state = true;
      }
    }

    _lastScrollPosition = currentPage;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(feedViewModelProvider);
    final viewModel = ref.read(feedViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      extendBody: true,
      appBar: AppBar(
        titleSpacing: 16.0,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocalizations.of(context)!.navBarHome,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            FutureBuilder<bool>(
              future: ref.read(feedViewModelProvider.notifier).isCurrentUserSeller(),
              builder: (context, snapshot) {
                final isSeller = snapshot.data ?? false;
                if (!isSeller) return const SizedBox.shrink();
                return IconButton(
                  icon: const Icon(Icons.add),
                  tooltip: AppLocalizations.of(context)!.upload,
                  onPressed: () => context.go('/upload'),
                );
              },
            ),
          ],
        ),
      ),
      body: _buildBody(state, viewModel, context),
    );
  }

  Widget _buildBody(FeedState state, FeedViewModel viewModel, BuildContext context) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(AppLocalizations.of(context)!.feedError(state.error!)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: viewModel.loadFeed,
              child: Text(AppLocalizations.of(context)!.retry),
            ),
          ],
        ),
      );
    }

    if (state.posts?.isEmpty ?? true) {
      return Center(child: Text(AppLocalizations.of(context)!.noPostsAvailable));
    }

    return SafeArea(
      bottom: true,
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollStartNotification) {
            _isUserDragging = true;
          } else if (notification is ScrollEndNotification) {
            _isUserDragging = false;
          }
          return false;
        },
        child: RefreshIndicator(
          onRefresh: viewModel.loadFeed,
          child: PageView.builder(
            scrollDirection: Axis.vertical,
            itemCount: state.posts?.length ?? 0,
            controller: _pageController,
            physics: const CustomPageScrollPhysics(),
            itemBuilder: (context, index) {
              return _buildPostItem(state.posts![index], context);
            },
            key: const PageStorageKey('feed_page_view'),
          ),
        ),
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
              if (post.mediaUrls.isNotEmpty && post.mediaUrls.length > 1)
                Positioned.fill(
                  child: ImageGallery(
                    urls: post.mediaUrls.reversed.toList(),
                    onUserScroll: () {
                      _isGalleryScrolling = true;
                      Future.delayed(const Duration(milliseconds: 600), () {
                        if (mounted) setState(() => _isGalleryScrolling = false);
                      });
                    },
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
                  opacity: isVisible ? 1 : 0.0,
                  duration: const Duration(milliseconds: 300),
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

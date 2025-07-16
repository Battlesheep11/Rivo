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



/// The main screen that displays a vertical feed of posts.
/// 
/// This screen uses a [PageView] with vertical scrolling to display a feed of posts.
/// Each post can contain media (images/videos), a caption, and like functionality.
/// The screen handles loading states, error states, and empty states appropriately.
class FeedScreen extends ConsumerStatefulWidget {
  /// Creates a new [FeedScreen] instance.
  /// 
  /// [key]: An optional key for widget testing and identification
  /// [onGlassBoxToggled]: Callback when the glass box visibility is toggled
  const FeedScreen({
    super.key, 
    this.onGlassBoxToggled,
  });

  /// Callback function that's called when the glass box visibility is toggled
  final VoidCallback? onGlassBoxToggled;

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  bool _isTextBoxVisible = true;
  final PageController _pageController = PageController();
  double _lastScrollPosition = 0;
  bool _isUserDragging = false;
  bool _isGalleryScrolling = false; // Flag to block nav bar logic during gallery scroll

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
    const double scrollThreshold = 0.01;

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
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            AppLocalizations.of(context)!.navBarHome,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: _buildBody(state, viewModel, context),
    );
  }

  /// Builds the appropriate widget based on the current feed state.
  /// 
  /// This method handles different states of the feed:
  /// - Loading state (with a loading indicator)
  /// - Error state (with retry option)
  /// - Empty state (when no posts are available)
  /// - Content state (displaying the list of posts)
  /// 
  /// [state]: The current state of the feed
  /// [viewModel]: The view model for feed operations
  /// [context]: The build context
  /// 
  /// Returns a widget that represents the current state of the feed
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

    // Wrap feed content in SafeArea to avoid overlap with system navigation bar
    return SafeArea(
      bottom: true, // Only apply padding at the bottom
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollStartNotification) {
            _isUserDragging = true;
          } else if (notification is ScrollEndNotification) {
            _isUserDragging = false;
          }
          return false;
        },
        child: PageView.builder(
          scrollDirection: Axis.vertical,
          itemCount: state.posts?.length ?? 0,
          controller: _pageController,
          itemBuilder: (context, index) {
            return _buildPostItem(state.posts![index], context);
          },
          key: const PageStorageKey('feed_page_view'),
        ),
      ),
    );
  }

  /// Builds a single post item in the feed.
  ///
  /// This widget displays:
  /// - The post media (image/video) in a styled container
  /// - The poster's avatar and username
  /// - The post caption (if available)
  /// - Like button with like count
  ///
  /// [post]: The post data to display
  /// [context]: The build context
  ///
  /// Returns a widget that represents a single post in the feed
  Widget _buildPostItem(FeedPostEntity post, BuildContext context) {
    // GestureDetector to toggle the visibility of the caption overlay on tap.
    return GestureDetector(
      onTap: () {
        setState(() {
          _isTextBoxVisible = !_isTextBoxVisible;
        });
        // Notify parent when glass box is toggled (hidden or shown)
        widget.onGlassBoxToggled?.call();
        
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black.withAlpha(13), width: 1), // 0.05 * 255 ≈ 13 alpha value
          boxShadow: [
            // Primary shadow (0 10px 25px -5px rgba(0,0,0,0.1))
            BoxShadow(
              color: Colors.black.withAlpha(26), // 0.1 * 255 ≈ 26 alpha value
              blurRadius: 25,
              offset: const Offset(0, 10),
            ),
            // Secondary shadow (0 8px 10px -6px rgba(0,0,0,0.1))
            BoxShadow(
              color: Colors.black.withAlpha(26), // 0.1 * 255 ≈ 26 alpha value
              blurRadius: 10,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        // Padding for the entire post card.
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Display the post's media (image/video) as the background.
              // If multiple images, show as a horizontal PageView with indicator
              if (post.mediaUrls.isNotEmpty && post.mediaUrls.length > 1)
                Positioned.fill(
                  child: ImageGallery(
                    urls: post.mediaUrls,
                    onUserScroll: () {
                      // Set a flag to ignore nav bar logic during gallery scroll
                      _isGalleryScrolling = true;
                      Future.delayed(const Duration(milliseconds: 600), () {
                        // Reset after a short period
                        if (mounted) setState(() => _isGalleryScrolling = false);
                      });
                    },
                  ),
                ),
              // If single image or video, show as before
              if (post.mediaUrls.length == 1)
                MediaRendererWidget(
                  urls: post.mediaUrls,
                ),

              // Bottom overlay for the post's caption and title (glass box).
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: AnimatedOpacity(
                  opacity: _isTextBoxVisible ? 1 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: CaptionGlassBox(
                    username: post.username,
                    caption: post.caption,
                    height: MediaQuery.of(context).size.height / 5,
                  ),
                ),
              ),

              // Right-side column for action buttons (like, comment, add, avatar) -- MOVED TO FOREGROUND.
              Positioned(
                right: 10,
                bottom: 20,
                child: PostActionColumn(
                  isLikedByMe: post.isLikedByMe,
                  likeCount: post.likeCount,
                  onLike: () => ref.read(feedViewModelProvider.notifier).toggleLike(post.id),
                  onComment: () {}, // TODO: Implement comment
                  onAdd: () {}, // TODO: Implement add to list
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

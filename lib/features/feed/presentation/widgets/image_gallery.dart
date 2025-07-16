import 'package:flutter/material.dart';
import 'package:rivo_app_beta/core/widgets/media_renderer_widget.dart';

/// A horizontally swipeable image gallery with a smooth indicator for feed posts with multiple images.
///
/// [urls]: List of image URLs to display
typedef OnGalleryScroll = void Function();

class ImageGallery extends StatefulWidget {
  final List<String> urls;
  final OnGalleryScroll? onUserScroll;
  const ImageGallery({super.key, required this.urls, this.onUserScroll});

  @override
  State<ImageGallery> createState() => _ImageGalleryState();
}

class _ImageGalleryState extends State<ImageGallery> {
  late final PageController _pageController;
  int _currentIndex = 0;


  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pageController.addListener(() {
      if (_pageController.page?.round() != _currentIndex) {
        setState(() {
          _currentIndex = _pageController.page!.round();
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Only allow horizontal drag, so vertical drags pass through to parent
      onHorizontalDragStart: (_) {
        widget.onUserScroll?.call();
      },
      onHorizontalDragEnd: (_) {
      },
      behavior: HitTestBehavior.translucent,
      child: Stack(
        children: [
          NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              // Prevent vertical scroll notifications from bubbling up
              if (notification.metrics.axis == Axis.horizontal) {
                return true; // absorb horizontal scroll
              }
              return false;
            },
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.urls.length,
              physics: const PageScrollPhysics(), // No animation on load, normal scroll
              onPageChanged: (i) => setState(() => _currentIndex = i),
              itemBuilder: (context, i) => MediaRendererWidget(urls: [widget.urls[i]]),
            ),
          ),
          // Indicator at top center
          if (widget.urls.length > 1) // Only show indicator if there are multiple images
            Positioned(
              top: 12,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(widget.urls.length, (i) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i == _currentIndex ? Colors.white : Colors.white.withAlpha(153), // 60% opacity for inactive dots
                      border: Border.all(color: Colors.black26, width: 0.5),
                    ),
                  )),
                ),
              ),
            )
        ],
      ),
    );
  }
}

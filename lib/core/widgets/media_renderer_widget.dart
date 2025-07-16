import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'video_player_widget.dart';

class MediaRendererWidget extends StatefulWidget {
  final List<String> urls;

  const MediaRendererWidget({super.key, required this.urls});

  @override
  State<MediaRendererWidget> createState() => _MediaRendererWidgetState();
}

class _MediaRendererWidgetState extends State<MediaRendererWidget> {
  int _currentIndex = 0;

  bool _isVideo(String url) {
    final path = Uri.parse(url).path.toLowerCase();
    return path.contains('.mp4') || path.contains('.mov') || path.contains('.webm');
  }

  @override
  Widget build(BuildContext context) {
    if (widget.urls.isEmpty) {
      return const Center(child: Icon(Icons.broken_image));
    }

    final currentUrl = widget.urls[_currentIndex];

    Widget mediaWidget;
    if (_isVideo(currentUrl)) {
      mediaWidget = VideoPlayerWidget(url: currentUrl);
    } else {
      // Use CachedNetworkImage for efficient image loading and caching
      mediaWidget = CachedNetworkImage(
        imageUrl: currentUrl,
        // Cover the entire container while maintaining aspect ratio
        fit: BoxFit.cover,
        // Show loading indicator while image loads
        placeholder: (context, url) => Container(
          color: Colors.black12,
          child: const Center(child: CircularProgressIndicator()),
        ),
        // Show broken image icon if loading fails
        errorWidget: (context, url, error) => Container(
          color: Colors.black12,
          child: const Center(child: Icon(Icons.broken_image)),
        ),
        // Enable disk caching for offline access
        cacheKey: currentUrl,
        // Quick fade transitions for smooth experience
        fadeOutDuration: const Duration(milliseconds: 100),
        fadeInDuration: const Duration(milliseconds: 100),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          Positioned.fill(child: mediaWidget),
        if (widget.urls.length > 1)
          Positioned(
            bottom: 16,
            right: 16,
            child: Row(
              children: List.generate(widget.urls.length, (index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: index == _currentIndex ? Colors.white : Colors.grey,
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

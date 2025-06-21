import 'package:flutter/material.dart';
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
      mediaWidget = Image.network(
        currentUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return const Center(child: Icon(Icons.broken_image));
        },
        loadingBuilder: (context, child, progress) {
          if (progress == null) {
            return child;
          }
          return const Center(child: CircularProgressIndicator());
        },
      );
    }

    return Stack(
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
    );
  }
}

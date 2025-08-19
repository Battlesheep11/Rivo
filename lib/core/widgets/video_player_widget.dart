import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:rivo_app_beta/core/cache/video_cache_manager.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String url;

  const VideoPlayerWidget({super.key, required this.url});

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _hadError = false;

  @override
  void initState() {
    super.initState();
    _setupController();
  }

  // Initialize the controller using a cached file when possible.
  // Falls back to network for HLS streams or on errors.
  Future<void> _setupController() async {
    try {
      final uri = Uri.parse(widget.url);
      // HLS streams (m3u8) or non-http(s) are not cached.
      final isHls = uri.path.toLowerCase().endsWith('.m3u8');
      final isHttp = uri.scheme == 'http' || uri.scheme == 'https';

      if (!isHls && isHttp) {
        // Cacheable full-file formats (mp4/mov/webm, etc.)
        final File file = await VideoCacheManager().getVideoFile(widget.url);
        _controller = VideoPlayerController.file(file);
      } else {
        // Fallback to streaming over network.
        _controller = VideoPlayerController.networkUrl(uri);
      }

      await _controller.initialize();
      if (!mounted) return;
      setState(() {
        _isInitialized = true;
      });
      // Autoplay + loop to mirror previous behavior.
      _controller
        ..setLooping(true)
        ..play();
    } catch (e) {
      // On failure, attempt a last-resort network init.
      try {
        final uri = Uri.parse(widget.url);
        _controller = VideoPlayerController.networkUrl(uri);
        await _controller.initialize();
        if (!mounted) return;
        setState(() {
          _isInitialized = true;
          _hadError = false;
        });
        _controller
          ..setLooping(true)
          ..play();
      } catch (_) {
        if (!mounted) return;
        setState(() {
          _hadError = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hadError) {
      return const Center(child: Icon(Icons.broken_image));
    }
    if (!_isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: _controller.value.size.width,
          height: _controller.value.size.height,
          child: VideoPlayer(_controller),
        ),
      ),
    );
  }
}

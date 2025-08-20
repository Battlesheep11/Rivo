// A lightweight, reusable cache manager for video files.
// Mirrors the behavior of image caching (via cached_network_image)
// by storing fetched videos on disk for reuse across sessions.
//
// Notes:
// - This caches whole-file assets (e.g., MP4/MOV/WEBM). Streaming formats
//   like HLS (m3u8) are not cached by this manager.
// - Adjust stalePeriod / maxNrOfCacheObjects to fit your product needs.
// - You can pre-warm the cache by calling preCache(url) anywhere suitable
//   (e.g., right after fetching a feed).

import 'dart:io';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class VideoCacheManager extends CacheManager {
  // Unique cache key for the video cache bucket.
  static const String key = 'videoCache';

  // Singleton instance for convenient global access.
  static final VideoCacheManager _instance = VideoCacheManager._internal();

  factory VideoCacheManager() => _instance;

  VideoCacheManager._internal()
      : super(
          Config(
            key,
            // Videos are typically heavier; keep a sensible retention window.
            stalePeriod: const Duration(days: 7),
            // Tune this based on avg video count/size in the app.
            maxNrOfCacheObjects: 100,
            // Default HTTP file service; customize headers if needed.
            fileService: HttpFileService(),
          ),
        );

  // Returns the cached file for the given URL, downloading if absent.
  Future<File> getVideoFile(String url) {
    return getSingleFile(url);
  }

  // Optional: observe download progress using the stream-based API.
  Stream<FileResponse> getVideoFileStream(
    String url, {
    bool withProgress = false,
  }) {
    return getFileStream(url, withProgress: withProgress);
  }

  // Warm up the cache for a specific URL.
  Future<void> preCache(String url) async {
    await getSingleFile(url);
  }

  // Remove a single cached entry.
  Future<void> evict(String url) => removeFile(url);

  // Clear the entire video cache bucket.
  Future<void> clearAll() => emptyCache();
}

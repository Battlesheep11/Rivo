import 'package:flutter/foundation.dart';

/// A simple in-memory cache for storing thumbnail data.
/// This helps prevent re-fetching thumbnails for gallery items during rebuilds,
/// which is a common cause of flickering.
class ThumbnailCache {
  final Map<String, Uint8List> _cache = {};

  /// Retrieves thumbnail data from the cache for a given asset ID.
  /// Returns null if the thumbnail is not in the cache.
  Uint8List? get(String assetId) {
    return _cache[assetId];
  }

  /// Adds or updates a thumbnail in the cache.
  void set(String assetId, Uint8List data) {
    _cache[assetId] = data;
  }

  /// Clears all items from the cache.
  /// This can be called when the gallery screen is disposed to free up memory.
  void clear() {
    _cache.clear();
    debugPrint('Thumbnail cache cleared.');
  }
}


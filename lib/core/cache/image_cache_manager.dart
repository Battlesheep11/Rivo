// A reusable cache manager for images with a 7-day TTL.
// Ensures time-based eviction for network images used by CachedNetworkImage.
// Notes:
// - Works alongside Flutter's in-memory ImageCache (size-based). This file
//   manages on-disk persistence and staleness.

import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class ImageCacheManager extends CacheManager {
  static const String key = 'imageCache';

  static final ImageCacheManager _instance = ImageCacheManager._internal();

  factory ImageCacheManager() => _instance;

  ImageCacheManager._internal()
      : super(
          Config(
            key,
            stalePeriod: Duration(days: 7),
            // Tune this depending on usage patterns
            maxNrOfCacheObjects: 300,
            fileService: HttpFileService(),
          ),
        );
}

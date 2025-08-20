import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:rivo_app_beta/core/cache/image_cache_manager.dart';

class FeaturedCardBase extends StatelessWidget {
  final String imageUrl;
  final Widget overlay;
  final VoidCallback? onTap;
  final double borderRadius;
  final double aspectRatio;

  const FeaturedCardBase({
    super.key,
    required this.imageUrl,
    required this.overlay,
    this.onTap,
    this.borderRadius = 28,
    this.aspectRatio = 3 / 3.4,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: Stack(
            children: [
              // רקע תמונה
              Positioned.fill(
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  cacheManager: ImageCacheManager(), // 7-day TTL disk cache
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) => const ColoredBox(
                    color: Colors.grey,
                    child: Center(
                      child: Icon(Icons.image, size: 32, color: Colors.white),
                    ),
                  ),
                ),
              ),

              // שכבת גרדיאנט
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withAlpha((0.7 * 255).round()),
                      ],
                    ),
                  ),
                ),
              ),

              // תוכן
Positioned.fill(
  child: Padding(
    padding: const EdgeInsets.all(24),
    child: Column(
  mainAxisAlignment: MainAxisAlignment.end,
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    overlay,
  ],
),

  ),
),

            ],
          ),
        ),
      ),
    );
  }
}

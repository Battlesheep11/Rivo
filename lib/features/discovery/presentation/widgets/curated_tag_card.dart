import 'package:flutter/material.dart';
import 'package:rivo_app_beta/design_system/exports.dart';
import 'package:rivo_app_beta/features/discovery/domain/entities/discovery_tag_entity.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:rivo_app_beta/core/cache/image_cache_manager.dart';

class CuratedTagCard extends StatelessWidget {
  final DiscoveryTagEntity tag;
  final VoidCallback? onTap;

  const CuratedTagCard({
    super.key,
    required this.tag,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: 20,
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: Stack(
        alignment: Alignment.bottomLeft,
        children: [
          if (tag.imageUrl != null && tag.imageUrl!.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: CachedNetworkImage(
                imageUrl: tag.imageUrl!,
                cacheManager: ImageCacheManager(),
                width: double.infinity,
                height: 120,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => Container(
                  height: 120,
                  width: double.infinity,
                  color: Colors.grey[300],
                  child: const Center(
                    child: Icon(Icons.image, color: Colors.white),
                  ),
                ),
              ),
            )
          else
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: GlassText(
              text: tag.name,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

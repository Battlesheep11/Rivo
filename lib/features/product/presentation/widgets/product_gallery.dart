import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:rivo_app_beta/core/cache/image_cache_manager.dart';

class ProductGallery extends StatefulWidget {
  const ProductGallery({super.key, required this.imageUrls});

  final List<String> imageUrls;

  @override
  State<ProductGallery> createState() => _ProductGalleryState();
}

class _ProductGalleryState extends State<ProductGallery> {
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 400,
      child: Stack(
        children: [
          PageView.builder(
            itemCount: widget.imageUrls.length,
            onPageChanged: (page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemBuilder: (context, index) {
              return CachedNetworkImage(
                imageUrl: widget.imageUrls[index],
                cacheManager: ImageCacheManager(),
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => const ColoredBox(
                  color: Colors.grey,
                  child: Center(child: Icon(Icons.image, color: Colors.white)),
                ),
              );
            },
          ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.imageUrls.length, (index) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha((_currentPage == index ? 255 : 153)),
                    borderRadius: BorderRadius.circular(4),
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

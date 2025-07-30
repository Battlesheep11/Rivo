import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'thumbnail_cache.dart';

/// A grid item for the media gallery that uses a cache to prevent thumbnail flickering.
class GalleryGridItem extends StatefulWidget {
  final AssetEntity asset;
  final bool isSelected;
  final VoidCallback onTap;
  final ThumbnailCache cache;

  const GalleryGridItem({
    super.key,
    required this.asset,
    required this.isSelected,
    required this.onTap,
    required this.cache,
  });

  @override
  State<GalleryGridItem> createState() => _GalleryGridItemState();
}

class _GalleryGridItemState extends State<GalleryGridItem> {
  Uint8List? _thumbnailData;


  @override
  void initState() {
    super.initState();
    _loadThumbnail();
  }

  @override
  void didUpdateWidget(GalleryGridItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the asset itself changes (e.g., in a different kind of gallery), reload the thumbnail.
    if (widget.asset.id != oldWidget.asset.id) {
      // Reset thumbnail data to show loading indicator while new one loads
      setState(() {
        _thumbnailData = null;
      });
      _loadThumbnail();
    }
  }

  Future<void> _loadThumbnail() async {
    // First, check if the thumbnail is already in the cache.
    final cachedData = widget.cache.get(widget.asset.id);
    if (cachedData != null) {
      if (mounted) {
        setState(() {
          _thumbnailData = cachedData;
        });
      }
      return;
    }

    // If not in cache, fetch the thumbnail data from the asset.
    final data = await widget.asset.thumbnailDataWithSize(const ThumbnailSize(400, 300));

    if (data != null) {
      // Store the newly fetched data in the cache.
      widget.cache.set(widget.asset.id, data);
      if (mounted) {
        setState(() {
          _thumbnailData = data;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: widget.onTap,
      child: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          fit: StackFit.expand,
        children: [
          // Display the thumbnail if it's loaded, otherwise show a placeholder.
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 10),
            child: _thumbnailData != null
                ? Image.memory(
                    _thumbnailData!,
                    key: ValueKey(_thumbnailData!),
                    fit: BoxFit.cover, // Fills the square cell, cropping as needed
                    width: double.infinity,
                    height: double.infinity,
                  )
                : Container(
                    key: const ValueKey('placeholder'),
                    color: Colors.transparent, // Transparent for seamless look
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2.0, color: Colors.white54),
                    ),
                  ),
          ),

          // Show a selection overlay if the item is selected.
          if (widget.isSelected)
            Container(
              color: Colors.black.withAlpha(128), // 50% opacity
              child: const Center(
                child: Icon(Icons.check_circle, color: Colors.white, size: 32),
              ),
            ),
        ],
      ),
    ),
  );
}
}

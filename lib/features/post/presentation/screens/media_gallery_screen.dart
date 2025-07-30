import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:rivo_app_beta/core/localization/generated/app_localizations.dart';
import 'package:rivo_app_beta/core/media/domain/entities/uploadable_media.dart';
import 'package:rivo_app_beta/core/utils/permission_utils.dart';
import 'gallery_grid_item.dart';
import 'thumbnail_cache.dart';

class MediaGalleryScreen extends StatefulWidget {
  const MediaGalleryScreen({super.key});

  @override
  State<MediaGalleryScreen> createState() => _MediaGalleryScreenState();
}

class _MediaGalleryScreenState extends State<MediaGalleryScreen> {
  List<AssetEntity> _mediaAssets = [];
  final Set<AssetEntity> _selectedAssets = {};
  bool _initialized = false;
  bool _isLoading = false;
  final ThumbnailCache _thumbnailCache = ThumbnailCache();

  @override
  void dispose() {
    // Clear the cache when the screen is disposed
    _thumbnailCache.clear();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _loadMedia();
      _initialized = true;
    }
  }

  Future<void> _loadMedia() async {
    final tr = AppLocalizations.of(context)!;
    setState(() {
      _isLoading = true;
    });
    final granted = await PermissionUtils.requestPhotoLibraryPermission();
    if (!granted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(tr.galleryPermissionMessage)),
        );
      }
      setState(() {
        _isLoading = false;
      });
      return;
    }
    final albums = await PhotoManager.getAssetPathList(
      type: RequestType.common,
      hasAll: true,
    );
    debugPrint('📁 Found ${albums.length} albums');
    for (final album in albums) {
      final count = await album.assetCountAsync;
      debugPrint('🖼️ Album: ${album.name} | $count assets');
    }
    final recentAlbum = albums.firstOrNull;
    if (recentAlbum == null) {
      debugPrint('⚠️ No albums found');
      setState(() {
        _mediaAssets = [];
        _isLoading = false;
      });
      return;
    }
    final assets = await recentAlbum.getAssetListPaged(page: 0, size: 100);
    debugPrint('📷 Loaded ${assets.length} assets from ${recentAlbum.name}');
    setState(() {
      _mediaAssets = assets;
      _isLoading = false;
    });
  }

  void _toggleSelection(AssetEntity asset) {
    setState(() {
      if (_selectedAssets.contains(asset)) {
        _selectedAssets.remove(asset);
      } else {
        _selectedAssets.add(asset);
      }
    });
  }

  Future<void> _handleConfirm() async {
    final navigator = Navigator.of(context);
    final result = <UploadableMedia>[];
    for (final asset in _selectedAssets) {
      final type = asset.type == AssetType.video ? MediaType.video : MediaType.image;
      result.add(UploadableMedia(
        id: asset.id,
        asset: asset,
        type: type,
      ));
    }
    navigator.pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(tr.selectMedia),
        actions: [
          if (_selectedAssets.isNotEmpty)
            TextButton(
              onPressed: _handleConfirm,
              child: Text(tr.confirm.toUpperCase()),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _mediaAssets.isEmpty
                    ? Center(child: Text(tr.noMediaFoundInGallery))
                    : GridView.builder(
                        itemCount: _mediaAssets.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4, // Set to 4 items per row
                          mainAxisSpacing: 0,
                          crossAxisSpacing: 0,
                          childAspectRatio: 1.0, // Force perfect squares
                        ),
                        itemBuilder: (context, index) {
                          final asset = _mediaAssets[index];
                          return GalleryGridItem(
                            asset: asset,
                            isSelected: _selectedAssets.contains(asset),
                            onTap: () => _toggleSelection(asset),
                            cache: _thumbnailCache, // Pass the cache instance
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

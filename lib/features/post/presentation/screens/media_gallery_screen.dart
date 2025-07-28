import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:rivo_app_beta/core/localization/generated/app_localizations.dart';
import 'package:rivo_app_beta/core/media/domain/entities/uploadable_media.dart';
import 'package:rivo_app_beta/core/utils/permission_utils.dart';

class MediaGalleryScreen extends StatefulWidget {
  const MediaGalleryScreen({super.key});

  @override
  State<MediaGalleryScreen> createState() => _MediaGalleryScreenState();
}

class _MediaGalleryScreenState extends State<MediaGalleryScreen> {
  List<AssetEntity> _mediaAssets = [];
  final Set<AssetEntity> _selectedAssets = {};

  bool _initialized = false;

@override
void didChangeDependencies() {
  super.didChangeDependencies();

  if (!_initialized) {
    _loadMedia(); // קורא ל־AppLocalizations ועוד
    _initialized = true;
  }
}


  

  Future<void> _loadMedia() async {
    final tr = AppLocalizations.of(context)!;
    final granted = await PermissionUtils.requestPhotoLibraryPermission();

    if (!granted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(tr.galleryPermissionMessage)),
        );
      }
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
      return;
    }

    final assets = await recentAlbum.getAssetListPaged(page: 0, size: 100);
    debugPrint('📷 Loaded ${assets.length} assets from ${recentAlbum.name}');

    setState(() {
      _mediaAssets = assets;
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
            child: _mediaAssets.isEmpty
                ? Center(child: Text(tr.noMediaFoundInGallery))
                : GridView.builder(
              itemCount: _mediaAssets.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 2,
                crossAxisSpacing: 2,
              ),
              itemBuilder: (context, index) {
                final asset = _mediaAssets[index];
                final isSelected = _selectedAssets.contains(asset);

                return GestureDetector(
                  onTap: () => _toggleSelection(asset),
                  child: Stack(
                    children: [
                      FutureBuilder<Uint8List?>(
                        future: asset.thumbnailDataWithSize(const ThumbnailSize(200, 200)),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          return Image.memory(
                            snapshot.data!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          );
                        },
                      ),
                      if (isSelected)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color.fromRGBO(33, 150, 243, 0.8),
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(4),
                            child: const Icon(Icons.check, size: 16, color: Colors.white),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

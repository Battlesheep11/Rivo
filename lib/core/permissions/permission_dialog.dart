import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:rivo_app_beta/core/localization/generated/app_localizations.dart';
import 'package:rivo_app_beta/core/media/domain/entities/uploadable_media.dart';
import 'package:rivo_app_beta/core/utils/permission_utils.dart';
import 'package:rivo_app_beta/features/post/presentation/screens/gallery_grid_item.dart';
import 'package:rivo_app_beta/features/post/presentation/screens/thumbnail_cache.dart';


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

    // Gallery permission (Photo Library)
    final granted = await PermissionUtils.requestPhotoLibraryPermission();
    if (!granted) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr.galleryPermissionMessage)),
      );
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
      if (!mounted) return;
      setState(() {
        _mediaAssets = [];
        _isLoading = false;
      });
      return;
    }
    final assets = await recentAlbum.getAssetListPaged(page: 0, size: 100);
    debugPrint('📷 Loaded ${assets.length} assets from ${recentAlbum.name}');
    if (!mounted) return;
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
      final type =
          asset.type == AssetType.video ? MediaType.video : MediaType.image;
      result.add(
        UploadableMedia(
          id: asset.id,
          asset: asset,
          type: type,
        ),
      );
    }
    navigator.pop(result);
  }

  // ---------- Camera permission flow ----------

  Future<void> _onTapCamera() async {
    // If you split photo/video modes, you can set includeMic=false for photo.
    final ok = await _requestCamera(includeMic: true);
    if (!ok) {
      final locked = await _isPermanentlyDenied(includeMic: true);
      if (locked && mounted) {
        await _showGoToSettingsDialog();
      } else {
        // Soft deny: just inform and stop.
        if (!mounted) return;
        final tr = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(tr.permission_not_now)),
        );
      }
      return;
    }

    // Permissions granted -> TODO: open your camera capture flow here.
    // For example: context.push('/camera'); or invoke your camera screen.
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Camera permission granted')),
    );
  }

  Future<bool> _requestCamera({required bool includeMic}) async {
    final cam = await Permission.camera.request();
    if (!cam.isGranted) return false;

    if (includeMic) {
      final mic = await Permission.microphone.request();
      if (!mic.isGranted) return false;
    }
    return true;
  }

  Future<bool> _isPermanentlyDenied({required bool includeMic}) async {
    final cam = await Permission.camera.status;
    final mic = includeMic ? await Permission.microphone.status : null;

    final camLocked = cam.isPermanentlyDenied || cam.isRestricted;
    final micLocked =
        includeMic ? (mic!.isPermanentlyDenied || mic.isRestricted) : false;

    return camLocked || micLocked;
  }

  Future<void> _showGoToSettingsDialog() async {
    final tr = AppLocalizations.of(context)!;
    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.all(24),
        child: Padding(
          padding: const EdgeInsetsDirectional.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(tr.permission_camera_explain, textAlign: TextAlign.start),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(tr.permission_not_now),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () async {
                      Navigator.of(context).pop();
                      await openAppSettings();
                    },
                    child: Text(tr.permission_go_to_settings),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------------------------------

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(tr.selectMedia),
        actions: [
          IconButton(
            onPressed: _onTapCamera,
            tooltip: 'Camera', // optional; your DS can localize if needed
            icon: const Icon(Icons.photo_camera_outlined),
          ),
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
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4, // 4 items per row
                          mainAxisSpacing: 0,
                          crossAxisSpacing: 0,
                          childAspectRatio: 1.0, // perfect squares
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

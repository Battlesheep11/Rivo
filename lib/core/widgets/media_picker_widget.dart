import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:rivo_app/features/post/domain/entities/media_file.dart';



class MediaPickerWidget extends StatefulWidget {
  final void Function(List<MediaFile>) onSelected;


  const MediaPickerWidget({
  super.key,
  required this.onSelected,
});


  @override
  State<MediaPickerWidget> createState() => _MediaPickerWidgetState();
}

class _MediaPickerWidgetState extends State<MediaPickerWidget> {
  List<AssetEntity> _mediaAssets = [];
  final Set<AssetEntity> _selectedAssets = {};

  @override
  void initState() {
    super.initState();
    _requestPermissionsAndLoadAssets();
  }

  Future<void> _requestPermissionsAndLoadAssets() async {
    final permission = await PhotoManager.requestPermissionExtend();
    if (!permission.isAuth) {
      return;
    }

    final albums = await PhotoManager.getAssetPathList(
      type: RequestType.common,
      hasAll: true,
    );

    final recentAlbum = albums.firstOrNull;
    if (recentAlbum == null) return;

    final assets = await recentAlbum.getAssetListPaged(page: 0, size: 100);

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

  Future<void> _handleNextPressed() async {
    final result = <MediaFile>[];
    for (final asset in _selectedAssets) {
      final bytes = await asset.originBytes;
      result.add(MediaFile.fromAsset(asset, bytes!));
    }

    widget.onSelected(result);
  }

  @override
  Widget build(BuildContext context) {
    if (_mediaAssets.isEmpty) {
      return const Center(child: Text('No media found in gallery'));
    }

    return Column(
      children: [
        Expanded(
          child: GridView.builder(
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
                            color: Colors.blue.withAlpha((0.8 * 255).toInt()),
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
        if (_selectedAssets.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(8),
            child: ElevatedButton(
              onPressed: _handleNextPressed,
              child: const Text('Next'),
            ),
          ),
      ],
    );
  }
}

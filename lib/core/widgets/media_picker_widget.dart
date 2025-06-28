import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:rivo_app/core/localization/generated/app_localizations.dart';
import 'package:rivo_app/features/post/domain/entities/media_file.dart';

class MediaPickerWidget extends StatefulWidget {
  final void Function(List<MediaFile>) onSelected;

  const MediaPickerWidget({super.key, required this.onSelected});

  @override
  State<MediaPickerWidget> createState() => _MediaPickerWidgetState();
}

class _MediaPickerWidgetState extends State<MediaPickerWidget> {
  List<AssetEntity> _media = [];
  final Set<AssetEntity> _selected = {};
  final _client = Supabase.instance.client;
  final _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    _loadGallery();
  }

  Future<void> _loadGallery() async {
    final result = await PhotoManager.requestPermissionExtend();
    if (!result.isAuth) return;

    final albums = await PhotoManager.getAssetPathList(
      type: RequestType.common,
      onlyAll: true,
    );

    final recent = albums.firstOrNull;
    if (recent == null) return;

    final assets = await recent.getAssetListPaged(page: 0, size: 100);
    setState(() => _media = assets);
  }

  void _toggleSelection(AssetEntity asset) {
    setState(() {
      if (_selected.contains(asset)) {
        _selected.remove(asset);
      } else {
        _selected.add(asset);
      }
    });
  }

  Future<void> _uploadSelectedAssets() async {
    final t = AppLocalizations.of(context)!;
    final List<MediaFile> uploadedMedia = [];

    for (final asset in _selected) {
      final file = await asset.originFile;
      if (file == null) continue;

      final ext = file.path.split('.').last.toLowerCase();
      final isImage = ['jpg', 'jpeg', 'png'].contains(ext);
      final isVideo = ['mp4', 'mov'].contains(ext);
      final type = isImage ? 'image' : isVideo ? 'video' : 'unknown';
      if (type == 'unknown') continue;

      try {
        final bytes = await file.readAsBytes();
        final filename = '${_uuid.v4()}.$ext';
        final path = 'media/$filename';

        await _client.storage.from('media').uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(contentType: '$type/$ext'),
        );

        final url = _client.storage.from('media').getPublicUrl(path);

        final insertResult = await _client
            .from('media')
            .insert({
              'media_url': url,
              'media_type': type,
            })
            .select()
            .single();

        final mediaFile = MediaFile(
          id: insertResult['id'],
          url: url,
          type: type,
          sortOrder: 0,
        );

        uploadedMedia.add(mediaFile);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${t.mediaPickerFailed}: ${e.toString()}')),
        );
      }
    }

    widget.onSelected(uploadedMedia);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    if (_media.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: GridView.builder(
            itemCount: _media.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 2,
              mainAxisSpacing: 2,
            ),
            itemBuilder: (_, index) {
              final asset = _media[index];
              return Builder(
                builder: (context) {
                  return FutureBuilder<Uint8List?>(
                    future: asset.thumbnailDataWithSize(const ThumbnailSize(200, 200)),
                    builder: (_, snapshot) {
                      final thumbData = snapshot.data;

                      return GestureDetector(
                        onTap: () => _toggleSelection(asset),
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: Container(
                                color: Colors.black12,
                                child: thumbData != null
                                    ? Image.memory(thumbData, fit: BoxFit.cover)
                                    : const SizedBox.expand(),
                              ),
                            ),
                            if (_selected.contains(asset))
                              Positioned(
                                top: 4,
                                right: 4,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.blueAccent,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.check, color: Colors.white, size: 16),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ElevatedButton.icon(
            onPressed: _selected.isEmpty ? null : _uploadSelectedAssets,
            icon: const Icon(Icons.cloud_upload),
            label: Text(t.mediaPickerUpload),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:rivo_app/features/post/domain/entities/media_file.dart';
import 'package:rivo_app/core/localization/generated/app_localizations.dart';

class MediaPickerWidget extends StatefulWidget {
  final void Function(List<MediaFile>) onMediaUploaded;

  const MediaPickerWidget({super.key, required this.onMediaUploaded});

  @override
  State<MediaPickerWidget> createState() => _MediaPickerWidgetState();
}

class _MediaPickerWidgetState extends State<MediaPickerWidget> {
  final List<MediaFile> _uploadedMedia = [];
  final _storage = Supabase.instance.client.storage;
  final _uuid = const Uuid();

  Future<void> _pickAndUploadMedia() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'mp4', 'mov'],
      withData: true, // 🟢 חשוב מאוד ל־Web: מביא את bytes!
    );

    if (result == null) return;

    for (final file in result.files) {
      final fileBytes = file.bytes;
      if (fileBytes == null) continue;

      final fileExt = file.extension ?? '';
      final isImage = ['jpg', 'jpeg', 'png'].contains(fileExt.toLowerCase());
      final isVideo = ['mp4', 'mov'].contains(fileExt.toLowerCase());

      final fileType = isImage
          ? 'image'
          : isVideo
              ? 'video'
              : 'unknown';

      if (fileType == 'unknown') continue;

      try {
        final fileName = '${_uuid.v4()}.$fileExt';
        final filePathInStorage = 'media/$fileName';

        await _storage.from('media').uploadBinary(
              filePathInStorage,
              fileBytes,
              fileOptions: FileOptions(
                contentType: isImage ? 'image/$fileExt' : 'video/$fileExt',
              ),
            );

        final publicUrl = _storage.from('media').getPublicUrl(filePathInStorage);

        final mediaFile = MediaFile(
          url: publicUrl,
          type: fileType,
        );

        setState(() {
          _uploadedMedia.add(mediaFile);
        });

        widget.onMediaUploaded(_uploadedMedia);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to upload media: $e')),
          );
        }
      }
    }
  }

  void _removeMedia(MediaFile media) {
    setState(() {
      _uploadedMedia.remove(media);
    });
    widget.onMediaUploaded(_uploadedMedia);
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ..._uploadedMedia.map((media) {
          return Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: media.type == 'image'
                    ? Image.network(
                        media.url,
                        fit: BoxFit.cover,
                      )
                    : const Center(child: Icon(Icons.videocam, size: 40)),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: () => _removeMedia(media),
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
        GestureDetector(
          onTap: _pickAndUploadMedia,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.add_photo_alternate, size: 30),
                const SizedBox(height: 4),
                Text(localizations.upload, style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

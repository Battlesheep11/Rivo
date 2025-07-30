import 'dart:typed_data';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivo_app_beta/core/media/domain/entities/uploadable_media.dart';
import 'package:rivo_app_beta/features/post/presentation/viewmodels/upload_post_viewmodel.dart';
import 'package:rivo_app_beta/core/widgets/media_picker_widget.dart'; // Reusing the picker logic

class PhotoUploadStep extends ConsumerWidget {
  const PhotoUploadStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaFiles = ref.watch(uploadPostViewModelProvider.select((s) => s.media));

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: mediaFiles.isEmpty
                ? _buildAddPhotosButton(context, ref)
                : _buildMainPreview(mediaFiles.first),
          ),
          const SizedBox(height: 16),
          _buildThumbnails(context, ref, mediaFiles),
        ],
      ),
    );
  }

  Widget _buildAddPhotosButton(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => MediaPickerWidget().pickFromGallery(context, ref),
      child: DottedBorder(
        options: const RectDottedBorderOptions(
          color: Colors.grey,
          strokeWidth: 1,
          dashPattern: [6, 3],
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Icon(Icons.add_a_photo_outlined, size: 50, color: Colors.grey),
          ),
        ),
      ),
    );
  }

  Widget _buildMainPreview(UploadableMedia media) {
    return FutureBuilder<Uint8List?>(
      future: media.asset.thumbnailDataWithSize(const ThumbnailSize(800, 800)),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting || !snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.memory(snapshot.data!, fit: BoxFit.cover),
        );
      },
    );
  }

  Widget _buildThumbnails(BuildContext context, WidgetRef ref, List<UploadableMedia> mediaFiles) {
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: mediaFiles.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: _buildThumbnailItem(ref, mediaFiles[index]),
          );
        },
      ),
    );
  }

  Widget _buildThumbnailItem(WidgetRef ref, UploadableMedia media) {
    return FutureBuilder<Uint8List?>(
      future: media.asset.thumbnailDataWithSize(const ThumbnailSize(200, 200)),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox(width: 80, height: 80, child: Center(child: CircularProgressIndicator()));
        }
        return Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.memory(snapshot.data!, width: 80, height: 80, fit: BoxFit.cover),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: () => ref.read(uploadPostViewModelProvider.notifier).removeMedia(media),
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                  child: const Icon(Icons.close, color: Colors.white, size: 14),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

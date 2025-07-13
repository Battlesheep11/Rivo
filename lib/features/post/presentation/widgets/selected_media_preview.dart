import 'package:rivo_app_beta/core/utils/temp_file_utils.dart';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivo_app_beta/features/post/domain/entities/media_file.dart';
import 'package:rivo_app_beta/features/post/presentation/viewmodels/upload_post_viewmodel.dart';
import 'package:video_player/video_player.dart';
import 'package:rivo_app_beta/features/post/domain/entities/uploadable_media.dart';

class SelectedMediaPreview extends ConsumerWidget {
  const SelectedMediaPreview({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaFiles = ref.watch(uploadPostViewModelProvider).media;
    final viewModel = ref.read(uploadPostViewModelProvider.notifier);

    if (mediaFiles.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: mediaFiles.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final item = mediaFiles[index];
          final media = item.media;
          final isInvalid = item.status == UploadMediaStatus.invalid;

          return Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: ColorFiltered(
                  colorFilter: isInvalid
                      ? const ColorFilter.mode(Colors.grey, BlendMode.saturation)
                      : const ColorFilter.mode(Colors.transparent, BlendMode.multiply),
                  child: _buildMediaThumbnail(media),
                ),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: () => viewModel.removeMedia(media),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(4),
                    child: const Icon(Icons.close, color: Colors.white, size: 16),
                  ),
                ),
              ),

              Positioned(
                bottom: 4,
                left: 4,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: child,
                  ),
                  child: _buildStatusIcon(item),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMediaThumbnail(MediaFile media) {
    if (media.type.toLowerCase().contains('video')) {
      return _VideoThumbnail(bytes: media.bytes);
    } else {
      return Image.memory(
        media.bytes,
        width: 100,
        height: 100,
        fit: BoxFit.cover,
      );
    }
  }


  Widget _buildStatusIcon(UploadableMedia item) {
    switch (item.status) {
      case UploadMediaStatus.uploading:
        return const SizedBox(
          key: ValueKey('uploading'),
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        );
      case UploadMediaStatus.uploaded:
        return const Icon(
          Icons.check_circle,
          color: Colors.green,
          size: 20,
          key: ValueKey('uploaded'),
        );
      case UploadMediaStatus.failed:
        return const Icon(
          Icons.error,
          color: Colors.red,
          size: 20,
          key: ValueKey('failed'),
        );
      case UploadMediaStatus.invalid:
        return Tooltip(
          key: const ValueKey('invalid'),
          message: item.errorMessage ?? 'Invalid file',
          child: const Icon(Icons.block, color: Colors.orange, size: 20),
        );
      default:
        return const SizedBox.shrink(key: ValueKey('empty'));
    }
  }
}

class _VideoThumbnail extends StatefulWidget {
  final Uint8List bytes;

  const _VideoThumbnail({required this.bytes});

  @override
  State<_VideoThumbnail> createState() => _VideoThumbnailState();
}

class _VideoThumbnailState extends State<_VideoThumbnail> {
  late VideoPlayerController _controller;

  Future<void> _loadVideo() async {
    final file = await TempFileUtils.saveBytesAsTempFile(widget.bytes, 'mp4');
    _controller = VideoPlayerController.file(file);
    await _controller.initialize();
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _loadVideo();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      height: 100,
      child: _controller.value.isInitialized
          ? Stack(
              alignment: Alignment.center,
              children: [
                VideoPlayer(_controller),
                const Icon(Icons.play_circle_fill, size: 30, color: Colors.white),
              ],
            )
          : const Center(child: CircularProgressIndicator(strokeWidth: 2)),
    );
  }
}

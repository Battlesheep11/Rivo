import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:rivo_app_beta/features/post/presentation/viewmodels/upload_post_viewmodel.dart';

import 'package:rivo_app_beta/core/localization/generated/app_localizations.dart';
import 'package:rivo_app_beta/core/utils/permission_utils.dart';
import 'package:rivo_app_beta/core/media/domain/entities/uploadable_media.dart';
import 'package:rivo_app_beta/core/widgets/permission_dialog.dart';
import 'package:rivo_app_beta/features/post/presentation/screens/media_gallery_screen.dart';

class MediaPickerWidget extends ConsumerWidget {
  const MediaPickerWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = AppLocalizations.of(context)!;

    return ElevatedButton.icon(
      icon: const Icon(Icons.add_photo_alternate),
      label: Text(tr.selectMedia),
      onPressed: () => _showMediaSourcePicker(context, ref),
    );
  }

  void _showMediaSourcePicker(BuildContext context, WidgetRef ref) {
    final tr = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(tr.mediaPickerGallery),
              onTap: () {
                Navigator.of(context).pop();
                pickFromGallery(context, ref);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text(tr.mediaPickerCamera),
              onTap: () {
                Navigator.of(context).pop();
                _showCameraOptions(context, ref);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCameraOptions(BuildContext context, WidgetRef ref) {
    final tr = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text(tr.takePhoto),
              onTap: () {
                Navigator.of(context).pop();
                _pickFromCamera(context, ref, isVideo: false);
              },
            ),
            ListTile(
              leading: const Icon(Icons.videocam),
              title: Text(tr.recordVideo),
              onTap: () {
                Navigator.of(context).pop();
                _pickFromCamera(context, ref, isVideo: true);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> pickFromGallery(BuildContext context, WidgetRef ref) async {
  final tr = AppLocalizations.of(context)!;

  debugPrint("📂 Requesting media access permission...");
  final hasPermission = await PermissionUtils.requestMediaAccessPermission();
  if (!context.mounted) return;

  if (!hasPermission) {
    debugPrint("❌ Permission denied");
    await PermissionDialog.show(
      context,
      title: tr.galleryPermissionTitle,
      message: tr.galleryPermissionMessage,
    );
    return;
  }

  debugPrint("✅ Permission granted – opening gallery screen");
  final result = await Navigator.of(context).push<List<UploadableMedia>>(
    MaterialPageRoute(builder: (_) => const MediaGalleryScreen()),
  );

  if (result == null) {
    debugPrint("📭 No media selected");
  } else if (result.isEmpty) {
    debugPrint("📭 Media selection returned empty list");
  } else {
    debugPrint("📸 ${result.length} media files selected");
    ref.read(uploadPostViewModelProvider.notifier).setMedia(result);
  }
}


  Future<void> _pickFromCamera(
    BuildContext context,
    WidgetRef ref, {
    required bool isVideo,
  }) async {
    final tr = AppLocalizations.of(context)!;

    final hasPermission = await PermissionUtils.requestCameraPermission();
    final isPermanentlyDenied = await Permission.camera.isPermanentlyDenied;
    if (!context.mounted) return;

    if (!hasPermission) {
      if (isPermanentlyDenied) {
        await PermissionDialog.show(
          context,
          title: tr.cameraPermissionTitle,
          message: tr.cameraPermissionMessage,
        );
      }
      return;
    }

    final picker = ImagePicker();
    final XFile? file = isVideo
        ? await picker.pickVideo(source: ImageSource.camera)
        : await picker.pickImage(source: ImageSource.camera);

    if (file != null) {
      try {
        final asset = isVideo
            ? await PhotoManager.editor.saveVideo(File(file.path))
            : await PhotoManager.editor.saveImageWithPath(file.path);

        final media = UploadableMedia(
          id: asset.id,
          asset: asset,
          type: isVideo ? MediaType.video : MediaType.image,
        );

        ref.read(uploadPostViewModelProvider.notifier).setMedia([media]);
      } catch (e) {
        debugPrint('❌ Failed to save captured media: $e');
      }
    }
  }
}

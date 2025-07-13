import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:rivo_app_beta/core/localization/generated/app_localizations.dart';
import 'package:rivo_app_beta/core/utils/permission_utils.dart';
import 'package:rivo_app_beta/features/post/domain/entities/media_file.dart';
import 'package:rivo_app_beta/features/post/presentation/screens/media_gallery_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rivo_app_beta/core/widgets/permission_dialog.dart';

class MediaPickerWidget extends StatelessWidget {
  final void Function(List<MediaFile>) onSelected;

  const MediaPickerWidget({
    super.key,
    required this.onSelected,
  });

  void _showMediaSourcePicker(BuildContext context) {
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
                _pickFromGallery(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text(tr.mediaPickerCamera),
              onTap: () {
                Navigator.of(context).pop();
                _showCameraOptions(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCameraOptions(BuildContext context) {
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
                _pickFromCamera(context, isVideo: false);
              },
            ),
            ListTile(
              leading: const Icon(Icons.videocam),
              title: Text(tr.recordVideo),
              onTap: () {
                Navigator.of(context).pop();
                _pickFromCamera(context, isVideo: true);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFromGallery(BuildContext context) async {
    final tr = AppLocalizations.of(context)!;
    final navigator = Navigator.of(context); 
    final dialogContext = context; 

    final permission = await Permission.photos.request();

    if (!permission.isGranted) {
      final isPermanentlyDenied = await Permission.photos.isPermanentlyDenied;
      if (isPermanentlyDenied && dialogContext.mounted) {
        await PermissionDialog.show(
          dialogContext,
          title: tr.galleryPermissionTitle,
          message: tr.galleryPermissionMessage,
        );
      }
      return;
    }

    final result = await navigator.push<List<MediaFile>>(
      MaterialPageRoute(
        builder: (_) => const MediaGalleryScreen(),
      ),
    );

    if (result != null && result.isNotEmpty) {
      onSelected(result);
    }
  }

  Future<void> _pickFromCamera(BuildContext context, {required bool isVideo}) async {
    final tr = AppLocalizations.of(context)!;
    final dialogContext = context; 

    final hasPermission = await PermissionUtils.requestCameraPermission();

    if (!hasPermission) {
      final isPermanentlyDenied = await Permission.camera.isPermanentlyDenied;
      if (isPermanentlyDenied && dialogContext.mounted) {
        await PermissionDialog.show(
          dialogContext,
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
      final savedAsset = await PhotoManager.editor.saveImageWithPath(file.path);
      final fileBytes = await savedAsset.originBytes;
      final mediaFile = MediaFile.fromAsset(savedAsset, fileBytes!);
      onSelected([mediaFile]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;

    return ElevatedButton.icon(
      icon: const Icon(Icons.add_photo_alternate),
      label: Text(tr.selectMedia),
      onPressed: () => _showMediaSourcePicker(context),
    );
  }
}

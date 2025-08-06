import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For FilteringTextInputFormatter and TextInputFormatter
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rivo_app_beta/core/localization/generated/app_localizations.dart';
import 'package:rivo_app_beta/features/post/presentation/viewmodels/upload_post_viewmodel.dart';
import 'package:rivo_app_beta/core/media/domain/entities/uploadable_media.dart';
import 'package:rivo_app_beta/core/utils/permission_utils.dart';
import 'package:rivo_app_beta/core/widgets/permission_dialog.dart';
import 'package:rivo_app_beta/features/post/presentation/screens/media_gallery_screen.dart';
import 'package:rivo_app_beta/features/post/domain/providers/post_providers.dart';
import 'package:rivo_app_beta/core/error_handling/app_exception.dart';
import 'package:rivo_app_beta/features/post/domain/providers/category_providers.dart';
import 'package:rivo_app_beta/core/entities/category.dart';

class PostUploadScreenRefactored extends ConsumerStatefulWidget {
  const PostUploadScreenRefactored({super.key});

  @override
  ConsumerState<PostUploadScreenRefactored> createState() => _PostUploadScreenRefactoredState();
}

class _PostUploadScreenRefactoredState extends ConsumerState<PostUploadScreenRefactored> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  /// Validates the current step before allowing navigation to the next page
  /// Shows specific error messages for missing required fields
  /// Navigate to the next page of the form
  void _nextPage() {
    if (!mounted) return;
    final state = ref.read(uploadPostViewModelProvider);
    final l10n = AppLocalizations.of(context)!;
    
    // Validate photo upload step (step 0)
    if (_currentPage == 0 && state.media.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.uploadPhotoRequired),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    // Validate caption & price step (step 1)
    if (_currentPage == 1) {
      if (state.caption == null || state.caption!.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.uploadCaptionRequired),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
      
      if (state.price == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.uploadPriceRequired),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
    }

    // Validate category step (step 2)
    if (_currentPage == 2) {
      if (state.categoryId == null || state.categoryId!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.uploadCategoryRequired),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
    }
    
    // Only proceed to next page if there are more pages
    if (_currentPage < 3) {
      setState(() {
        _currentPage++;
      });
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (!mounted) return;
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      if (mounted) {
        setState(() {
          _currentPage--;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // Initialization code can go here
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      resizeToAvoidBottomInset: true,
      // Modern gradient background matching CSS design
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF5F7FF), // #f5f7ff
              Color(0xFFF8F9FF), // #f8f9ff
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top Navigation Bar
              _buildTopBar(context, l10n),
              // Progress Bar
              _buildProgressBar(),
              // Main Content
              Expanded(
                child: _buildMainContent(context, l10n),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Top navigation bar with back button, title, and next button
  Widget _buildTopBar(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          // Back button - on last step, triggers upload, otherwise goes back or home
          GestureDetector(
            onTap: _currentPage == 3 
              ? () => _publishItem(ref.read(uploadPostViewModelProvider.notifier), AppLocalizations.of(context)!) 
              : _currentPage > 0 
                ? _previousPage 
                : () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/home');
                    }
                  },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha((0.8 * 255).round()),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha((0.05 * 255).round()),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Color(0xFF1A1A2E),
                size: 20,
              ),
            ),
          ),
          // Title
          Expanded(
            child: Text(
              l10n.newItem,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A2E),
                letterSpacing: -0.3,
              ),
            ),
          ),
          // Next button
          GestureDetector(
            onTap: _nextPage,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6E8EFB), Color(0xFF9BB5FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6E8EFB).withAlpha((0.3 * 255).round()),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_forward,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Progress bar showing current step
  Widget _buildProgressBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: List.generate(4, (index) {
          final isActive = index <= _currentPage;
          return Expanded(
            child: Container(
              height: 4,
              margin: EdgeInsets.only(right: index < 3 ? 8 : 0),
              decoration: BoxDecoration(
                color: isActive ? const Color(0xFF6E8EFB) : Colors.grey.withAlpha((0.2 * 255).round()),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  /// Main content area with page view
  Widget _buildMainContent(BuildContext context, AppLocalizations l10n) {
    return PageView(
      controller: _pageController,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildPhotoUploadStep(context, l10n),
        _buildCaptionPriceStep(context, ref),
        _buildItemDetailsStep(context, l10n),
        _buildTagsStep(l10n),
      ],
    );
  }

  /// Step 1: Photo upload with modern grid design
  Widget _buildPhotoUploadStep(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and description
          Text(
            l10n.addPhotos,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A2E),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.photoTip,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.withAlpha((0.7 * 255).round()),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          // Photo grid container with glassmorphism effect
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha((0.7 * 255).round()),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withAlpha((0.2 * 255).round()),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha((0.05 * 255).round()),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: _buildPhotoGrid(context, l10n),
            ),
          ),
        ],
      ),
    );
  }

  /// Interactive photo grid with add, remove, and reorder functionality
  /// Photo grid where the add photo button is always at index 0, followed by media items.
  /// Only media items (indices 1..N) are reorderable.
  Widget _buildPhotoGrid(BuildContext context, AppLocalizations l10n) {
    final viewModel = ref.read(uploadPostViewModelProvider.notifier);
    final state = ref.watch(uploadPostViewModelProvider);

    // Add button is always at index 0 if media.length < 10
    final hasAddButton = state.media.length < 10;
    final itemCount = state.media.length + (hasAddButton ? 1 : 0);

    return ReorderableGridView.builder(
      dragStartDelay: const Duration(milliseconds: 100),
      padding: const EdgeInsets.all(16.0),
      itemCount: itemCount,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      // Only allow reordering of media items (not the add button at index 0)
      onReorder: (oldIndex, newIndex) {
        // Prevent moving the add button (index 0)
        if (oldIndex == 0 || newIndex == 0) return;
        // Adjust indices since media items start at index 1
        final mediaOldIndex = oldIndex - 1;
        final mediaNewIndex = newIndex - 1;
        if (mediaOldIndex >= 0 && mediaNewIndex >= 0 && mediaOldIndex < state.media.length && mediaNewIndex < state.media.length) {
          viewModel.reorderMedia(mediaOldIndex, mediaNewIndex);
        }
      },
      itemBuilder: (context, index) {
        if (index == 0 && hasAddButton) {
          // Always show the add photo button at the start
          return KeyedSubtree(
            key: const ValueKey('add_photo_button'),
            child: _buildAddPhotoButton(context),
          );
        } else {
          // Media items start from index 1
          final media = state.media[index - 1];
          return ReorderableDragStartListener(
            key: ValueKey(media.asset.id),
            index: index,
            child: _buildPhotoPreviewItem(context, media, index - 1, viewModel),
          );
        }
      },
    );
  }

  /// Add photo button with camera icon and styling
  Widget _buildAddPhotoButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _showImagePicker(context),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.withAlpha((0.1 * 255).round()),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey.withAlpha((0.3 * 255).round()),
            width: 2,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6E8EFB), Color(0xFF9BB5FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6E8EFB).withAlpha((0.3 * 255).round()),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.camera_alt_outlined,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add Photo',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey.withAlpha((0.7 * 255).round()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Photo preview item with remove button and drag functionality
  Widget _buildPhotoPreviewItem(
    BuildContext context, 
    UploadableMedia media, 
    int index, 
    UploadPostViewModel viewModel,
  ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.08 * 255).round()),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Photo image
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: AssetEntityImage(
                media.asset,
                isOriginal: false,
                thumbnailSize: const ThumbnailSize.square(250),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildErrorPlaceholder(),
              ),
            ),
          ),
          // Remove button
          Positioned(
            top: 6,
            right: 6,
            child: GestureDetector(
              onTap: () => viewModel.removeMedia(media),
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha((0.6 * 255).round()),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ),
          ),
          // First photo indicator (cover image)
          if (index == 0)
            Positioned(
              bottom: 6,
              left: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha((0.7 * 255).round()),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Cover',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  /// Error placeholder for failed image loads
  Widget _buildErrorPlaceholder() {
    return Container(
      color: Colors.grey.withAlpha((0.2 * 255).round()),
      child: Icon(
        Icons.broken_image_outlined,
        color: Colors.grey.withAlpha((0.6 * 255).round()),
        size: 32,
      ),
    );
  }
  
  /// Show image picker bottom sheet
  void _showImagePicker(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withAlpha((0.3 * 255).round()),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              // Title
              Text(
                l10n.addPhotos,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 20),
              // Camera option
              _buildPickerOption(
                context,
                icon: Icons.camera_alt_outlined,
                title: 'Camera',
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              const SizedBox(height: 12),
              // Gallery option
              _buildPickerOption(
                context,
                icon: Icons.photo_library_outlined,
                title: 'Photo Library',
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  /// Picker option button
  Widget _buildPickerOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.grey.withAlpha((0.05 * 255).round()),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey.withAlpha((0.1 * 255).round()),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: const Color(0xFF6E8EFB),
              size: 24,
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1A1A2E),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Pick image from camera or gallery using proper MediaPickerWidget workflow
  Future<void> _pickImage(ImageSource source) async {
    if (source == ImageSource.gallery) {
      await _pickFromGallery();
    } else {
      await _pickFromCamera();
    }
  }
  
  /// Pick images from gallery using proper permission workflow
  Future<void> _pickFromGallery() async {
    final viewModel = ref.read(uploadPostViewModelProvider.notifier);
    final l10n = AppLocalizations.of(context)!;
    debugPrint("📂 Requesting media access permission...");
    final hasPermission = await PermissionUtils.requestMediaAccessPermission();
    if (!mounted) return;

    if (!hasPermission) {
      debugPrint("❌ Permission denied");
      await PermissionDialog.show(
        context,
        title: l10n.galleryPermissionTitle,
        message: l10n.galleryPermissionMessage,
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
      // Add new media to existing media list (up to 10 total)
      final currentMedia = ref.read(uploadPostViewModelProvider).media;
      final totalMedia = [...currentMedia, ...result];
      if (totalMedia.length <= 10) {
        viewModel.setMedia(totalMedia);
      } else {
        // Take only up to 10 photos total
        viewModel.setMedia(totalMedia.take(10).toList());
        // Show message about limit
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Maximum 10 photos allowed'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    }
  }
  
  /// Pick image from camera using proper permission workflow
  Future<void> _pickFromCamera() async {
    final viewModel = ref.read(uploadPostViewModelProvider.notifier);
    final l10n = AppLocalizations.of(context)!;
    final hasPermission = await PermissionUtils.requestCameraPermission();
    final isPermanentlyDenied = await Permission.camera.isPermanentlyDenied;
    if (!mounted) return;

    if (!hasPermission) {
      if (isPermanentlyDenied) {
        await PermissionDialog.show(
          context,
          title: l10n.cameraPermissionTitle,
          message: l10n.cameraPermissionMessage,
        );
      }
      return;
    }

    final picker = ImagePicker();
    final XFile? file = await picker.pickImage(source: ImageSource.camera);

    if (file != null) {
      try {
        // Save the captured image to gallery and get AssetEntity
        final asset = await PhotoManager.editor.saveImageWithPath(file.path);

        final media = UploadableMedia(
          id: asset.id,
          asset: asset,
          type: MediaType.image,
        );

        // Add to existing media list (up to 10 total)
        final currentMedia = ref.read(uploadPostViewModelProvider).media;
        if (currentMedia.length < 10) {
          viewModel.setMedia([...currentMedia, media]);
        } else {
          // Show message about limit
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Maximum 10 photos allowed'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
      } catch (e) {
        debugPrint('❌ Failed to save captured media: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to save photo'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Widget _buildCaptionPriceStep(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final viewModel = ref.read(uploadPostViewModelProvider.notifier);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and description
          Text(
            l10n.captionAndPriceTitle,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A2E),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.addCaptionHint,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.withAlpha((0.7 * 255).round()),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          
          // Main content container
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha((0.7 * 255).round()),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withAlpha((0.2 * 255).round()),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha((0.05 * 255).round()),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  // Caption field
                  Text(
                    'Caption',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey.withAlpha((0.2 * 255).round()),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha((0.03 * 255).round()),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      maxLines: 3,
                      onChanged: viewModel.setCaption,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(500), // Limit caption length
                        FilteringTextInputFormatter.deny(RegExp(r'[<>/\|]')), // Block dangerous characters
                      ],
                      decoration: InputDecoration(
                        hintText: 'Describe your item...',
                        hintStyle: TextStyle(
                          color: Colors.grey.withAlpha((0.5 * 255).round()),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(16),
                      ),
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Price field
                  Text(
                    'Price',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey.withAlpha((0.2 * 255).round()),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha((0.03 * 255).round()),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      // Add input formatters to allow only numbers and a single decimal dot
                      inputFormatters: [
                        // Allow only digits and a single decimal dot
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                        // Custom formatter to ensure only one decimal dot
                        TextInputFormatter.withFunction((oldValue, newValue) {
                          final text = newValue.text;
                          // Allow only one decimal dot
                          if (text.contains('.') && text.indexOf('.') != text.lastIndexOf('.')) {
                            return oldValue;
                          }
                          // Prevent leading decimal dot
                          if (text.startsWith('.')) {
                            return oldValue;
                          }
                          // Prevent more than two decimals
                          final parts = text.split('.');
                          if (parts.length > 1 && parts[1].length > 2) {
                            return oldValue;
                          }
                          return newValue;
                        }),
                      ],
                      onChanged: (value) {
                        final price = double.tryParse(value);
                        viewModel.setPrice(price);
                      },
                      decoration: InputDecoration(
                        hintText: '0.00', // Using hardcoded format as it's a number format
                        hintStyle: TextStyle(
                          color: Colors.grey.withAlpha((0.5 * 255).round()),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(16),
                        // Use the localized shekel symbol as prefix
                        prefixText: l10n.currencyShekel,
                        prefixStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Navigation buttons
                  Row(
                    children: [
                      // Back button
                      Expanded(
                        child: GestureDetector(
                          onTap: _previousPage,
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.grey.withAlpha((0.1 * 255).round()),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.grey.withAlpha((0.2 * 255).round()),
                                width: 1,
                              ),
                            ),
                            child: const Center(
                              child: Text(
                                'Back',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1A1A2E),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Next button
                      Expanded(
                        child: GestureDetector(
                          onTap: _nextPage,
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF6E8EFB), Color(0xFF9BB5FF)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF6E8EFB).withAlpha((0.3 * 255).round()),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                l10n.next,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
        ]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemDetailsStep(BuildContext context, AppLocalizations l10n) {
    final viewModel = ref.read(uploadPostViewModelProvider.notifier);
    final state = ref.watch(uploadPostViewModelProvider);
    final l10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and description
          Text(
            l10n.itemDetailsTitle,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A2E),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.itemDetailsDescription,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.withAlpha((0.6 * 255).round()),
            ),
          ),
          const SizedBox(height: 24),

          // Category picker
          _buildDetailField(
            l10n.categoryLabel,
            l10n.selectCategoryHint,
            Icons.category_outlined, // Changed icon
            onTap: () => _showCategoryPicker(context, viewModel),
            value: ref.watch(categoryByIdProvider(state.categoryId)).when(
                  data: (category) => category?.name,
                  loading: () => '',
                  error: (err, stack) => null,
                ),
          ),

          // Condition picker
          _buildDetailField(
            l10n.conditionLabel,
            l10n.selectConditionHint,
            Icons.check_circle_outline,
            onTap: () => _showConditionPicker(context, viewModel),
            value: state.condition,
          ),

          // Size picker
          _buildDetailField(
            l10n.sizeLabel,
            l10n.selectSizeHint,
            Icons.straighten_outlined,
            onTap: () => _showSizePicker(context, viewModel),
            value: state.size,
          ),

          // Brand input
          _buildTextDetailField(
            '${l10n.brandLabel} (${l10n.optional})',
            l10n.enterBrandHint,
            Icons.store_outlined,
            onChanged: viewModel.setBrand,
          ),

          // Material input
          _buildTextDetailField(
            '${l10n.materialLabel} (${l10n.optional})',
            l10n.enterMaterialHint,
            Icons.texture_outlined,
            onChanged: viewModel.setMaterial,
          ),
          
          const SizedBox(height: 8),
          
          // Measurements section
          Text(
            '${l10n.measurementsLabel} (${l10n.optional})',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: _buildMeasurementField(
                  l10n.chest,
                  l10n.centimetersAbbreviation,
                  onChanged: (value) {
                    final chest = double.tryParse(value);
                    viewModel.setChest(chest);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMeasurementField(
                  l10n.waist,
                  l10n.centimetersAbbreviation,
                  onChanged: (value) {
                    final waist = double.tryParse(value);
                    viewModel.setWaist(waist);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMeasurementField(
                  l10n.length,
                  l10n.centimetersAbbreviation,
                  onChanged: (value) {
                    final length = double.tryParse(value);
                    viewModel.setLength(length);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          
          // Navigation buttons
          Row(
            children: [
              // Back button
              Expanded(
                child: GestureDetector(
                  onTap: _previousPage,
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey.withAlpha((0.1 * 255).round()),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey.withAlpha((0.2 * 255).round()),
                        width: 1,
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        'Back',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Next button
              Expanded(
                child: GestureDetector(
                  onTap: _nextPage,
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6E8EFB), Color(0xFF9BB5FF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6E8EFB).withAlpha((0.3 * 255).round()),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'Next',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
  
  /// Build a detail field with tap functionality (for dropdowns)
  /// Build a selectable field with icon and optional value display
  Widget _buildDetailField(
    String label,
    String placeholder,
    IconData icon, {
    required VoidCallback onTap,
    String? value,
  }) {
    final hasValue = value?.isNotEmpty ?? false;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey.withAlpha(51), // 0.2 * 255 ≈ 51
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(13), // 0.05 * 255 ≈ 13
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFF6E8EFB).withAlpha(26), // 0.1 * 255 ≈ 26
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF6E8EFB),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    hasValue ? value! : placeholder,
                    style: TextStyle(
                      fontSize: 16,
                      color: hasValue 
                          ? const Color(0xFF111827) 
                          : const Color(0xFF9CA3AF),
                      fontWeight: hasValue ? FontWeight.w500 : FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Color(0xFF9CA3AF),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Build a text input detail field
  Widget _buildTextDetailField(
    String label,
    String placeholder,
    IconData icon, {
    Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey.withAlpha((0.2 * 255).round()),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha((0.03 * 255).round()),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            onChanged: onChanged,
            inputFormatters: [
              LengthLimitingTextInputFormatter(100), // Limit input length
              FilteringTextInputFormatter.deny(RegExp(r'[<>/\|]')), // Block dangerous characters
            ],
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: TextStyle(
                color: Colors.grey.withAlpha((0.5 * 255).round()),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
              prefixIcon: Icon(
                icon,
                color: const Color(0xFF6E8EFB),
                size: 20,
              ),
            ),
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF1A1A2E),
            ),
          ),
        ),
      ],
    );
  }
  
  /// Build a measurement input field
  Widget _buildMeasurementField(
    String label,
    String unit, {
    Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.grey.withAlpha((0.2 * 255).round()),
              width: 1,
            ),
          ),
          child: TextField(
            keyboardType: TextInputType.number,
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: '0',
              hintStyle: TextStyle(
                color: Colors.grey.withAlpha((0.5 * 255).round()),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              suffixText: unit,
              suffixStyle: TextStyle(
                fontSize: 12,
                color: Colors.grey.withAlpha((0.6 * 255).round()),
              ),
            ),
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF1A1A2E),
            ),
          ),
        ),
      ],
    );
  }

  // Show condition picker bottom sheet
  void _showConditionPicker(BuildContext context, UploadPostViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildPickerSheet(
        title: 'Select Condition',
        items: const [
          'New with tags',
          'New without tags',
          'Like new',
          'Very good',
          'Good',
          'Fair',
        ],
        onSelected: (value) {
          viewModel.setCondition(value);
          Navigator.pop(context);
        },
      ),
    );
  }

  // Show category picker bottom sheet
  void _showCategoryPicker(BuildContext context, UploadPostViewModel viewModel) {
    // Use ref.read to get the future and handle it manually.
    final categoriesFuture = ref.read(categoriesProvider.future);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return FutureBuilder<List<Category>>(
          future: categoriesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No categories found.'));
            }

            final categoryList = snapshot.data!;
            return _buildPickerSheet(
              title: 'Select Category',
              items: categoryList.map((c) => c.name).toList(),
              onSelected: (value) {
                final selectedCategory =
                    categoryList.firstWhere((c) => c.name == value);
                viewModel.setCategory(selectedCategory.id);
                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
  }

  // Show size picker bottom sheet
  void _showSizePicker(BuildContext context, UploadPostViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildPickerSheet(
        title: 'Select Size',
        items: const [
          'XS', 'S', 'M', 'L', 'XL', 'XXL',
          'One Size', 'Other'
        ],
        onSelected: (value) {
          viewModel.setSize(value);
          Navigator.pop(context);
        },
      ),
    );
  }
  
  // Reusable picker bottom sheet
  Widget _buildPickerSheet({
    required String title,
    required List<String> items,
    required Function(String) onSelected,
  }) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          
          // Title
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 16),
          
          // Items list
          SizedBox(
            height: 300,
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return ListTile(
                  title: Text(
                    item,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  onTap: () => onSelected(item),
                );
              },
            ),
          ),
          
          // Cancel button
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: Colors.grey[100],
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Tags step with style tags, custom tags, and publish functionality
  Widget _buildTagsStep(AppLocalizations l10n) {
    final state = ref.watch(uploadPostViewModelProvider);
    final viewModel = ref.read(uploadPostViewModelProvider.notifier);
    final isSubmitting = state.isSubmitting;
    final allTags = ref.watch(tagsProvider);
    
    if (!mounted) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and description
          Text(
            l10n.tagsAndStyleTitle,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A2E),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.tagsAndStyleDescription,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.withAlpha((0.7 * 255).round()),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          
          // Main content container
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha((0.7 * 255).round()),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withAlpha((0.2 * 255).round()),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha((0.05 * 255).round()),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Style tags section
                    Text(
                      l10n.styleTagsLabel,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 12),
                                        allTags.when(
                      data: (availableTags) {
                        return Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          children: availableTags.map((tag) {
                            return _TagChip(
                              label: tag.name,
                              isSelected: state.tagNames.contains(tag.name),
                              onTap: () => _toggleTag(tag.name, viewModel),
                            );
                          }).toList(),
                        );
                      },
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (error, stackTrace) => Center(child: Text(l10n.error_loading_tags)),
                    ),
                    const SizedBox(height: 24),
                    
                    // Custom tags section
                    Text(
                      l10n.customTagsLabel,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.customTagsHint,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.withAlpha((0.6 * 255).round()),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildCustomTagsInput(viewModel),
                    const SizedBox(height: 20),
                    
                    // Selected tags display
                    if (state.tagNames.isNotEmpty) 
                      Column(
                        children: [
                          Text(
                            l10n.selectedTagsLabel,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1A1A2E),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildSelectedTags(state.tagNames, viewModel),
                          const SizedBox(height: 24),
                        ],
                      ),
                    
                    const SizedBox(height: 32),
                    
                    // Navigation buttons
                    Row(
                      children: [
                        // Back button
                        Expanded(
                          child: GestureDetector(
                            onTap: isSubmitting ? null : _previousPage,
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: isSubmitting 
                                    ? Colors.grey.withAlpha((0.05 * 255).round())
                                    : Colors.grey.withAlpha((0.1 * 255).round()),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.grey.withAlpha((0.2 * 255).round()),
                                  width: 1,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  'Back',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: isSubmitting 
                                        ? Colors.grey.withAlpha((0.4 * 255).round())
                                        : const Color(0xFF1A1A2E),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Publish button
                        Expanded(
                          child: GestureDetector(
                            onTap: isSubmitting ? null : () => _publishItem(viewModel, l10n),
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                gradient: isSubmitting
                                    ? LinearGradient(
                                        colors: [
                                          Colors.grey.withAlpha((0.3 * 255).round()),
                                          Colors.grey.withAlpha((0.4 * 255).round()),
                                        ],
                                      )
                                    : const LinearGradient(
                                        colors: [Color(0xFF6E8EFB), Color(0xFF9BB5FF)],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: isSubmitting
                                    ? []
                                    : [
                                        BoxShadow(
                                          color: const Color(0xFF6E8EFB).withAlpha((0.3 * 255).round()),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                              ),
                              child: Center(
                                child: isSubmitting
                                    ? Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor: AlwaysStoppedAnimation<Color>(
                                                Colors.white.withAlpha((0.8 * 255).round()),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            l10n.publishingButton,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white.withAlpha((0.8 * 255).round()),
                                            ),
                                          ),
                                        ],
                                      )
                                    : Text(
                                        l10n.publishItemButton,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  /// Build selected tags display with remove functionality
  Widget _buildSelectedTags(List<String> tags, UploadPostViewModel viewModel) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: tags.map((tag) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF6E8EFB).withAlpha((0.1 * 255).round()),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF6E8EFB).withAlpha((0.2 * 255).round()),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                tag,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6E8EFB),
                ),
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: () => _removeTag(tag, viewModel),
                child: Icon(
                  Icons.close,
                  size: 14,
                  color: const Color(0xFF6E8EFB).withAlpha((0.7 * 255).round()),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
  

  

  
  /// Remove a tag
  void _removeTag(String tag, UploadPostViewModel viewModel) {
    final currentTags = ref.read(uploadPostViewModelProvider).tagNames;
    final updatedTags = currentTags.where((t) => t != tag).toList();
    viewModel.setTags(updatedTags);
  }
  
  /// Publish the item
    void _toggleTag(String tag, UploadPostViewModel viewModel) {
    final currentTags = ref.read(uploadPostViewModelProvider).tagNames;
    if (currentTags.contains(tag)) {
      viewModel.setTags(currentTags.where((t) => t != tag).toList());
    } else {
      viewModel.setTags([...currentTags, tag]);
    }
  }

  /// Handles custom tag input, sanitizing and validating tags.
void _handleCustomTagsInput(String input, UploadPostViewModel viewModel) {
  // Split by comma, trim whitespace, and remove any empty tags.
  final newTags = input
      .split(',')
      .map((tag) {
        // Sanitize each tag to allow only Hebrew, English, numbers, and spaces.
        // This also helps prevent script injection.
        final sanitizedTag = tag.replaceAll(RegExp(r'[^\u0590-\u05FFa-zA-Z0-9 ]'), '').trim();
        return sanitizedTag;
      })
      .where((tag) => tag.isNotEmpty) // Filter out any tags that are empty after sanitization
      .toSet(); // Use a Set to automatically handle duplicates from the input string.

  if (newTags.isEmpty) {
    return;
  }

  final currentTags = ref.read(uploadPostViewModelProvider).tagNames.toSet();
  
  // Add only the tags that are not already present.
  final uniqueNewTags = newTags.difference(currentTags);

  if (uniqueNewTags.isNotEmpty) {
    viewModel.setTags([...currentTags, ...uniqueNewTags]);
  }
  // Note: Backend services should use parameterized queries to prevent SQL injection.
  // Client-side validation helps ensure data integrity.
}

    Widget _buildCustomTagsInput(UploadPostViewModel viewModel) {
  final TextEditingController controller = TextEditingController();
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: Colors.grey.withAlpha((0.2 * 255).round()),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withAlpha((0.03 * 255).round()),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: TextField(
      controller: controller,
      // Allow only Hebrew, English, and numbers (plus comma for separation)
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r"[\u0590-\u05FFa-zA-Z0-9, ]")),
      ],
      onSubmitted: (value) {
        _handleCustomTagsInput(value, viewModel);
        controller.clear(); // Clear after submit
      },
      decoration: InputDecoration(
        hintText: 'e.g. summer, party, comfortable',
        hintStyle: TextStyle(
          color: Colors.grey.withAlpha((0.5 * 255).round()),
        ),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.all(16),
        prefixIcon: Icon(
          Icons.local_offer_outlined,
          color: const Color(0xFF6E8EFB),
          size: 20,
        ),
      ),
      style: const TextStyle(
        fontSize: 16,
        color: Color(0xFF1A1A2E),
      ),
      textInputAction: TextInputAction.done,
    ),
  );
}

  Future<void> _publishItem(UploadPostViewModel viewModel, AppLocalizations l10n) async {
    try {
      await viewModel.submit();
      if (mounted) {
        // Navigate to the feed after successful upload
        context.go('/feed');
      }
    } on AppException catch (e) {
      if (!mounted) return;
      String errorMessage;
      switch (e.message) {
        case 'uploadCaptionRequiredBackend':
          errorMessage = l10n.uploadCaptionRequiredBackend;
          break;
        case 'uploadPriceRequiredBackend':
          errorMessage = l10n.uploadPriceRequiredBackend;
          break;
        case 'upload.required_fields_missing':
          errorMessage = l10n.fieldRequired;
          break;
        default:
          errorMessage = l10n.failed_to_publish_item(e.message);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.failed_to_publish_item(e.toString())),
          backgroundColor: Colors.red,
        ),
      );
    }
  }  
}

class _TagChip extends StatelessWidget {
  const _TagChip({
    required this.label,
    required this.isSelected,
    this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
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
import 'package:rivo_app_beta/features/post/presentation/widgets/condition_dropdown.dart';
import 'package:rivo_app_beta/features/post/presentation/widgets/materials_selector.dart';
import 'package:rivo_app_beta/features/post/presentation/widgets/color_selector.dart';
import 'package:rivo_app_beta/features/post/presentation/widgets/defects_selector.dart';

class PostUploadScreenRefactored extends ConsumerStatefulWidget {
  const PostUploadScreenRefactored({super.key});

  @override
  ConsumerState<PostUploadScreenRefactored> createState() => _PostUploadScreenRefactoredState();
}

class _PostUploadScreenRefactoredState extends ConsumerState<PostUploadScreenRefactored> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  void _nextPage() {
    if (!mounted) return;
    final state = ref.read(uploadPostViewModelProvider);
    final l10n = AppLocalizations.of(context)!;

    if (_currentPage == 0 && state.media.isEmpty) {
      _snack(context, l10n.uploadPhotoRequired, orange: true);
      return;
    }
    if (_currentPage == 1) {
      if (state.title == null || state.title!.trim().isEmpty) {
        _snack(context, 'Please add a title', orange: true);
        return;
      }
      if (state.description == null || state.description!.trim().isEmpty) {
        _snack(context, 'Please add a description', orange: true);
        return;
      }
      if (state.caption == null || state.caption!.trim().isEmpty) {
        _snack(context, l10n.uploadCaptionRequired, orange: true);
        return;
      }
      if (state.productPrice == null) {
        _snack(context, l10n.uploadPriceRequired, orange: true);
        return;
      }
    }
    if (_currentPage == 2) {
      if (state.categoryId == null || state.categoryId!.isEmpty) {
        _snack(context, l10n.uploadCategoryRequired, orange: true);
        return;
      }
    }

    if (_currentPage < 3) {
      setState(() => _currentPage++);
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
      if (mounted) setState(() => _currentPage--);
    }
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [Color(0xFFF5F7FF), Color(0xFFF8F9FF)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildTopBar(context, l10n),
              _buildProgressBar(),
              Expanded(child: _buildMainContent(context, l10n)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          GestureDetector(
            onTap: _currentPage == 3
                ? () => _publishItem(ref.read(uploadPostViewModelProvider.notifier), l10n)
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
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha((0.8 * 255).round()),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withAlpha((0.05 * 255).round()), blurRadius: 8, offset: const Offset(0, 2))],
              ),
              child: const Icon(Icons.arrow_back, color: Color(0xFF1A1A2E), size: 20),
            ),
          ),
          Expanded(
            child: Text(
              l10n.newItem,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E), letterSpacing: -0.3),
            ),
          ),
          GestureDetector(
            onTap: _nextPage,
            child: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF6E8EFB), Color(0xFF9BB5FF)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: const Color(0xFF6E8EFB).withAlpha((0.3 * 255).round()), blurRadius: 8, offset: const Offset(0, 2))],
              ),
              child: const Icon(Icons.arrow_forward, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

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

  // ---------- Step 0: Photos ----------
  Widget _buildPhotoUploadStep(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(l10n.addPhotos, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E), letterSpacing: -0.5)),
        const SizedBox(height: 8),
        Text(l10n.photoTip, style: TextStyle(fontSize: 16, color: Colors.grey.withAlpha((0.7 * 255).round()), height: 1.4)),
        const SizedBox(height: 24),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha((0.7 * 255).round()),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withAlpha((0.2 * 255).round()), width: 1),
              boxShadow: [BoxShadow(color: Colors.black.withAlpha((0.05 * 255).round()), blurRadius: 20, offset: const Offset(0, 8))],
            ),
            child: _buildPhotoGrid(context, l10n),
          ),
        ),
      ]),
    );
  }

  Widget _buildPhotoGrid(BuildContext context, AppLocalizations l10n) {
    final viewModel = ref.read(uploadPostViewModelProvider.notifier);
    final state = ref.watch(uploadPostViewModelProvider);

    final hasAddButton = state.media.length < 10;
    final itemCount = state.media.length + (hasAddButton ? 1 : 0);

    return ReorderableGridView.builder(
      dragStartDelay: const Duration(milliseconds: 100),
      padding: const EdgeInsets.all(16.0),
      itemCount: itemCount,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, crossAxisSpacing: 12, mainAxisSpacing: 12,
      ),
      onReorder: (oldIndex, newIndex) {
        if (oldIndex == 0 || newIndex == 0) return; // keep add button fixed
        final mediaOldIndex = oldIndex - 1;
        final mediaNewIndex = newIndex - 1;
        if (mediaOldIndex >= 0 && mediaNewIndex >= 0 && mediaOldIndex < state.media.length && mediaNewIndex < state.media.length) {
          viewModel.reorderMedia(mediaOldIndex, mediaNewIndex);
        }
      },
      itemBuilder: (context, index) {
        if (index == 0 && hasAddButton) {
          return KeyedSubtree(
            key: const ValueKey('add_photo_button'),
            child: _buildAddPhotoButton(context),
          );
        } else {
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

  Widget _buildAddPhotoButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _showImagePicker(context),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.withAlpha((0.1 * 255).round()),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withAlpha((0.3 * 255).round()), width: 2, strokeAlign: BorderSide.strokeAlignInside),
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF6E8EFB), Color(0xFF9BB5FF)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: const Color(0xFF6E8EFB).withAlpha((0.3 * 255).round()), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: const Icon(Icons.camera_alt_outlined, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 8),
          Text('Add Photo', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey.withAlpha((0.7 * 255).round()))),
        ]),
      ),
    );
  }

  Widget _buildPhotoPreviewItem(
    BuildContext context,
    UploadableMedia media,
    int index,
    UploadPostViewModel viewModel,
  ) {
    final state = ref.watch(uploadPostViewModelProvider);
    final isCover = state.coverImageIndex == index;

    return GestureDetector(
      onTap: () => viewModel.setCoverImageIndex(index),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: isCover ? Border.all(color: const Color(0xFF6E8EFB), width: 3) : null,
          boxShadow: [BoxShadow(color: Colors.black.withAlpha((0.08 * 255).round()), blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: FutureBuilder<Uint8List?>(
                future: media.asset.thumbnailDataWithSize(const ThumbnailSize(200, 200), quality: 80),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data != null) {
                    return Image.memory(snapshot.data!, width: double.infinity, height: double.infinity, fit: BoxFit.cover);
                  }
                  return Container(color: Colors.grey[300], child: const Center(child: CircularProgressIndicator()));
                },
              ),
            ),
            Positioned(
              top: 6,
              right: 6,
              child: GestureDetector(
                onTap: () => viewModel.removeMedia(media),
                child: Container(
                  width: 24, height: 24,
                  decoration: BoxDecoration(color: Colors.red.withAlpha((0.8 * 255).round()), shape: BoxShape.circle),
                  child: const Icon(Icons.close, color: Colors.white, size: 16),
                ),
              ),
            ),
            if (isCover)
              Positioned(
                bottom: 6,
                left: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6E8EFB),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: Colors.black.withAlpha((0.2 * 255).round()), blurRadius: 4, offset: const Offset(0, 1))],
                  ),
                  child: const Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.star, color: Colors.white, size: 12),
                    SizedBox(width: 4),
                    Text('Cover', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
                  ]),
                ),
              )
            else
              Positioned(
                bottom: 6,
                left: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: Colors.black.withAlpha((0.5 * 255).round())),
                  child: const Text('Tap to set as cover', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w400)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ---------- Media picking ----------
  void _showImagePicker(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        child: SafeArea(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.withAlpha((0.3 * 255).round()), borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            Text(l10n.addPhotos, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E))),
            const SizedBox(height: 20),
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
            _buildPickerOption(
              context,
              icon: Icons.photo_library_outlined,
              title: 'Photo Library',
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ]),
        ),
      ),
    );
  }

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
            Icon(icon, color: const Color(0xFF6E8EFB), size: 24),
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

  Future<void> _pickImage(ImageSource source) async {
    if (source == ImageSource.gallery) {
      await _pickFromGallery();
    } else {
      await _pickFromCamera();
    }
  }

  Future<void> _pickFromGallery() async {
    final viewModel = ref.read(uploadPostViewModelProvider.notifier);
    final hasPermission = await PermissionUtils.requestMediaAccessPermission();
    if (!mounted) return;

    if (!hasPermission) {
      await PermissionDialog.show(
        context,
        title: AppLocalizations.of(context)!.galleryPermissionTitle,
        message: AppLocalizations.of(context)!.galleryPermissionMessage,
      );
      return;
    }

    final result = await Navigator.of(context).push<List<UploadableMedia>>(
      MaterialPageRoute(builder: (_) => const MediaGalleryScreen()),
    );
    if (!mounted) return; // 👈 after async gap, before using context/ref

    if (result == null || result.isEmpty) return;

    final currentMedia = ref.read(uploadPostViewModelProvider).media;
    final totalMedia = [...currentMedia, ...result];
    if (totalMedia.length <= 10) {
      viewModel.setMedia(totalMedia);
    } else {
      viewModel.setMedia(totalMedia.take(10).toList());
      if (!mounted) return;
      _snack(context, 'Maximum 10 photos allowed', orange: true);
    }
  }

  Future<void> _pickFromCamera() async {
    final viewModel = ref.read(uploadPostViewModelProvider.notifier);
    final hasPermission = await PermissionUtils.requestCameraPermission();
    final isPermanentlyDenied = await Permission.camera.isPermanentlyDenied;
    if (!mounted) return;

    if (!hasPermission) {
      if (isPermanentlyDenied) {
        await PermissionDialog.show(
          context,
          title: AppLocalizations.of(context)!.cameraPermissionTitle,
          message: AppLocalizations.of(context)!.cameraPermissionMessage,
        );
      }
      return;
    }

    final picker = ImagePicker();
    final XFile? file = await picker.pickImage(source: ImageSource.camera);
    if (!mounted) return; // 👈 after async gap

    if (file != null) {
      try {
        final asset = await PhotoManager.editor.saveImageWithPath(file.path);
        if (!mounted) return; // 👈 after async gap

        final media = UploadableMedia(id: asset.id, asset: asset, type: MediaType.image);
        final currentMedia = ref.read(uploadPostViewModelProvider).media;
        if (currentMedia.length < 10) {
          viewModel.setMedia([...currentMedia, media]);
        } else {
          _snack(context, 'Maximum 10 photos allowed', orange: true);
        }
      } catch (e) {
        if (!mounted) return;
        _snack(context, 'Failed to save photo', red: true);
      }
    }
  }

  // ---------- Step 1: Title / Description / Caption / Price ----------
  Widget _buildCaptionPriceStep(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final viewModel = ref.read(uploadPostViewModelProvider.notifier);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(l10n.captionAndPriceTitle, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E), letterSpacing: -0.5)),
        const SizedBox(height: 8),
        Text(l10n.addCaptionHint, style: TextStyle(fontSize: 16, color: Colors.grey.withAlpha((0.7 * 255).round()), height: 1.4)),
        const SizedBox(height: 24),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha((0.7 * 255).round()),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withAlpha((0.2 * 255).round()), width: 1),
              boxShadow: [BoxShadow(color: Colors.black.withAlpha((0.05 * 255).round()), blurRadius: 20, offset: const Offset(0, 8))],
            ),
            child: SingleChildScrollView(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Title', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E))),
                const SizedBox(height: 8),
                _boxedTextField(
                  context,
                  hint: 'e.g. Vintage red rayon dress',
                  onChanged: viewModel.setTitle,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(120),
                    FilteringTextInputFormatter.deny(RegExp(r'[<>/\|]')),
                  ],
                ),
                const SizedBox(height: 20),

                const Text('Description', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E))),
                const SizedBox(height: 8),
                _boxedTextField(
                  context,
                  maxLines: 4,
                  hint: 'Key details, fabric, fit, special notes…',
                  onChanged: viewModel.setDescription,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(1000),
                    FilteringTextInputFormatter.deny(RegExp(r'[<>/\|]')),
                  ],
                ),
                const SizedBox(height: 20),

                Text('Caption', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E))),
                const SizedBox(height: 8),
                _boxedTextField(
                  context,
                  maxLines: 3,
                  hint: 'Describe your item...',
                  onChanged: viewModel.setCaption,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(500),
                    FilteringTextInputFormatter.deny(RegExp(r'[<>/\|]')),
                  ],
                ),
                const SizedBox(height: 20),

                Text('Price', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E))),
                const SizedBox(height: 8),
                Container(
                  decoration: _boxDecoration(context),
                  child: TextField(
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                      TextInputFormatter.withFunction((oldValue, newValue) {
                        final text = newValue.text;
                        if (text.contains('.') && text.indexOf('.') != text.lastIndexOf('.')) return oldValue;
                        if (text.startsWith('.')) return oldValue;
                        final parts = text.split('.');
                        if (parts.length > 1 && parts[1].length > 2) return oldValue;
                        return newValue;
                      }),
                    ],
                    onChanged: (value) => viewModel.setPrice(double.tryParse(value)),
                    decoration: InputDecoration(
                      hintText: '0.00',
                      hintStyle: TextStyle(color: Colors.grey.withAlpha((0.5 * 255).round())),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(16),
                      prefixText: l10n.currencyShekel,
                      prefixStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF1A1A2E)),
                    ),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF1A1A2E)),
                  ),
                ),
                const SizedBox(height: 20),

                Row(children: [
                  Expanded(child: _secondaryButton('Back', _previousPage)),
                  const SizedBox(width: 12),
                  Expanded(child: _primaryButton(l10n.next, _nextPage)),
                ]),
              ]),
            ),
          ),
        ),
      ]),
    );
  }

  // ---------- Step 2: Item details ----------
  Widget _buildItemDetailsStep(BuildContext context, AppLocalizations l10n) {
    final viewModel = ref.read(uploadPostViewModelProvider.notifier);
    final state = ref.watch(uploadPostViewModelProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(l10n.itemDetailsTitle, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E), letterSpacing: -0.5)),
        const SizedBox(height: 8),
        Text(l10n.itemDetailsDescription, style: TextStyle(fontSize: 16, color: Colors.grey.withAlpha((0.7 * 255).round()), height: 1.4)),
        const SizedBox(height: 24),

        _buildDetailField(
          l10n.categoryLabel,
          l10n.selectCategoryHint,
          Icons.category_outlined,
          onTap: () => _showCategoryPicker(context, viewModel),
          value: ref.watch(categoryByIdProvider(state.categoryId)).when(
                data: (category) => category?.name,
                loading: () => '',
                error: (err, stack) => null,
              ),
        ),

        FormField<String>(
          initialValue: state.conditionCode,
          validator: (val) => (val == null || val.isEmpty) ? AppLocalizations.of(context)!.conditionRequiredError : null,
          builder: (field) => ConditionDropdown(
            selectedCode: field.value,
            onChanged: (val) {
              field.didChange(val);
              viewModel.setConditionCode(val);
            },
          ),
        ),

        _buildDetailField(
          l10n.sizeLabel,
          l10n.selectSizeHint,
          Icons.straighten_outlined,
          onTap: () => _showSizePicker(context, viewModel),
          value: state.size,
        ),

        _buildTextDetailField('${l10n.brandLabel} (${l10n.optional})', l10n.enterBrandHint, Icons.store_outlined, onChanged: viewModel.setBrand),

        MaterialsSelector(
          selectedCodes: state.materialCodes,
          onChanged: viewModel.setMaterialCodes,
          otherMaterial: state.otherMaterial,
          onOtherChanged: viewModel.setOtherMaterial,
        ),
        const SizedBox(height: 8),

        DefectsSelector(
          selectedCodes: state.defectCodes,
          onChanged: viewModel.setDefectCodes,
          otherNote: state.otherDefectNote,
          onOtherChanged: viewModel.setOtherDefectNote,
        ),
        const SizedBox(height: 8),

        ColorSelector(selectedCodes: state.colorCodes, onChanged: viewModel.setColorCodes),
        const SizedBox(height: 8),

        Text('${l10n.measurementsLabel} (${l10n.optional})', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E))),
        const SizedBox(height: 12),

        Row(children: [
          Expanded(child: _buildMeasurementField(l10n.chest, l10n.centimetersAbbreviation, onChanged: (v) => viewModel.setChest(double.tryParse(v)))),
          const SizedBox(width: 12),
          Expanded(child: _buildMeasurementField(l10n.waist, l10n.centimetersAbbreviation, onChanged: (v) => viewModel.setWaist(double.tryParse(v)))),
          const SizedBox(width: 12),
          Expanded(child: _buildMeasurementField(l10n.length, l10n.centimetersAbbreviation, onChanged: (v) => viewModel.setLength(double.tryParse(v)))),
        ]),
        const SizedBox(height: 32),

        Row(children: [
          Expanded(child: _secondaryButton('Back', _previousPage)),
          const SizedBox(width: 12),
          Expanded(child: _primaryButton('Next', _nextPage)),
        ]),
        const SizedBox(height: 24),
      ]),
    );
  }

  // ---------- Step 3: Tags / Publish ----------
  Widget _buildTagsStep(AppLocalizations l10n) {
    final state = ref.watch(uploadPostViewModelProvider);
    final viewModel = ref.read(uploadPostViewModelProvider.notifier);
    final isSubmitting = state.isSubmitting;
    final allTags = ref.watch(tagsProvider);

    if (!mounted) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(l10n.tagsAndStyleTitle, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E), letterSpacing: -0.5)),
        const SizedBox(height: 8),
        Text(l10n.tagsAndStyleDescription, style: TextStyle(fontSize: 16, color: Colors.grey.withAlpha((0.7 * 255).round()), height: 1.4)),
        const SizedBox(height: 24),

        Expanded(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha((0.7 * 255).round()),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withAlpha((0.2 * 255).round()), width: 1),
              boxShadow: [BoxShadow(color: Colors.black.withAlpha((0.05 * 255).round()), blurRadius: 20, offset: const Offset(0, 8))],
            ),
            child: SingleChildScrollView(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(l10n.styleTagsLabel, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E))),
                const SizedBox(height: 12),
                allTags.when(
                  data: (availableTags) => Wrap(
                    spacing: 8.0, runSpacing: 8.0,
                    children: availableTags.map((tag) {
                      return _TagChip(
                        label: tag.name,
                        isSelected: state.tagNames.contains(tag.name),
                        onTap: () => _toggleTag(tag.name, viewModel),
                      );
                    }).toList(),
                  ),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, stackTrace) => Center(child: Text(l10n.error_loading_tags)),
                ),
                const SizedBox(height: 24),

                Text(l10n.customTagsLabel, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E))),
                const SizedBox(height: 8),
                Text(l10n.customTagsHint, style: TextStyle(fontSize: 14, color: Colors.grey.withAlpha((0.6 * 255).round()))),
                const SizedBox(height: 12),
                _buildCustomTagsInput(viewModel),
                const SizedBox(height: 20),

                if (state.tagNames.isNotEmpty) ...[
                  Text(l10n.selectedTagsLabel, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E))),
                  const SizedBox(height: 12),
                  _buildSelectedTags(state.tagNames, viewModel),
                  const SizedBox(height: 24),
                ],

                const SizedBox(height: 32),

                Row(children: [
                  Expanded(child: _secondaryButton('Back', isSubmitting ? null : _previousPage)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: isSubmitting ? null : () => _publishItem(viewModel, l10n),
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: isSubmitting
                              ? LinearGradient(colors: [Colors.grey.withAlpha((0.3 * 255).round()), Colors.grey.withAlpha((0.4 * 255).round())])
                              : const LinearGradient(colors: [Color(0xFF6E8EFB), Color(0xFF9BB5FF)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: isSubmitting ? [] : [BoxShadow(color: const Color(0xFF6E8EFB).withAlpha((0.3 * 255).round()), blurRadius: 8, offset: const Offset(0, 2))],
                        ),
                        child: Center(
                          child: isSubmitting
                              ? Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                  const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white))),
                                  const SizedBox(width: 8),
                                  Text(l10n.publishingButton, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white.withAlpha((0.8 * 255).round()))),
                                ])
                              : Text(l10n.publishItemButton, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                        ),
                      ),
                    ),
                  ),
                ]),
              ]),
            ),
          ),
        ),
      ]),
    );
  }

  // ---------- Reusable bits ----------
  BoxDecoration _boxDecoration(BuildContext context) => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withAlpha((0.2 * 255).round()), width: 1),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha((0.03 * 255).round()), blurRadius: 4, offset: const Offset(0, 2))],
      );

  Widget _boxedTextField(
    BuildContext context, {
    int maxLines = 1,
    required String hint,
    required ValueChanged<String> onChanged,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Container(
      decoration: _boxDecoration(context),
      child: TextField(
        maxLines: maxLines,
        onChanged: onChanged,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.withAlpha((0.5 * 255).round())),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
        style: const TextStyle(fontSize: 16, color: Color(0xFF1A1A2E)),
      ),
    );
  }

  Widget _secondaryButton(String label, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.grey.withAlpha((0.1 * 255).round()),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withAlpha((0.2 * 255).round()), width: 1),
        ),
        child: Center(child: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E)))),
      ),
    );
  }

  Widget _primaryButton(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF6E8EFB), Color(0xFF9BB5FF)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: const Color(0xFF6E8EFB).withAlpha((0.3 * 255).round()), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Center(child: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white))),
      ),
    );
  }

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
          border: Border.all(color: Colors.grey.withAlpha(51), width: 1),
          boxShadow: [BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: const Color(0xFF6E8EFB).withAlpha(26), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: const Color(0xFF6E8EFB), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                label,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 2),
              Text(
                hasValue ? value! : placeholder,
                style: TextStyle(
                  fontSize: 16,
                  color: hasValue ? const Color(0xFF111827) : const Color(0xFF9CA3AF),
                  fontWeight: hasValue ? FontWeight.w500 : FontWeight.normal,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ]),
          ),
          const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Color(0xFF9CA3AF)),
        ]),
      ),
    );
  }

  Widget _buildTextDetailField(
    String label,
    String placeholder,
    IconData icon, {
    Function(String)? onChanged,
  }) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E))),
      const SizedBox(height: 6),
      Container(
        decoration: _boxDecoration(context),
        child: TextField(
          onChanged: onChanged,
          inputFormatters: [
            LengthLimitingTextInputFormatter(100),
            FilteringTextInputFormatter.deny(RegExp(r'[<>/\|]')),
          ],
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: TextStyle(color: Colors.grey.withAlpha((0.5 * 255).round())),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.all(16),
            prefixIcon: Icon(icon, color: const Color(0xFF6E8EFB), size: 20),
          ),
          style: const TextStyle(fontSize: 16, color: Color(0xFF1A1A2E)),
        ),
      ),
    ]);
  }

  Widget _buildMeasurementField(String label, String unit, {Function(String)? onChanged}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E))),
      const SizedBox(height: 4),
      Container(
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.withAlpha((0.2 * 255).round()), width: 1),
        ),
        child: TextField(
          keyboardType: TextInputType.number,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: '0',
            hintStyle: TextStyle(color: Colors.grey.withAlpha((0.5 * 255).round())),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            suffixText: unit,
            suffixStyle: TextStyle(fontSize: 12, color: Colors.grey.withAlpha((0.6 * 255).round())),
          ),
          style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A2E)),
        ),
      ),
    ]);
  }

  void _showCategoryPicker(BuildContext context, UploadPostViewModel viewModel) {
    final categoriesFuture = ref.read(categoriesProvider.future);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return FutureBuilder<List<Category>>(
          future: categoriesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
            if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
            if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text('No categories found.'));
            final list = snapshot.data!;
            return _buildPickerSheet(
              title: 'Select Category',
              items: list.map((c) => c.name).toList(),
              onSelected: (value) {
                final selected = list.firstWhere((c) => c.name == value);
                viewModel.setCategory(selected.id);
                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
  }

  void _showSizePicker(BuildContext context, UploadPostViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildPickerSheet(
        title: 'Select Size',
        items: const ['XS', 'S', 'M', 'L', 'XL', 'XXL', 'One Size', 'Other'],
        onSelected: (value) {
          viewModel.setSize(value);
          Navigator.pop(context);
        },
      ),
    );
  }

  Widget _buildPickerSheet({required String title, required List<String> items, required Function(String) onSelected}) {
    return Container(
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 16),
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E))),
        const SizedBox(height: 16),
        SizedBox(
          height: 300,
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
                title: Text(item, style: const TextStyle(fontSize: 16, color: Color(0xFF1A1A2E))),
                onTap: () => onSelected(item),
              );
            },
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              backgroundColor: Colors.grey[100],
            ),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF6B7280), fontSize: 16, fontWeight: FontWeight.w500)),
          ),
        ),
      ]),
    );
  }

  Widget _buildSelectedTags(List<String> tags, UploadPostViewModel viewModel) {
    return Wrap(
      spacing: 8, runSpacing: 8,
      children: tags.map((tag) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF6E8EFB).withAlpha((0.1 * 255).round()),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF6E8EFB).withAlpha((0.2 * 255).round()), width: 1),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text(tag, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF6E8EFB))),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: () => _removeTag(tag, viewModel),
              child: Icon(Icons.close, size: 14, color: const Color(0xFF6E8EFB).withAlpha((0.7 * 255).round())),
            ),
          ]),
        );
      }).toList(),
    );
  }

  void _removeTag(String tag, UploadPostViewModel viewModel) {
    final currentTags = ref.read(uploadPostViewModelProvider).tagNames;
    viewModel.setTags(currentTags.where((t) => t != tag).toList());
  }

  void _toggleTag(String tag, UploadPostViewModel viewModel) {
    final current = ref.read(uploadPostViewModelProvider).tagNames;
    if (current.contains(tag)) {
      viewModel.setTags(current.where((t) => t != tag).toList());
    } else {
      viewModel.setTags([...current, tag]);
    }
  }

  void _handleCustomTagsInput(String input, UploadPostViewModel viewModel) {
    final newTags = input
        .split(',')
        .map((t) => t.replaceAll(RegExp(r'[^\u0590-\u05FFa-zA-Z0-9 ]'), '').trim())
        .where((t) => t.isNotEmpty)
        .toSet();
    if (newTags.isEmpty) return;

    final current = ref.read(uploadPostViewModelProvider).tagNames.toSet();
    final unique = newTags.difference(current);
    if (unique.isNotEmpty) viewModel.setTags([...current, ...unique].toList());
  }

  Widget _buildCustomTagsInput(UploadPostViewModel viewModel) {
    final controller = TextEditingController();
    return Container(
      decoration: _boxDecoration(context),
      child: TextField(
        controller: controller,
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\u0590-\u05FFa-zA-Z0-9, ]'))],
        onSubmitted: (value) {
          _handleCustomTagsInput(value, viewModel);
          controller.clear();
        },
        decoration: InputDecoration(
          hintText: 'e.g. summer, party, comfortable',
          hintStyle: TextStyle(color: Colors.grey.withAlpha((0.5 * 255).round())),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
          prefixIcon: const Icon(Icons.local_offer_outlined, color: Color(0xFF6E8EFB), size: 20),
        ),
        style: const TextStyle(fontSize: 16, color: Color(0xFF1A1A2E)),
        textInputAction: TextInputAction.done,
      ),
    );
  }

  Future<void> _publishItem(UploadPostViewModel viewModel, AppLocalizations l10n) async {
    try {
      await viewModel.submit();
      if (!mounted) return;
      context.go('/home');
    } on AppException catch (e) {
      if (!mounted) return;
      String errorMessage;
      switch (e.message) {
        case 'price_must_be_above_min':
          errorMessage = 'Price must be greater than 1 ILS';
          break;
        case 'uploadTitleRequiredBackend':
          errorMessage = 'Title is required';
          break;
        case 'uploadDescriptionRequiredBackend':
          errorMessage = 'Description is required';
          break;
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
      _snack(context, errorMessage, red: true);
    } catch (e) {
      if (!mounted) return;
      _snack(context, l10n.failed_to_publish_item(e.toString()), red: true);
    }
  }

  void _snack(BuildContext context, String msg, {bool orange = false, bool red = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: red ? Colors.red : (orange ? Colors.orange : Colors.black87)),
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.label, required this.isSelected, this.onTap});
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
          style: TextStyle(color: isSelected ? Colors.white : Colors.black, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}

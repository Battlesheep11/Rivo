import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rivo_app_beta/core/localization/generated/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:rivo_app_beta/features/onboarding/presentation/viewmodels/onboarding_view_model.dart';
import 'package:rivo_app_beta/features/onboarding/presentation/widgets/tag_selector_widget.dart';
import 'package:rivo_app_beta/features/onboarding/domain/usecases/save_profile_info_usecase_provider.dart';
import 'package:rivo_app_beta/features/profile/domain/entities/user_profile_entity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rivo_app_beta/core/design_system/design_system.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rivo_app_beta/core/media/data/media_compressor.dart';
import 'package:rivo_app_beta/core/localization/locale_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rivo_app_beta/core/analytics/analytics_service.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  File? _avatarFile;
  String? _avatarUrl;
  bool _isUploadingAvatar = false;

  String? _selectedSource;
  final List<String> _referralOptions = [
    'Instagram',
    'TikTok',
    'Google',
    'Friend',
    'Other',
  ];

  @override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    ref.read(onboardingViewModelProvider.notifier).loadTags();
    AnalyticsService.logScreenView(screenName: 'onboarding_profile_info');

    // UTM: קליטת פרמטרים מה-URL
    final uri = GoRouterState.of(context).uri;

    final Map<String, String> utmParams = {
      'utm_source': uri.queryParameters['utm_source'] ?? '',
      'utm_medium': uri.queryParameters['utm_medium'] ?? '',
      'utm_campaign': uri.queryParameters['utm_campaign'] ?? '',
      'utm_term': uri.queryParameters['utm_term'] ?? '',
      'utm_content': uri.queryParameters['utm_content'] ?? '',
      'referral_code': uri.queryParameters['ref'] ?? '',
    };

    ref.read(onboardingViewModelProvider.notifier).setUTMParams(utmParams);
  });
}


  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _bioController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _goToNextPage() {
    if (_currentPage < 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final hasSelectedTags =
        ref.watch(onboardingViewModelProvider.select((s) => s.selectedTags.isNotEmpty));

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          if (_currentPage == 0)
            TextButton(
              onPressed: _goToNextPage,
              child: Text(t.onboardingSkip),
            ),
        ],
      ),
      resizeToAvoidBottomInset: true,
      body: PageView(
        controller: _controller,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (index) {
          if (!mounted) return;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            setState(() => _currentPage = index);
            if (index == 1) {
              AnalyticsService.logScreenView(screenName: 'onboarding_tags');
            }
          });
        },
        children: [
          _buildProfileInfoPage(t),
          _buildTagSelectionPage(t),
        ],
      ),
      bottomNavigationBar: _buildBottomButton(t: t, enabled: _currentPage == 0 ? true : hasSelectedTags),
    );
  }

  Widget _buildProfileInfoPage(AppLocalizations t) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          Text(
            t.onboardingWelcomeTitle,
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(t.onboardingWelcomeSubtitle, textAlign: TextAlign.center),
          const SizedBox(height: 24),
          Center(
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                  backgroundImage: _avatarFile != null
                      ? FileImage(_avatarFile!)
                      : (_avatarUrl != null ? NetworkImage(_avatarUrl!) as ImageProvider : null),
                  child: (_avatarFile == null && _avatarUrl == null)
                      ? const Icon(Icons.person, size: 48)
                      : null,
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Center(
                    child: Tooltip(
                      message: t.selectMedia,
                      child: Material(
                        color: Theme.of(context).colorScheme.primary,
                        shape: const CircleBorder(),
                        elevation: 2,
                        child: InkWell(
                          onTap: _isUploadingAvatar ? null : _pickAvatar,
                          customBorder: const CircleBorder(),
                          child: SizedBox(
                            width: 40,
                            height: 40,
                            child: Center(
                              child: _isUploadingAvatar
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : Icon(Icons.edit, size: 18, color: Theme.of(context).colorScheme.onPrimary),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(t.authFirstName),
          const SizedBox(height: 8),
          AppTextField(controller: _firstNameController, hintText: t.authFirstNameHint),
          const SizedBox(height: 16),
          Text(t.authLastName),
          const SizedBox(height: 8),
          AppTextField(controller: _lastNameController, hintText: t.authLastNameHint),
          const SizedBox(height: 16),
          Text(t.bioHint),
          const SizedBox(height: 8),
          AppTextField(controller: _bioController, hintText: t.bioHint, maxLines: 4, maxLength: 500),
          const SizedBox(height: 16),
          Text(t.onboardingHowDidYouHear),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _selectedSource,
            items: _referralOptions
                .map((source) => DropdownMenuItem(value: source, child: Text(source)))
                .toList(),
            onChanged: (value) {
              setState(() => _selectedSource = value);
              if (value != null) {
                AnalyticsService.logEvent('onboarding_source_selected', parameters: {
                  'source': value,
                });
              }
            },
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              hintText: t.onboardingHowDidYouHearHint,
            ),
          ),
        ],
      ),
    );
  }

  // Pick an avatar image from gallery and lightly compress it for upload
  Future<void> _pickAvatar() async {
  // Ask user to choose image source (camera or gallery) — images only
  final t = AppLocalizations.of(context)!;
  final ImageSource? source = await showModalBottomSheet<ImageSource>(
    context: context,
    builder: (sheetContext) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text(t.mediaPickerCamera),
              onTap: () => Navigator.of(sheetContext).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(t.mediaPickerGallery),
              onTap: () => Navigator.of(sheetContext).pop(ImageSource.gallery),
            ),
          ],
        ),
      );
    },
  );

  if (source == null) return; // user dismissed

AnalyticsService.logEvent('avatar_selected', parameters: {
  'source': source.name, // camera or gallery
});



  // Request/check permissions for the chosen source before proceeding
  final granted = await _ensurePermissionForSource(source);
  if (!granted) return;

  // Limit to pictures only by using pickImage
  final picker = ImagePicker();
  final XFile? picked = await picker.pickImage(source: source);
  if (picked == null) return;

  // Compress photo before upload to save bandwidth
  final rawFile = File(picked.path);
  final result = await MediaCompressor.compressImageFile(rawFile, quality: 88);
  final File file = result.fold<File>((compressed) => compressed, (_) => rawFile);

  if (!mounted) return;
  setState(() {
    _avatarFile = file;
    _avatarUrl = null; // reset uploaded url if re‑selecting
  });
}

  // Check and request permission based on selected source (camera/gallery)
  Future<bool> _ensurePermissionForSource(ImageSource source) async {
    final t = AppLocalizations.of(context)!;

    if (source == ImageSource.camera) {
      final status = await Permission.camera.request();
      if (status.isGranted) return true;
      await _showPermissionDialog(
        title: t.cameraPermissionTitle,
        message: t.cameraPermissionMessage,
      );
      return false;
    } else {
      // Gallery/photos permission differs by platform
      Permission galleryPermission = Platform.isIOS ? Permission.photos : Permission.storage;
      final status = await galleryPermission.request();
      if (status.isGranted) return true;
      await _showPermissionDialog(
        title: t.galleryPermissionTitle,
        message: t.galleryPermissionMessage,
      );
      return false;
    }
  }

  // Show a localized dialog guiding users to grant permissions or open settings
  Future<void> _showPermissionDialog({required String title, required String message}) async {
    final t = AppLocalizations.of(context)!;
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(t.permissionDialogCancel),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(ctx).pop();
                await openAppSettings();
              },
              child: Text(t.permissionDialogOpenSettings),
            ),
          ],
        );
      },
    );
  }

  // Upload the avatar file to Supabase Storage (media bucket → avatars/)
  Future<String> _uploadAvatar({
    required SupabaseClient client,
    required String userId,
    required File file,
  }) async {
    final filename = '${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final relativePath = 'avatars/$filename'; // path relative to 'media' bucket

    final bytes = await file.readAsBytes();
    await client.storage.from('media').uploadBinary(
      relativePath,
      bytes,
      fileOptions: const FileOptions(
        contentType: 'image/jpeg',
        upsert: true,
      ),
    );

    // Public URL to store in profile
    return client.storage.from('media').getPublicUrl(relativePath);
  }

  Widget _buildTagSelectionPage(AppLocalizations t) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            t.onboardingTagSelectionTitle,
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Expanded(
            child: TagSelectorWidget(),
          ),
          // Action button moved to bottomNavigationBar to keep it visible above system bars
        ],
      ),
    );
  }

  // Unified bottom action button so it's always visible (wrapped in SafeArea)
  Widget _buildBottomButton({
    required AppLocalizations t,
    required bool enabled,
  }) {
    final isProfilePage = _currentPage == 0;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: enabled
                ? () async {
                    if (isProfilePage) {
                      await _onNextFromProfile();
                    } else {
                      await _onFinishTags();
                    }
                  }
                : null,
            child: Text(isProfilePage ? t.next : t.onboardingFinishButton),
          ),
        ),
      ),
    );
  }

  // Extracted handler for the profile page Next action
  Future<void> _onNextFromProfile() async {
    final saveProfileInfoUseCase = ref.read(saveProfileInfoUseCaseProvider);
    final client = Supabase.instance.client;
    final userId = client.auth.currentUser?.id;
    if (userId != null) {
      final firstName = _firstNameController.text.trim();
      final lastName = _lastNameController.text.trim();
      final bio = _bioController.text.trim();

      // Resolve language from current locale (avoid hardcoding)
      final locale = ref.read(localeProvider);
      String? avatarUrl = _avatarUrl;

      // If user picked an avatar file, upload it to Supabase Storage first
      if (_avatarFile != null) {
        setState(() => _isUploadingAvatar = true);
        try {
          avatarUrl = await _uploadAvatar(
            client: client,
            userId: userId,
            file: _avatarFile!,
          );
          if (mounted) setState(() => _avatarUrl = avatarUrl);
        } catch (_) {
          // Silent fail — avatar is optional
        } finally {
          if (mounted) setState(() => _isUploadingAvatar = false);
        }
      }
      final utm = ref.read(onboardingViewModelProvider).utmParams;


      final user = UserProfileEntity(
        id: userId,
        username: '',
        firstName: firstName.isEmpty ? null : firstName,
        lastName: lastName.isEmpty ? null : lastName,
        bio: bio.isEmpty ? null : bio,
        avatarUrl: avatarUrl, // uploaded public URL (if any)
        isSeller: false,
        language: locale.languageCode, // dynamic from localeProvider
        lastSeenAt: null,
        createdAt: null,
        onboardingSource: _selectedSource,
        utmSource: utm['utm_source'],
        utmMedium: utm['utm_medium'],
        utmCampaign: utm['utm_campaign'],
        utmTerm: utm['utm_term'],
        utmContent: utm['utm_content'],
        referralCode: utm['referral_code'],
      );
      try {
        await saveProfileInfoUseCase.execute(user);
        AnalyticsService.logEvent('onboarding_profile_completed', parameters: {
  'has_avatar': _avatarUrl != null,
});
      } catch (_) {
        // Silent fail — optional step
      }
    }
    _goToNextPage();
  }

  // Extracted handler for the tags page Finish action
  Future<void> _onFinishTags() async {
    final viewModel = ref.read(onboardingViewModelProvider.notifier);
    await viewModel.submitTags();
    final count = ref.read(onboardingViewModelProvider).selectedTags.length;
AnalyticsService.logEvent('onboarding_tags_completed', parameters: {
  'selected_tag_count': count,
});
    if (!mounted) return;
    context.go('/home');
  }
}

import 'package:flutter/material.dart';
import 'package:rivo_app_beta/core/design_system/design_system.dart';
import 'package:rivo_app_beta/features/profile/data/models/profile_model.dart';
import 'package:rivo_app_beta/core/localization/generated/app_localizations.dart';
import 'package:rivo_app_beta/features/profile/data/profile_service.dart';
import 'package:rivo_app_beta/features/onboarding/presentation/viewmodels/onboarding_view_model.dart';
import 'package:rivo_app_beta/features/onboarding/presentation/widgets/tag_selector_widget.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ProfileHeader extends StatefulWidget {
  final Profile profile;

  const ProfileHeader({super.key, required this.profile});

  @override
  State<ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<ProfileHeader> {
  late Profile _profile;
  String? _selectedTag;

  @override
  void initState() {
    super.initState();
    _profile = widget.profile;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Top row: avatar, user info
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: NetworkImage(_profile.avatarUrl ?? 'https://i.pravatar.cc/150?u=${_profile.id}'),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_profile.fullName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.onSurface)), // User name
                    const SizedBox(height: 4),
                    Text('@${_profile.username}', style: const TextStyle(fontSize: 16, color: AppColors.gray600)), // Username
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStat(AppLocalizations.of(context)!.followers, _profile.followers.toString()),
              _buildStat(AppLocalizations.of(context)!.following, _profile.following.toString()),
            ],
          ),
          const SizedBox(height: 16),
          // Bio row with edit button
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  _profile.bio ?? AppLocalizations.of(context)!.noBioYet,
                  style: const TextStyle(fontSize: 14, color: AppColors.onSurface),
                  textAlign: TextAlign.center,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit, size: 18, color: AppColors.gray500),
                tooltip: AppLocalizations.of(context)!.editBio,
                onPressed: () async {
                  // Show edit bio dialog and wait for result
                  final newBio = await showDialog<String>(
                    context: context,
                    builder: (context) => _EditBioDialog(
                      initialBio: _profile.bio ?? '',
                      userId: _profile.id,
                    ),
                  );

                  if (newBio != null) {
                    setState(() {
                      _profile = _profile.copyWith(bio: newBio);
                    });
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Tags row with edit button
          if (_profile.tags.isNotEmpty)
            Row(
              mainAxisAlignment: MainAxisAlignment.center, // Center the row content
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Center(
                    child: Center(
                      child: Wrap(
                        spacing: 8.0,
                        runSpacing: 4.0,
                        children: _profile.tags.map((tag) => _buildTag(tag)).toList(),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, size: 18, color: AppColors.gray500),
                  tooltip: AppLocalizations.of(context)!.editTags,
                  onPressed: () async {
                    // Show tag selection dialog
                    await showDialog(
                      context: context,
                      builder: (context) => const _EditTagsDialog(),
                    );
                  },
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String count) {
    return Column(
      children: [
        Text(count, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 14, color: AppColors.gray600)),
      ],
    );
  }

  Widget _buildTag(String tagName) {
    final bool isSelected = _selectedTag == tagName;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTag = isSelected ? null : tagName;
        });
      },
      child: Chip(
        label: Text('#$tagName'),
        backgroundColor: AppColors.gray100,
        labelStyle: const TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.w500),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? AppColors.onSurface : AppColors.gray200,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
      ),
    );
  }
}

// Dialog for editing the user's bio.
class _EditBioDialog extends StatefulWidget {
  final String initialBio;
  final String userId;

  const _EditBioDialog({required this.initialBio, required this.userId});

  @override
  State<_EditBioDialog> createState() => _EditBioDialogState();
}

class _EditBioDialogState extends State<_EditBioDialog> {
  late final TextEditingController _controller;
  final int _maxChars = 500;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialBio);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _saveBio() async {
    // Capture the context-dependent objects before the async gap.
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final localizations = AppLocalizations.of(context)!;

    try {
      await ProfileService().updateBio(widget.userId, _controller.text);
    } catch (e) {
      if (!mounted) return;
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(localizations.failedToUpdateBio),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(localizations.editBio),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            maxLines: 5,
            maxLength: _maxChars,
            decoration: InputDecoration(
              hintText: localizations.bioHint,
              border: const OutlineInputBorder(),
              counterText: '', // Hide the default counter
            ),
          ),
          const SizedBox(height: 8),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _controller,
            builder: (context, value, child) {
              final charsLeft = _maxChars - value.text.length;
              return Align(
                alignment: Alignment.centerRight,
                child: Text(
                  localizations.charactersLeft(charsLeft),
                  style: const TextStyle(fontSize: 12, color: AppColors.gray600),
                ),
              );
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(localizations.cancel),
        ),
        ElevatedButton(
          onPressed: () async {
            final navigator = Navigator.of(context);
            await _saveBio();
            if (!mounted) return;
            navigator.pop(_controller.text);
          },
          child: Text(localizations.save),
        ),
      ],
    );
  }
}

// Dialog for editing user's tags.
class _EditTagsDialog extends ConsumerStatefulWidget {
  const _EditTagsDialog();

  @override
  ConsumerState<_EditTagsDialog> createState() => _EditTagsDialogState();
}

class _EditTagsDialogState extends ConsumerState<_EditTagsDialog> {
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(localizations.editTags),
      content: const SizedBox(
        width: double.maxFinite,
        child: TagSelectorWidget(), // Re-use the tag selector from onboarding
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(localizations.cancel),
        ),
        ElevatedButton(
          onPressed: () async {
            final navigator = Navigator.of(context);
            // Use the view model to submit the selected tags
            await ref.read(onboardingViewModelProvider.notifier).submitTags();
            if (!mounted) return;
            navigator.pop();
          },
          child: Text(localizations.save),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rivo_app_beta/core/design_system/design_system.dart';
import 'package:rivo_app_beta/features/profile/data/models/profile_model.dart';
import 'package:rivo_app_beta/core/localization/generated/app_localizations.dart';
import 'package:rivo_app_beta/features/profile/data/profile_service.dart';
import 'package:rivo_app_beta/features/profile/presentation/providers/edit_tags_provider.dart';
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
                backgroundImage: NetworkImage(_profile.avatarUrl ?? 'https://nbrqyxsxsokrwkhpdvov.supabase.co/storage/v1/object/public/icons/greyicon.PNG'),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: _profile.tags.isEmpty
                    ? Text(
                        AppLocalizations.of(context)!.noTagsYet,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.gray600),
                      )
                    : Wrap(
                        spacing: 8.0,
                        runSpacing: 4.0,
                        alignment: WrapAlignment.center,
                        children: _profile.tags.map((tag) => _buildTag(tag)).toList(),
                      ),
              ),
              IconButton(
                icon: const Icon(Icons.edit, size: 18, color: AppColors.gray500),
                tooltip: AppLocalizations.of(context)!.editTags,
                onPressed: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  final saved = await showDialog<bool>(
                    context: context,
                    builder: (context) => const _EditTagsDialog(),
                  );

                  if (saved != true || !mounted) return;

                  try {
                    final profileData = await ProfileService().getProfileData(_profile.id);
                    final row = profileData['profile'] as Map<String, dynamic>?;

                    if (mounted && row != null) {
                      setState(() {
                        _profile = Profile.fromData(row); // <- now includes avatar_url correctly
                      });
                    }

                  } catch (e) {
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text('Failed to refresh profile: $e'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
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
            inputFormatters: [
              FilteringTextInputFormatter.deny(RegExp(r'[<>/\|]')), // Block dangerous characters
            ],
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
    final allTagsAsync = ref.watch(allTagsProvider);
    final selectedTagsAsync = ref.watch(editTagsProvider);
    
    return AlertDialog(
      title: Text(localizations.editTags),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: allTagsAsync.when(
          data: (allTags) => selectedTagsAsync.when(
            data: (selectedTags) => SingleChildScrollView(
              child: Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: allTags.map((tag) {
                  final isSelected = selectedTags.contains(tag);
                  return FilterChip(
                    label: Text(tag),
                    selected: isSelected,
                    onSelected: (selected) {
                      ref.read(editTagsProvider.notifier).selectTag(tag);
                    },
                    selectedColor: AppColors.primary.withAlpha(51), // Use withAlpha as per user rules
                    checkmarkColor: AppColors.primary,
                  );
                }).toList(),
              ),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Text('Error loading selected tags: $error'),
            ),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Text('Error loading tags: $error'),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            ref.read(editTagsProvider.notifier).reset();
            Navigator.of(context).pop();
          },
          child: Text(localizations.cancel),
        ),
        ElevatedButton(
          onPressed: selectedTagsAsync.isLoading ? null : () async {
            final navigator = Navigator.of(context);
            await ref.read(editTagsProvider.notifier).saveTags();
            if (!mounted) return;
            navigator.pop(true); // Return true to indicate tags were saved
          },
          child: selectedTagsAsync.isLoading 
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(localizations.save),
        ),
      ],
    );
  }
}

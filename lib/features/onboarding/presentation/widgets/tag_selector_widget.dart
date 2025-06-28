import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rivo_app/core/localization/generated/app_localizations.dart';
import 'package:rivo_app/features/onboarding/presentation/viewmodels/onboarding_view_model.dart';
import 'package:rivo_app/features/onboarding/domain/entities/tag_entity.dart';

class TagSelectorWidget extends ConsumerWidget {
  const TagSelectorWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final state = ref.watch(onboardingViewModelProvider);
    final viewModel = ref.read(onboardingViewModelProvider.notifier);

    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.allTags.isEmpty) {
      return Center(child: Text(t.errorLoadingData));
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: state.allTags.map((tagName) {
        final tag = TagEntity(name: tagName);
        final isSelected = state.selectedTags.contains(tagName);

        return FilterChip(
          label: Text(tag.localizedLabel(context)),
          selected: isSelected,
          onSelected: (_) => viewModel.toggleTag(tagName),
        );
      }).toList(),
    );
  }
}

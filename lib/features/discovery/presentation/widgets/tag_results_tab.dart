import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivo_app/core/localization/generated/app_localizations.dart';
import 'package:rivo_app/features/discovery/presentation/providers/search_query_provider.dart';
import 'package:rivo_app/features/discovery/presentation/providers/search_tags_provider.dart';
import 'package:rivo_app/features/discovery/presentation/widgets/tag_search_card.dart';

class TagResultsTab extends ConsumerWidget {
  const TagResultsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(searchQueryProvider);
    final tagsAsync = ref.watch(searchTagsProvider(query));

    return tagsAsync.when(
      data: (tags) {
        if (tags.isEmpty) {
          return Center(
            child: Text(AppLocalizations.of(context)!.noMatchingTags),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: tags.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            return TagSearchCard(tag: tags[index]);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Text('${AppLocalizations.of(context)!.errorOccurred} $e'),
      ),
    );
  }
}

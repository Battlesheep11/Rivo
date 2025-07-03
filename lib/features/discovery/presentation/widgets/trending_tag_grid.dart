import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivo_app/features/discovery/domain/entities/discovery_tag_entity.dart';
import 'package:rivo_app/features/discovery/presentation/providers/discovery_providers.dart';
import 'package:rivo_app/features/discovery/presentation/widgets/trending_tag_chip.dart';

class TrendingTagGrid extends ConsumerWidget {
  final void Function(DiscoveryTagEntity tag)? onTagTap;

  const TrendingTagGrid({super.key, this.onTagTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tagsAsync = ref.watch(trendingTagsProvider);

    return tagsAsync.when(
      data: (tags) => SizedBox(
        height: 44,
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: tags.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final tag = tags[index];
              return TrendingTagChip(
                tag: tag,
                onTap: () => onTagTap?.call(tag),
              );
            },
          ),
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error loading trending tags')),
    );
  }
}

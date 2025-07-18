import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivo_app_beta/core/localization/generated/app_localizations.dart';
import 'package:rivo_app_beta/features/discovery/presentation/providers/discovery_providers.dart';
import 'package:rivo_app_beta/features/discovery/presentation/widgets/curated_collection_card.dart';
import 'package:rivo_app_beta/features/discovery/presentation/widgets/trending_tag_grid.dart';
import 'package:rivo_app_beta/features/discovery/presentation/widgets/discover_users_tab.dart';

class DiscoverTopSection extends ConsumerWidget {
  const DiscoverTopSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collectionsAsync = ref.watch(curatedCollectionsProvider);

    return collectionsAsync.when(
      data: (collections) => ListView(
        key: const ValueKey('discover_top_section'),
        children: [ 
          const SizedBox(height: 32),
          Text(
            AppLocalizations.of(context)!.curatedCollectionsTitle,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 220,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: collections.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                return SizedBox(
                  width: 160, // 🔁 שימי לב שאפשר לכוונן
                  child: CuratedCollectionCard(collection: collections[index]),
                );
              },
            ),
          ),
          const SizedBox(height: 32),
          Text(
            AppLocalizations.of(context)!.trendingNow,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
            SizedBox(
              height: 44,
              child: TrendingTagGrid(
                onTagTap: (tag) {
                  debugPrint('Tapped trending tag: ${tag.name}');
                },
              ),
            ),

            const SizedBox(height: 32),
            Text(
              AppLocalizations.of(context)!.popularSellers,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 120,
              child: DiscoverUsersTab(),
            ),
            const SizedBox(height: 32),
        ],
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('⚠️ $e')),
    );
  }
}

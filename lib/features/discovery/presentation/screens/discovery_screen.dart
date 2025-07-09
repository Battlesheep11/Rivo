import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivo_app/features/discovery/presentation/providers/discovery_providers.dart';
import 'package:rivo_app/features/discovery/presentation/widgets/featured_product_card.dart';
import 'package:rivo_app/core/localization/generated/app_localizations.dart';
import 'package:rivo_app/features/discovery/presentation/widgets/trending_tag_grid.dart';
import 'package:rivo_app/features/discovery/presentation/widgets/curated_collection_grid.dart';
import 'package:go_router/go_router.dart';

class DiscoveryScreen extends ConsumerStatefulWidget {
  const DiscoveryScreen({super.key});

  @override
  ConsumerState<DiscoveryScreen> createState() => _DiscoveryScreenState();
}

class _DiscoveryScreenState extends ConsumerState<DiscoveryScreen> {
  String? selectedTagId;



  @override
  Widget build(BuildContext context) {
    final featuredAsync = ref.watch(featuredProductProvider);

    return Scaffold(
      appBar: AppBar(
  title: Text(AppLocalizations.of(context)!.discover),
  actions: [
    IconButton(
      icon: const Icon(Icons.search),
      tooltip: AppLocalizations.of(context)!.searchTooltip,
      onPressed: () {
        context.push('/search');
      },
    ),
  ],
),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            featuredAsync.when(
              data: (product) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: FeaturedProductCard(product: product),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => const SizedBox.shrink(),
            ),

            const SizedBox(height: 32),

            // 🔤 Trending Now – localized

            

           Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                AppLocalizations.of(context)!.trendingNow,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
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

            // 🔤 Curated For You – localized
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                AppLocalizations.of(context)!.curatedForYou,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),

            

            const SizedBox(height: 32),
            CuratedCollectionGrid(
              onTap: (collection) {
                debugPrint('Tapped collection: ${collection.name}');
              },
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

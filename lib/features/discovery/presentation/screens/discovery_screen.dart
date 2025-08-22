import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivo_app_beta/features/discovery/presentation/providers/discovery_providers.dart';
import 'package:rivo_app_beta/features/discovery/presentation/widgets/featured_product_card.dart';
import 'package:rivo_app_beta/core/localization/generated/app_localizations.dart';
import 'package:rivo_app_beta/features/discovery/presentation/widgets/trending_tag_grid.dart';
import 'package:rivo_app_beta/features/discovery/presentation/widgets/curated_collection_grid.dart';
import 'package:go_router/go_router.dart';
import 'package:rivo_app_beta/core/analytics/analytics_service.dart';

class DiscoveryScreen extends ConsumerStatefulWidget {
  const DiscoveryScreen({super.key});

  @override
  ConsumerState<DiscoveryScreen> createState() => _DiscoveryScreenState();
}

class _DiscoveryScreenState extends ConsumerState<DiscoveryScreen> {
  String? selectedTagId;

  @override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    AnalyticsService.logScreenView(screenName: 'discovery_screen');
  });
}


  @override
  Widget build(BuildContext context) {
    final featuredAsync = ref.watch(featuredProductProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.discover),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            featuredAsync.when(
              data: (product) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: FeaturedProductCard(
                  product: product,
                  onTap: () {
                    // Log event when featured product is tapped
                    AnalyticsService.logEvent('featured_product_clicked', parameters: {
                      'product_id': product.id,
                    });
                    context.push('/product/${product.id}?source=discover');
                  },
                ),
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
                  // Log event when tag is clicked
                  AnalyticsService.logEvent('trending_tag_clicked', parameters: {
                    'tag_id': tag.id,
                    'tag_name': tag.name,
                  });
                  context.push('/tag/${tag.id}?source=discover');
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
                // Log event when collection is tapped
                AnalyticsService.logEvent('curated_collection_clicked', parameters: {
                  'collection_id': collection.id,
                  'collection_name': collection.name,
                });
                context.push('/collection/${collection.id}?source=discover');
              },
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

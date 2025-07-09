import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rivo_app/core/localization/generated/app_localizations.dart';
import '../providers/search_query_provider.dart';
import '../providers/search_results_provider.dart';
import 'package:rivo_app/core/design_system/cards/simple_product_card.dart';

class ProductResultsTab extends ConsumerWidget {
  const ProductResultsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(searchQueryProvider);
    final result = ref.watch(searchResultsProvider(query));

    return result.when(
      data: (products) {
        if (products.isEmpty) {
          return Center(
            child: Text(AppLocalizations.of(context)!.searchNoResults),
          );
        }

        return ListView.separated(
          itemCount: products.length,
          padding: const EdgeInsetsDirectional.all(8),
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final product = products[index];
            return SimpleProductCard(
              product: product,
              onTap: () {
                // TODO: Navigate to product detail
              },
              onUserTap: () {
                // TODO: Navigate to user profile
              },
              onLikeTap: () {
                // TODO: Like/unlike the product
              },
              isLiked: false, // TODO: Replace with actual like logic
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text(error.toString())),
    );
  }
}

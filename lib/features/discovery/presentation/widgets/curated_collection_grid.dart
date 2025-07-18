import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivo_app_beta/features/discovery/domain/entities/curated_collection_entity.dart';
import 'package:rivo_app_beta/features/discovery/presentation/providers/discovery_providers.dart';
import 'package:rivo_app_beta/features/discovery/presentation/widgets/curated_collection_card.dart';

class CuratedCollectionGrid extends ConsumerWidget {
  final void Function(CuratedCollectionEntity collection)? onTap;

  const CuratedCollectionGrid({super.key, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collectionsAsync = ref.watch(curatedCollectionsProvider);

    return collectionsAsync.when(
      data: (collections) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: collections.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.8,
          ),
          itemBuilder: (context, index) {
            final collection = collections[index];
            return CuratedCollectionCard(
              collection: collection,
              onTap: () => onTap?.call(collection),
            );
          },
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => const Center(child: Text('Error loading collections')),
    );
  }
}

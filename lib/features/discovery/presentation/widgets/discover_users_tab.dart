import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivo_app/features/discovery/domain/usecases/get_popular_sellers_use_case.dart';
import 'package:rivo_app/features/discovery/presentation/widgets/popular_seller_card.dart';


class DiscoverUsersTab extends ConsumerWidget {
  const DiscoverUsersTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sellersAsync = ref.watch(getPopularSellersUseCaseProvider);

    return sellersAsync.when(
      data: (sellers) => ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: sellers.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          return PopularSellerCard(seller: sellers[index]);
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('⚠️ $e')),
    );
  }
}

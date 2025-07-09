import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivo_app/features/discovery/domain/entities/seller_entity.dart';
import 'package:rivo_app/features/discovery/presentation/providers/search_sellers_provider.dart';

final searchSellersUseCaseProvider =
    FutureProvider.family<List<SellerEntity>, String>((ref, query) async {
  final repository = ref.read(searchRepositoryProvider);
  return repository.searchSellers(query);
});

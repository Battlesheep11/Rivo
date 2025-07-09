import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rivo_app/features/discovery/domain/entities/search_product_entity.dart';
import 'package:rivo_app/core/di/di.dart';

final searchResultsProvider = FutureProvider.family<List<SearchProductEntity>, String>((ref, query) async {
  final useCase = ref.read(searchProductsUseCaseProvider);
  if (query.trim().isEmpty) return [];
  return useCase(query);
});

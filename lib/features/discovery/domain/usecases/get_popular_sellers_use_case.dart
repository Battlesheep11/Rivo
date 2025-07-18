import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rivo_app_beta/features/discovery/domain/entities/seller_entity.dart';
import 'package:rivo_app_beta/features/discovery/presentation/providers/discovery_providers.dart';

final getPopularSellersUseCaseProvider = FutureProvider<List<SellerEntity>>((ref) async {
  final repository = ref.read(discoveryRepositoryProvider);
  return repository.getPopularSellers();
});

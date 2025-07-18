import 'package:rivo_app_beta/features/discovery/domain/entities/discovery_product_entity.dart';
import 'package:rivo_app_beta/features/discovery/domain/repositories/discovery_repository.dart';

class GetFeaturedProductUseCase {
  final DiscoveryRepository repository;

  GetFeaturedProductUseCase(this.repository);

  Future<DiscoveryProductEntity> call() {
    return repository.getFeaturedProduct();
  }
}

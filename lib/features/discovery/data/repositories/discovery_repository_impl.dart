import 'package:rivo_app/features/discovery/domain/entities/discovery_tag_entity.dart';
import 'package:rivo_app/features/discovery/domain/repositories/discovery_repository.dart';
import 'package:rivo_app/features/discovery/data/datasources/discovery_remote_data_source.dart';
import 'package:rivo_app/features/discovery/domain/entities/discovery_product_entity.dart';
import 'package:rivo_app/features/discovery/domain/entities/curated_collection_entity.dart';
import 'package:rivo_app/features/discovery/domain/entities/seller_entity.dart';

class DiscoveryRepositoryImpl implements DiscoveryRepository {
  final DiscoveryRemoteDataSource remoteDataSource;

  DiscoveryRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<DiscoveryTagEntity>> getCuratedTags() {
    return remoteDataSource.getCuratedTags();
  }

  @override
  Future<DiscoveryProductEntity> getFeaturedProduct() {
    return remoteDataSource.getFeaturedProduct();
  }

@override
Future<List<DiscoveryTagEntity>> getTrendingTags({int limit = 4}) {
  return remoteDataSource.getTrendingTags(limit: limit);
}
@override
Future<List<CuratedCollectionEntity>> getCuratedCollections() {
  return remoteDataSource.getCuratedCollections();
}
@override
Future<List<SellerEntity>> getPopularSellers() {
  return remoteDataSource.getPopularSellers();
}


}

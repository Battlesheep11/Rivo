import 'package:rivo_app/features/discovery/domain/entities/discovery_tag_entity.dart';
import 'package:rivo_app/features/discovery/domain/entities/discovery_product_entity.dart';
import 'package:rivo_app/features/discovery/domain/entities/curated_collection_entity.dart';


abstract class DiscoveryRepository {
  Future<DiscoveryProductEntity> getFeaturedProduct();
  Future<List<DiscoveryTagEntity>> getCuratedTags();  
  Future<List<DiscoveryTagEntity>> getTrendingTags({int limit});
  Future<List<CuratedCollectionEntity>> getCuratedCollections();
}

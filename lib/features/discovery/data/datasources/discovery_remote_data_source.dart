import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rivo_app/features/discovery/domain/entities/discovery_tag_entity.dart';
import 'package:rivo_app/features/discovery/domain/entities/discovery_product_entity.dart';
import 'package:rivo_app/features/discovery/domain/entities/curated_collection_entity.dart';


class DiscoveryRemoteDataSource {
  final SupabaseClient _client;

  DiscoveryRemoteDataSource({required SupabaseClient client}) : _client = client;

 Future<DiscoveryProductEntity> getFeaturedProduct() async {
  final response = await _client
      .from('featured_product')
      .select('''
        product:id,
        products (
          id,
          title,
          description,
          product_media (
            media (
              media_url
            )
          )
        )
      ''')
      .maybeSingle();

  if (response == null) {
    throw Exception('No featured product set.');
  }

  final product = response['products'];
  final mediaList = product['product_media'] as List<dynamic>?;

  final imageUrl = mediaList != null && mediaList.isNotEmpty
      ? mediaList.first['media']['media_url'] as String
      : '';

  return DiscoveryProductEntity(
    id: product['id'] as String,
    title: product['title'] as String,
    description: product['description'] ?? '',
    imageUrl: imageUrl,
    ctaLabel: 'Explore',
  );
} 

  Future<List<DiscoveryTagEntity>> getCuratedTags() async {
  final response = await _client
      .from('curated_tag_images')
      .select('tag_id, tag_name, media_url');

  final data = response as List;

  return data
      .map((json) => DiscoveryTagEntity(
            id: json['tag_id'] as String,
            name: json['tag_name'] as String,
            imageUrl: json['media_url'] as String?,
          ))
      .toList();
}
Future<List<DiscoveryTagEntity>> getTrendingTags({int limit = 4}) async {
  final response = await _client
      .from('vw_trending_tags_with_image')
      .select()
      .limit(limit);

  return (response as List)
      .map((item) => DiscoveryTagEntity(
            id: item['tag_id'] as String,
            name: item['tag_name'] as String,
            imageUrl: item['image_url'] as String?,
          ))
      .toList();
}


Future<List<CuratedCollectionEntity>> getCuratedCollections() async {
  final response = await _client
      .from('vw_curated_collections_with_preview')
      .select();

  return (response as List).map((json) {
    return CuratedCollectionEntity(
      id: json['collection_id'] as String,
      name: json['collection_name'] as String,
      postCount: json['post_count'] as int,
      topPostId: json['top_post_id'] as String?,
      imageUrl: json['top_post_image_url'] as String,
      iconUrl: json['icon_url'] as String?, 
    );
  }).toList();
}




}

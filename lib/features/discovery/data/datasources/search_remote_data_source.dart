
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/search_product_entity.dart';
import '../../domain/entities/seller_entity.dart';
import '../../domain/entities/tag_search_entity.dart';

class SearchRemoteDataSource {
  final SupabaseClient client;

  SearchRemoteDataSource(this.client);

  Future<List<SearchProductEntity>> searchProducts(String query) async {
    final response = await client
  .from('products')
  .select('''
  id,
  title,
  price,
  brand,
  product_media:product_media (
    media:media_id (
      id,
      media_url
    ),
    sort_order
  ),
  seller:profiles!products_seller_id_fkey (
    id,
    username,
    avatar_url
  )
''')
  .ilike('title', '%$query%')
  .eq('is_deleted', false)
  .limit(50)
  .order('created_at', ascending: false);





final List data = (response as List?) ?? [];

    return data
  .whereType<Map<String, dynamic>>()
  .map(SearchProductEntity.fromJson)
  .toList();

  }

Future<List<SellerEntity>> searchSellers(String query) async {
  final response = await client
      .from('profiles')
      .select('id, username, avatar_url, is_seller')
      .ilike('username', '%$query%')
      .eq('is_seller', true);

  return (response as List)
      .map((e) => SellerEntity.fromMap(e))
      .toList();
}

Future<List<TagSearchEntity>> searchTags(String query) async {
  final response = await client
      .from('vw_trending_tags_with_image')
      .select()
      .ilike('tag_name', '%$query%');

  return (response as List)
      .map((e) => TagSearchEntity.fromJson(e))
      .toList();
}

}

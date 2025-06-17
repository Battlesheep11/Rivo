import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rivo_app/features/feed/domain/entities/feed_post_entity.dart';

class FeedRemoteDataSource {
  final SupabaseClient client;

  FeedRemoteDataSource({required this.client});

  Future<List<FeedPostEntity>> getFeedPosts() async {
  final List response = await client
    .from('feed_posts')
    .select('''
      id,
      caption,
      creator_id,
      creator:profiles (
        username,
        avatar_url
      ),
      feed_post_products (
        product_id,
        products (
          title,
          product_media (
            media_id,
            media (
              media_url
            )
          )
        )
      )
    ''')
    .order('created_at', ascending: false);





  return response.map((post) {
  final feedPostProducts = post['feed_post_products'] as List;
  final firstProduct = feedPostProducts.isNotEmpty ? feedPostProducts[0] : null;
  final product = firstProduct?['products'];

  final productMedia = product?['product_media'] as List?;
  final mediaUrls = productMedia?.map<String>((mediaEntry) {
    final media = mediaEntry['media'];
    return media?['media_url'] ?? '';
  }).where((url) => url.isNotEmpty).toList() ?? [];

  final creator = post['creator'];
  final username = creator?['username'] ?? '';
  final avatarUrl = creator?['avatar_url'] ?? '';

  return FeedPostEntity(
    postId: post['id'] as String,
    productId: firstProduct?['product_id'] ?? '',
    title: product?['title'] ?? '',
    caption: post['caption'] ?? '',
    mediaUrls: mediaUrls,
    username: username,
    avatarUrl: avatarUrl,
  );
}).toList();



}

}

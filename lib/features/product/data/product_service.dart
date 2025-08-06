import 'package:rivo_app_beta/features/product/domain/product.dart';
import 'package:rivo_app_beta/features/product/domain/product_repository.dart';
import 'package:rivo_app_beta/features/product/domain/seller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductService implements ProductRepository {
  ProductService(this._supabaseClient);

  final SupabaseClient _supabaseClient;

@override
Future<Product> getProduct(String id) async {
  try {
    String? productId;

    final productResponse = await _supabaseClient
        .from('products')
        .select()
        .eq('id', id)
        .maybeSingle();

    if (productResponse != null) {
      productId = productResponse['id'];
    } else {
      //  שלב 2 – אם לא מצאנו, נבדוק אם מדובר ב־postId
      final maybePost = await _supabaseClient
          .from('feed_post')
          .select('product_id')
          .eq('id', id)
          .maybeSingle();

      if (maybePost != null && maybePost['product_id'] != null) {
        productId = maybePost['product_id'];
        // נטען את המוצר שוב לפי productId שנגזר מהפוסט
        final secondTry = await _supabaseClient
            .from('products')
            .select()
            .eq('id', productId!)
            .maybeSingle();

        if (secondTry != null) {
          productId = secondTry['id'];
          return await _buildProductFromData(secondTry);
        }
      }

      // אם לא מצאנו כלום
      throw Exception('Product not found.');
    }

    return await _buildProductFromData(productResponse);
  } catch (e) {
    // ignore: avoid_print
    print('Error fetching product: $e');
    rethrow;
  }
}

Future<Product> _buildProductFromData(Map<String, dynamic> productResponse) async {
  final productId = productResponse['id'];

  final mediaResponse = await _supabaseClient
      .from('product_media')
      .select('media(media_url)')
      .eq('product_id', productId);

  final imageUrls = mediaResponse
      .map((e) => e['media']['media_url'] as String)
      .toList();

  final size = 'C: ${productResponse['chest']} W: ${productResponse['waist']} L: ${productResponse['length']}';

  return Product(
    id: productId,
    name: productResponse['title'],
    price: productResponse['price']?.toDouble() ?? 0.0,
    description: productResponse['description'],
    imageUrls: imageUrls,
    size: size,
    fabric: productResponse['fabric'] ?? 'N/A',
    condition: productResponse['condition'] ?? 'N/A',
    brand: productResponse['brand'] ?? 'N/A',
    sellerId: productResponse['seller_id'],
  );
}


  @override
  Future<Seller> getSeller(String sellerId) async {
    try {
      final response = await _supabaseClient
          .from('profiles')
          .select()
          .eq('id', sellerId)
          .single();

      return Seller(
        id: response['id'],
        name: response['username'],
        avatarUrl: response['avatar_url'],
        // These are placeholders as they are not in the profiles table
        rating: 4.8,
        reviewCount: 213,
      );
    } catch (e) {
      // ignore: avoid_print
      print('Error fetching seller: $e');
      rethrow;
    }
  }

  @override
  Future<List<Product>> getRecommendedProducts(String postId) async {
    try {
      // 1. Get the product_id from the feed_post table.
      final feedPostResponse = await _supabaseClient
          .from('feed_post')
          .select('product_id')
          .eq('id', postId)
          .maybeSingle();

      if (feedPostResponse == null || feedPostResponse['product_id'] == null) {
        return [];
      }
      final currentProductId = feedPostResponse['product_id'];

      // 2. Get the seller_id from the products table using the product_id.
      final productResponse = await _supabaseClient
          .from('products')
          .select('seller_id')
          .eq('id', currentProductId)
          .single();

      final sellerId = productResponse['seller_id'];

      // 3. Get all posts from the same seller, excluding the current product's post.
      final response = await _supabaseClient
          .from('feed_post')
          .select('id, products!inner(id, title, price, seller_id)')
          .eq('products.seller_id', sellerId)
          .neq('product_id', currentProductId);

      final products = response.map((item) {
        final productData = item['products'];
        final postId = item['id'] as String?;

        if (productData == null || postId == null) {
          return null;
        }

        return Product(
          id: productData['id'],
          name: productData['title'],
          price: productData['price']?.toDouble() ?? 0.0,
          postId: postId,
          sellerId: productData['seller_id'],
          // Default values for fields not needed in the preview
          description: '',
          imageUrls: [],
          size: '',
          fabric: '',
          condition: '',
          brand: '',
        );
      }).whereType<Product>().toList();

      // For each product, fetch its media
      final productsWithMedia = <Product>[];
      for (final product in products) {
        final mediaResponse = await _supabaseClient
            .from('product_media')
            .select('media(media_url)')
            .eq('product_id', product.id);

        final imageUrls = mediaResponse
            .map((e) => e['media']['media_url'] as String)
            .toList();

        productsWithMedia.add(product.copyWith(imageUrls: imageUrls));
      }

      return productsWithMedia;
    } catch (e) {
      // ignore: avoid_print
      print('Error fetching recommended products: $e');
      return []; // Return empty list on error
    }
  }
}

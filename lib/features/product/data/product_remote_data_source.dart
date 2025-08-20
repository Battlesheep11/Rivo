import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rivo_app_beta/core/error_handling/app_exception.dart';

class ProductRemoteDataSource {
  final SupabaseClient client;
  ProductRemoteDataSource({required this.client});

  /// Returns a row from v_product_details (or null if not found).
  Future<Map<String, dynamic>?> getProductDetails(String productId) async {
    try {
      final rows = await client
          .from('v_product_details')
          .select()
          .eq('id', productId)
          .limit(1);

      if (rows.isNotEmpty) {
        return rows.first;
      }
      return null;
    } on PostgrestException catch (e) {
      throw AppException.unexpected(
        'Supabase error: ${e.message}',
        code: 'get_product_details_error',
      );
    } catch (_) {
      throw AppException.unexpected(
        'Unexpected error occurred',
        code: 'get_product_details_error',
      );
    }
  }

  // -----------------------
  // Lookups (kept together)
  // -----------------------

  /// Active item conditions (code list) ordered by display_order.
  /// UI should localize by code (e.g., never_worn/as_new/good/fair).
  Future<List<Map<String, dynamic>>> getItemConditions() async {
    try {
      final rows = await client
          .from('item_conditions')
          .select('code, display_order, is_active')
          .eq('is_active', true)
          .order('display_order');
      return (rows as List).cast<Map<String, dynamic>>();
    } on PostgrestException catch (e) {
      throw AppException.unexpected(
        'Supabase error: ${e.message}',
        code: 'get_item_conditions_error',
      );
    } catch (_) {
      throw AppException.unexpected(
        'Unexpected error occurred',
        code: 'get_item_conditions_error',
      );
    }
  }

  /// Active defect types (code list) ordered by display_order.
  /// Use for the multi-select checklist when condition is 'good' or 'fair'.
  Future<List<Map<String, dynamic>>> getDefectTypes() async {
    try {
      final rows = await client
          .from('defect_types')
          .select('code, display_order, is_active')
          .eq('is_active', true)
          .order('display_order');
      return (rows as List).cast<Map<String, dynamic>>();
    } on PostgrestException catch (e) {
      throw AppException.unexpected(
        'Supabase error: ${e.message}',
        code: 'get_defect_types_error',
      );
    } catch (_) {
      throw AppException.unexpected(
        'Unexpected error occurred',
        code: 'get_defect_types_error',
      );
    }
  }

  /// Materials (code + display_name) ordered by display_order.
  Future<List<Map<String, dynamic>>> getMaterials() async {
    try {
      final rows = await client
          .from('materials')
          .select('code, display_name, display_order')
          .order('display_order');
      return (rows as List).cast<Map<String, dynamic>>();
    } on PostgrestException catch (e) {
      throw AppException.unexpected(
        'Supabase error: ${e.message}',
        code: 'get_materials_error',
      );
    } catch (_) {
      throw AppException.unexpected(
        'Unexpected error occurred',
        code: 'get_materials_error',
      );
    }
  }

  /// Colors (code + hex) ordered by display_order.
  Future<List<Map<String, dynamic>>> getColors() async {
    try {
      final rows = await client
          .from('colors')
          .select('code, hex, display_order')
          .order('display_order');
      return (rows as List).cast<Map<String, dynamic>>();
    } on PostgrestException catch (e) {
      throw AppException.unexpected(
        'Supabase error: ${e.message}',
        code: 'get_colors_error',
      );
    } catch (_) {
      throw AppException.unexpected(
        'Unexpected error occurred',
        code: 'get_colors_error',
      );
    }
  }

Future<Map<String, dynamic>?> getProductRowByIdOrPostId(String id) async {
  try {
    // Try as product id
    final product = await client
        .from('products')
        .select()
        .eq('id', id)
        .maybeSingle();

    if (product != null) return product;

    // Fallback: treat id as feed_post.id → resolve product_id
    final post = await client
        .from('feed_post')
        .select('product_id')
        .eq('id', id)
        .maybeSingle();

    final productId = (post?['product_id']) as String?;
    if (productId == null) return null;

    final secondTry = await client
        .from('products')
        .select()
        .eq('id', productId)
        .maybeSingle();

    return secondTry;
  } on PostgrestException catch (e) {
    throw AppException.unexpected(
      'Supabase error: ${e.message}',
      code: 'get_product_row_error',
    );
  } catch (_) {
    throw AppException.unexpected(
      'Unexpected error occurred',
      code: 'get_product_row_error',
    );
  }
}

/// Returns the list of media URLs for a product (ordered by product_media.sort_order).
Future<List<String>> getProductImageUrls(String productId) async {
  try {
    final rows = await client
        .from('product_media')
        .select('sort_order, media(media_url)')
        .eq('product_id', productId)
        .order('sort_order', ascending: true);

    final list = (rows as List).cast<Map<String, dynamic>>();
    return list
        .map((m) => (m['media'] as Map<String, dynamic>?)?['media_url'] as String?)
        .whereType<String>()
        .toList();
  } on PostgrestException catch (e) {
    throw AppException.unexpected(
      'Supabase error: ${e.message}',
      code: 'get_product_media_error',
    );
  } catch (_) {
    throw AppException.unexpected(
      'Unexpected error occurred',
      code: 'get_product_media_error',
    );
  }
}

/// Returns a seller profile row (from profiles) by seller id.
Future<Map<String, dynamic>> getSellerProfile(String sellerId) async {
  try {
    final row = await client
        .from('profiles')
        .select()
        .eq('id', sellerId)
        .single();
    return row;
  } on PostgrestException catch (e) {
    throw AppException.unexpected(
      'Supabase error: ${e.message}',
      code: 'get_seller_profile_error',
    );
  } catch (_) {
    throw AppException.unexpected(
      'Unexpected error occurred',
      code: 'get_seller_profile_error',
    );
  }
}

/// Returns more items from the same seller, excluding a given product.
/// Each entry includes: product (raw), post_id (if available), and image_urls.
Future<List<Map<String, dynamic>>> getSellerOtherProducts({
  required String sellerId,
  required String excludeProductId,
}) async {
  try {
    // Grab posts joined to products for that seller, excluding the current product.
    final rows = await client
        .from('feed_post')
        .select('id, product_id, products!inner(id, title, price, seller_id)')
        .eq('products.seller_id', sellerId)
        .neq('product_id', excludeProductId);

    final posts = (rows as List).cast<Map<String, dynamic>>();

    // For each product, attach its image urls
    final result = <Map<String, dynamic>>[];
    for (final row in posts) {
      final product = row['products'] as Map<String, dynamic>?;
      final postId = row['id'] as String?;
      final productId = product?['id'] as String?;
      if (product == null || postId == null || productId == null) continue;

      final imageUrls = await getProductImageUrls(productId);

      result.add({
        'post_id': postId,
        'product': product,
        'image_urls': imageUrls,
      });
    }
    return result;
  } on PostgrestException catch (e) {
    throw AppException.unexpected(
      'Supabase error: ${e.message}',
      code: 'get_seller_other_products_error',
    );
  } catch (_) {
    throw AppException.unexpected(
      'Unexpected error occurred',
      code: 'get_seller_other_products_error',
    );
  }
}

/// Convenience: recommended by postId (same seller as the post's product).
Future<List<Map<String, dynamic>>> getRecommendedProductsByPostId(String postId) async {
  try {
    // Resolve product id from post
    final post = await client
        .from('feed_post')
        .select('product_id')
        .eq('id', postId)
        .maybeSingle();
    final productId = (post?['product_id']) as String?;
    if (productId == null) return const [];

    // Resolve seller id from product
    final product = await client
        .from('products')
        .select('seller_id')
        .eq('id', productId)
        .single();
    final sellerId = product['seller_id'] as String;

    // Return other products by same seller
    return getSellerOtherProducts(
      sellerId: sellerId,
      excludeProductId: productId,
    );
  } on PostgrestException catch (e) {
    throw AppException.unexpected(
      'Supabase error: ${e.message}',
      code: 'recommended_products_error',
    );
  } catch (_) {
    throw AppException.unexpected(
      'Unexpected error occurred',
      code: 'recommended_products_error',
    );
  }
}





}

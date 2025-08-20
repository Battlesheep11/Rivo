import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rivo_app_beta/features/product/data/product_remote_data_source.dart';
import 'package:rivo_app_beta/features/product/domain/product.dart';
import 'package:rivo_app_beta/features/product/domain/seller.dart';

final productRemoteDataSourceProvider = Provider<ProductRemoteDataSource>((ref) {
  return ProductRemoteDataSource(client: Supabase.instance.client);
});

/// Load a product either by product id or by post id (the provider accepts both).
final productProvider =
    FutureProvider.family<Product, String>((ref, idOrPostId) async {
  final ds = ref.read(productRemoteDataSourceProvider);

  // Prefer the view (if exists), otherwise raw table rows.
  final viewRow = await ds.getProductDetails(idOrPostId);

  Map<String, dynamic> row;
  List<String> imageUrls;

  if (viewRow != null) {
    row = viewRow;
    final viewImages = (viewRow['image_urls'] as List?)?.whereType<String>().toList();
    imageUrls = viewImages ?? await ds.getProductImageUrls(viewRow['id'] as String);
  } else {
    row = (await ds.getProductRowByIdOrPostId(idOrPostId)) ??
        (throw Exception('Product not found'));
    imageUrls = await ds.getProductImageUrls(row['id'] as String);
  }

  // Try to build a user-friendly "fabric" from possible fields.
  final dynamic mats = row['materials'] ?? row['material_names'] ?? row['material'];
  final List<String> materialNames = switch (mats) {
    List l when l.isNotEmpty && l.first is String => l.cast<String>(),
    List l when l.isNotEmpty && l.first is Map =>
      l.map((e) => (e as Map)['display_name'] as String? ?? '')
       .where((s) => s.isNotEmpty).toList(),
    String s => s.split(',').map((e) => e.trim()).where((s) => s.isNotEmpty).toList(),
    _ => <String>[],
  };
  final fabric = materialNames.isEmpty ? 'N/A' : materialNames.join(', ');

  return Product(
    id: row['id'] as String,
    name: (row['title'] as String?) ?? '',
    description: (row['description'] as String?) ?? '',
    price: ((row['price'] as num?) ?? 0).toDouble(),
    size: (row['size'] as String?) ?? '',
    brand: (row['brand'] as String?) ?? '',
    condition: (row['condition_code'] as String?) ?? '',
    fabric: fabric,
    sellerId: (row['seller_id'] as String?) ?? '',
    imageUrls: imageUrls,
  );
});

/// Return a **Seller** domain object for SellerInfo.
final sellerProvider =
    FutureProvider.family<Seller, String>((ref, sellerId) async {
  final ds = ref.read(productRemoteDataSourceProvider);
  final row = await ds.getSellerProfile(sellerId);

  final first = (row['first_name'] as String?)?.trim() ?? '';
  final last  = (row['last_name'] as String?)?.trim() ?? '';
  final fullName = ([first, last]..removeWhere((s) => s.isEmpty)).join(' ');
  final displayName = fullName.isNotEmpty
      ? fullName
      : ((row['username'] as String?) ?? 'Seller');

  return Seller(
    id: (row['id'] as String?) ?? sellerId,
    name: displayName,
    avatarUrl: (row['avatar_url'] as String?) ?? '',
    // If you don't store rating/review_count yet, default gracefully:
    rating: ((row['rating'] as num?) ?? 4.8).toDouble(),
    reviewCount: ((row['review_count'] as num?) ?? 0).toInt(),
  );
});

/// Recommended items (returned as `List<Product>` so your widget compiles).

final recommendedProductsProvider =
    FutureProvider.family<List<Product>, String>((ref, postId) async {
  final ds = ref.read(productRemoteDataSourceProvider);
  final rows = await ds.getRecommendedProductsByPostId(postId);

  final result = <Product>[];
  for (final r in rows) {
    final prod = r['product'] as Map<String, dynamic>;
    final pid = prod['id'] as String;
    final imgs = r['image_urls']?.cast<String>() ?? const <String>[];

    result.add(Product(
      id: pid,
      name: (prod['title'] as String?) ?? '',
      description: '',
      price: ((prod['price'] as num?) ?? 0).toDouble(),
      size: (prod['size'] as String?) ?? '',
      brand: (prod['brand'] as String?) ?? '',
      condition: (prod['condition_code'] as String?) ?? '',
      fabric: 'N/A',
      sellerId: (prod['seller_id'] as String?) ?? '',
      imageUrls: imgs,
    ));
  }
  return result;
});

import 'package:rivo_app_beta/features/product/domain/product.dart';
import 'package:rivo_app_beta/features/product/domain/product_repository.dart';
import 'package:rivo_app_beta/features/product/domain/seller.dart';
import 'package:rivo_app_beta/features/product/data/product_remote_data_source.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remote;
  ProductRepositoryImpl({required this.remote});

  @override
  Future<Product> getProduct(String id) async {
    final row = await remote.getProductRowByIdOrPostId(id);
    if (row == null) {
      throw Exception('Product not found'); // keep behavior consistent; you can swap to AppException later
    }
    final productId = row['id'] as String;

    final imageUrls = await remote.getProductImageUrls(productId);

    final chest = row['chest'];
    final waist = row['waist'];
    final length = row['length'];
    final size = 'C: ${chest ?? '-'} W: ${waist ?? '-'} L: ${length ?? '-'}';

    final materialText = (row['material'] ?? row['fabric'])?.toString() ?? 'N/A';
    final conditionText = (row['condition'] ?? row['condition_code'])?.toString() ?? 'N/A';

    return Product(
      id: productId,
      name: (row['title'] ?? '').toString(),
      price: (row['price'] is num) ? (row['price'] as num).toDouble() : 0.0,
      description: (row['description'] ?? '').toString(),
      imageUrls: imageUrls,
      size: size,
      fabric: materialText,
      condition: conditionText,
      brand: (row['brand'] ?? 'N/A').toString(),
      sellerId: (row['seller_id'] ?? '').toString(),
    );
  }

  @override
  Future<Seller> getSeller(String sellerId) async {
    final row = await remote.getSellerProfile(sellerId);
    return Seller(
      id: row['id'] as String,
      name: (row['username'] ?? '').toString(),
      avatarUrl: (row['avatar_url'] ?? '').toString(),
      rating: 4.8,       // placeholders (not in schema)
      reviewCount: 213,  // placeholders
    );
  }

  @override
  Future<List<Product>> getRecommendedProducts(String id) async {
    // id can be postId; we map the remote result (raw maps) into Product
    // First resolve the base product row to know what to exclude + seller
    final base = await remote.getProductRowByIdOrPostId(id);
    if (base == null) return <Product>[];

    final productId = base['id'] as String;
    final sellerId = base['seller_id'] as String;
    final rows = await remote.getSellerOtherProducts(
      sellerId: sellerId,
      excludeProductId: productId,
    );

    final products = <Product>[];
    for (final r in rows) {
      final product = r['product'] as Map<String, dynamic>;
      final imageUrls = (r['image_urls'] as List).cast<String>();

      products.add(Product(
        id: (product['id'] ?? '').toString(),
        name: (product['title'] ?? '').toString(),
        price: (product['price'] is num) ? (product['price'] as num).toDouble() : 0.0,
        description: '',
        imageUrls: imageUrls,
        size: '',
        fabric: '',
        condition: '',
        brand: (product['brand'] ?? '').toString(),
        sellerId: (product['seller_id'] ?? '').toString(),
        postId: r['post_id']?.toString(),
      ));
    }
    return products;
  }

  // ---- Lookups passthrough (Maps; UI will localize codes) ----
  @override
  Future<Map<String, dynamic>?> getProductDetails(String productId) {
    return remote.getProductDetails(productId);
  }

  @override
  Future<List<Map<String, dynamic>>> getItemConditions() {
    return remote.getItemConditions();
  }

  @override
  Future<List<Map<String, dynamic>>> getDefectTypes() {
    return remote.getDefectTypes();
  }

  @override
  Future<List<Map<String, dynamic>>> getMaterials() {
    return remote.getMaterials();
  }

  @override
  Future<List<Map<String, dynamic>>> getColors() {
    return remote.getColors();
  }
}

import 'package:rivo_app_beta/features/product/domain/product.dart';
import 'package:rivo_app_beta/features/product/domain/seller.dart';

abstract class ProductRepository {
  Future<Product> getProduct(String productId);
  Future<Seller> getSeller(String sellerId);
  Future<List<Product>> getRecommendedProducts(String productId);
  Future<Map<String, dynamic>?> getProductDetails(String productId);
  Future<List<Map<String, dynamic>>> getItemConditions();
  Future<List<Map<String, dynamic>>> getDefectTypes();
  Future<List<Map<String, dynamic>>> getMaterials();
  Future<List<Map<String, dynamic>>> getColors();
}

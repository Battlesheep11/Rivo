import 'package:rivo_app_beta/features/product/domain/product.dart';
import 'package:rivo_app_beta/features/product/domain/seller.dart';

abstract class ProductRepository {
  Future<Product> getProduct(String productId);
  Future<Seller> getSeller(String sellerId);
  Future<List<Product>> getRecommendedProducts(String productId);
}

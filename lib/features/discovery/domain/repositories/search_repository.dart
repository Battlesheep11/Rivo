
import '../entities/search_product_entity.dart';
import '../entities/seller_entity.dart';

abstract class SearchRepository {
  Future<List<SearchProductEntity>> searchProducts(String query);
  Future<List<SellerEntity>> searchSellers(String query);
}

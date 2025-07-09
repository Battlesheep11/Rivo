
import '../entities/search_product_entity.dart';
import '../repositories/search_repository.dart';

class SearchProductsUseCase {
  final SearchRepository _repository;

  SearchProductsUseCase(this._repository);

  Future<List<SearchProductEntity>> call(String query) {
    return _repository.searchProducts(query);
  }
}

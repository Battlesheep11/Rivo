
import '../../domain/entities/search_product_entity.dart';
import '../../domain/entities/seller_entity.dart';
import '../../domain/repositories/search_repository.dart';
import '../datasources/search_remote_data_source.dart';

class SearchRepositoryImpl implements SearchRepository {
  final SearchRemoteDataSource remoteDataSource;

  SearchRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<SearchProductEntity>> searchProducts(String query) {
    return remoteDataSource.searchProducts(query);
  }

  @override
Future<List<SellerEntity>> searchSellers(String query) {
  return remoteDataSource.searchSellers(query);
}

}

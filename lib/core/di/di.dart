import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rivo_app/features/discovery/data/datasources/search_remote_data_source.dart';
import 'package:rivo_app/features/discovery/data/repositories/search_repository_impl.dart';
import 'package:rivo_app/features/discovery/domain/usecases/search_products_use_case.dart';
import 'package:rivo_app/features/discovery/domain/repositories/search_repository.dart';
import 'package:rivo_app/core/supabase/supabase_client_provider.dart'; 

final searchRemoteDataSourceProvider = Provider<SearchRemoteDataSource>((ref) {
  final client = ref.read(supabaseClientProvider); // מחזיר SupabaseClient
  return SearchRemoteDataSource(client);
});

final searchRepositoryProvider = Provider<SearchRepository>((ref) {
  final remote = ref.read(searchRemoteDataSourceProvider);
  return SearchRepositoryImpl(remote);
});

final searchProductsUseCaseProvider = Provider<SearchProductsUseCase>((ref) {
  final repo = ref.read(searchRepositoryProvider);
  return SearchProductsUseCase(repo);
});

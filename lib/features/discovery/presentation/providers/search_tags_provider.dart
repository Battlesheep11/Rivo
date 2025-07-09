import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/search_remote_data_source.dart';
import '../../domain/entities/tag_search_entity.dart';
import 'package:rivo_app/core/supabase/supabase_client_provider.dart';

final searchTagsProvider = FutureProvider.family
    .autoDispose<List<TagSearchEntity>, String>((ref, query) async {
  final client = ref.watch(supabaseClientProvider);
  final ds = SearchRemoteDataSource(client);
  return ds.searchTags(query);
});

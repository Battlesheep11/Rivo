import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../entities/tag_search_entity.dart';
import '../../presentation/providers/search_tags_provider.dart';

final searchTagsUseCaseProvider = Provider.family
    .autoDispose<Future<List<TagSearchEntity>>, String>((ref, query) {
  return ref.watch(searchTagsProvider(query).future);
});

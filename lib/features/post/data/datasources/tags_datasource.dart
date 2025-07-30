import 'package:rivo_app_beta/core/error_handling/app_exception.dart';
import 'package:rivo_app_beta/features/post/domain/entities/tag_entity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class TagsDataSource {
  Future<List<TagEntity>> getTags();
}

class TagsDataSourceImpl implements TagsDataSource {
  final SupabaseClient _supabaseClient;

  TagsDataSourceImpl(this._supabaseClient);

  @override
  Future<List<TagEntity>> getTags() async {
    try {
      final response = await _supabaseClient.from('tags').select();

      final tags = (response as List)
          .map((tagData) => TagEntity.fromJson(tagData))
          .toList();

      return tags;
    } catch (e) {
      throw AppException.unexpected(e.toString());
    }
  }
}

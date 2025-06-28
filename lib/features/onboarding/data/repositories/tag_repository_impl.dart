import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rivo_app/features/onboarding/domain/repositories/tag_repository.dart';

class TagRepositoryImpl implements TagRepository {
  final SupabaseClient _client;

  TagRepositoryImpl(this._client);

  @override
  Future<void> submitUserTags(List<String> tagNames) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('No user logged in');

    final response = await _client
        .from('tags')
        .select('id, name')
        .inFilter('name', tagNames)
        .eq('is_visible', true);

    final tagIds = response.map((t) => t['id'] as String).toList();

    final rows = tagIds.map((id) => {
          'user_id': userId,
          'tag_id': id,
        }).toList();

    await _client.from('user_tags').insert(rows);
  }

  @override
  Future<List<String>> getAllVisibleTags() async {
    final response = await _client
        .from('tags')
        .select('name')
        .eq('is_visible', true)
        .order('name', ascending: true);

    return response.map<String>((row) => row['name'] as String).toList();
  }
}

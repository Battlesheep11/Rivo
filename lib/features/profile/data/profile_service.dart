import 'dart:developer' as developer;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rxdart/rxdart.dart';

class ProfileService {
  static final Map<String, Map<String, dynamic>> _profileCache = {};
  static final Map<String, DateTime> _cacheTimestamps = {};
  static const Duration _cacheDuration = Duration(minutes: 5);

  final Map<String, BehaviorSubject<Map<String, dynamic>>> _profileStreams = {};
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> updateBio(String userId, String bio) async {
    await _supabase.from('profiles').update({'bio': bio}).eq('id', userId);

    if (_profileCache.containsKey(userId)) {
      _profileCache[userId]!['profile'] = {
        ..._profileCache[userId]!['profile'],
        'bio': bio,
      };
      _cacheTimestamps[userId] = DateTime.now();

      if (_profileStreams.containsKey(userId)) {
        _profileStreams[userId]!.add(_profileCache[userId]!);
      }
    }
  }

  Future<List<String>> getTagsForUser(String userId) async {
    final response = await _supabase
        .from('user_tags')
        .select('tags(name)')
        .eq('user_id', userId);

    final tagsList = (response as List<dynamic>)
        .map((e) => (e['tags'] as Map)['name'] as String)
        .toList();
    return tagsList;
  }

  Future<void> updateTagsForUser(String userId, List<String> tagNames) async {
    final tagsResponse = await _supabase
        .from('tags')
        .select('id, name')
        .filter('name', 'in', '(${tagNames.join(",")})');

    final tagIds = tagsResponse.map((tag) => tag['id'] as String).toList();

    await _supabase.rpc(
      'update_user_tags',
      params: {'p_user_id': userId, 'p_tag_ids': tagIds},
    );

    if (_profileCache.containsKey(userId)) {
      final updatedTags = await _supabase
          .from('user_tags')
          .select('tags(name)')
          .eq('user_id', userId);

      _profileCache[userId]!['tags'] =
          updatedTags.map((e) => e['tags']).toList();
      _cacheTimestamps[userId] = DateTime.now();

      if (_profileStreams.containsKey(userId)) {
        _profileStreams[userId]!.add(_profileCache[userId]!);
      }
    }
  }

  Future<Map<String, dynamic>> getProfileData(String userId) async {
    final now = DateTime.now();
    if (_profileCache.containsKey(userId) &&
        _cacheTimestamps.containsKey(userId) &&
        now.difference(_cacheTimestamps[userId]!) < _cacheDuration) {
      return _profileCache[userId]!;
    }

    try {
      final results = await Future.wait<dynamic>([
        _supabase
            .from('profiles')
            .select()
            .eq('id', userId)
            .single(),
        _supabase
            .from('user_following')
            .select('*', const FetchOptions(count: CountOption.exact))
            .eq('followed_seller_id', userId),
        _supabase
            .from('user_following')
            .select('*', const FetchOptions(count: CountOption.exact))
            .eq('follower_id', userId),
        _supabase
            .from('user_tags')
            .select('tags(name)')
            .eq('user_id', userId),
      ]);

      final profileData = results[0] as Map<String, dynamic>;
      final followerCount = (results[1] as PostgrestResponse).count;
      final followingCount = (results[2] as PostgrestResponse).count;
      final tagsData = results[3] as List<dynamic>;

      final processedTags = tagsData.map((e) => (e as Map)['tags']).toList();

      final profileMap = {
        'profile': profileData,
        'followers_count': followerCount,
        'following_count': followingCount,
        'tags': processedTags,
      };

      _profileCache[userId] = profileMap;
      _cacheTimestamps[userId] = now;

      if (_profileStreams.containsKey(userId)) {
        _profileStreams[userId]!.add(profileMap);
      }

      return profileMap;
    } catch (e) {
      if (_profileCache.containsKey(userId)) {
        developer.log('Using cached profile data due to error: $e',
            name: 'ProfileService');
        return _profileCache[userId]!;
      }
      rethrow;
    }
  }

  Stream<Map<String, dynamic>>? watchProfileData(String userId) {
    if (!_profileStreams.containsKey(userId)) {
      _profileStreams[userId] = BehaviorSubject<Map<String, dynamic>>();
      getProfileData(userId).then((data) {
        if (_profileStreams[userId]?.isClosed == false) {
          _profileStreams[userId]!.add(data);
        }
      }).catchError((e) {
        if (_profileStreams[userId]?.isClosed == false) {
          _profileStreams[userId]!.addError(e);
        }
      });
    }
    return _profileStreams[userId]?.stream;
  }

  void clearCache(String userId) {
    _profileCache.remove(userId);
    _cacheTimestamps.remove(userId);
  }

  void clearAllCache() {
    _profileCache.clear();
    _cacheTimestamps.clear();
  }

  Future<void> deleteUserViaEdgeFunction() async {
  final client = Supabase.instance.client;

  final response = await client.functions.invoke('delete_user_self');

  if ((response.status ?? 500) >= 400) {
  final error = response.data?['error'] ?? 'Unknown error';
  throw Exception('Failed to delete user: $error');
}

}

}

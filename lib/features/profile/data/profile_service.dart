import 'dart:developer' as developer;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rxdart/rxdart.dart';

class ProfileService {
  // In‑memory cache (simple & time‑boxed)
  static final Map<String, Map<String, dynamic>> _profileCache = {};
  static final Map<String, DateTime> _cacheTimestamps = {};
  static const Duration _cacheDuration = Duration(minutes: 5);

  final Map<String, BehaviorSubject<Map<String, dynamic>>> _profileStreams = {};
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> updateBio(String userId, String bio) async {
    await _supabase.from('profiles').update({'bio': bio}).eq('id', userId);

    // keep cache & stream in sync if present
    if (_profileCache.containsKey(userId)) {
      final current = _profileCache[userId]!;
      final updatedProfile = {
        ...(current['profile'] as Map<String, dynamic>? ?? {}),
        'bio': bio,
      };

      _profileCache[userId] = {
        ...current,
        'profile': updatedProfile,
      };
      _cacheTimestamps[userId] = DateTime.now();

      _profileStreams[userId]?.add(_profileCache[userId]!);
    }
  }

  Future<List<String>> getTagsForUser(String userId) async {
    final response = await _supabase
        .from('user_tags')
        .select('tags(name)')
        .eq('user_id', userId);

    final tagsList = (response as List)
        .map((e) => ((e['tags'] as Map?)?['name'] as String?) ?? '')
        .where((name) => name.isNotEmpty)
        .toList();

    return tagsList;
  }

  Future<void> updateTagsForUser(String userId, List<String> tagNames) async {
    if (tagNames.isEmpty) {
      await _supabase.rpc('update_user_tags', params: {
        'p_user_id': userId,
        'p_tag_ids': <String>[],
      });
      await _refreshCachedTags(userId);
      return;
    }

    // Safer "IN" without using in_ (works on older supabase-dart too)
    // Build a quoted list like: ('A','B','C')
    final quoted =
        tagNames.map((n) => "'${n.replaceAll("'", "''")}'").join(',');

    final tagsResponse = await _supabase
        .from('tags')
        .select('id,name')
        .filter('name', 'in', '($quoted)');

    final tagIds = (tagsResponse as List)
        .map((row) => row['id'] as String?)
        .whereType<String>()
        .toList();

    await _supabase.rpc(
      'update_user_tags',
      params: {'p_user_id': userId, 'p_tag_ids': tagIds},
    );

    await _refreshCachedTags(userId);
  }

  Future<void> _refreshCachedTags(String userId) async {
    if (_profileCache.containsKey(userId)) {
      final updated = await _supabase
          .from('user_tags')
          .select('tags(name)')
          .eq('user_id', userId);

      final names = (updated as List)
          .map((e) => (e['tags'] as Map?)?['name'])
          .whereType<String>()
          .toList();

      final current = _profileCache[userId]!;
      _profileCache[userId] = {...current, 'tags': names};
      _cacheTimestamps[userId] = DateTime.now();
      _profileStreams[userId]?.add(_profileCache[userId]!);
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
      .select('id, username, first_name, last_name, bio, avatar_url, is_seller, created_at, language, last_seen_at')
      .eq('id', userId)
      .maybeSingle(),
  _supabase
      .from('user_following')
      .select('follower_id')
      .eq('followed_seller_id', userId),
  _supabase
      .from('user_following')
      .select('followed_seller_id')
      .eq('follower_id', userId),
  _supabase
      .from('user_tags')
      .select('tags(name)')
      .eq('user_id', userId),
]);


      final profileRow = results[0] as Map<String, dynamic>?; // may be null
      final followersRows = results[1] as List;
      final followingRows = results[2] as List;
      final tagsRows = results[3] as List;

      final followerCount = followersRows.length;
      final followingCount = followingRows.length;

      // Normalize to List<String>
      final tagNames = tagsRows
          .map((e) => (e as Map)['tags'])
          .whereType<Map>()
          .map((m) => m['name'])
          .whereType<String>()
          .toList();

      final profileMap = <String, dynamic>{
        'profile': profileRow, // null if not found
        'followers_count': followerCount,
        'following_count': followingCount,
        'tags': tagNames, // List<String>
      };

      _profileCache[userId] = profileMap;
      _cacheTimestamps[userId] = now;
      _profileStreams[userId]?.add(profileMap);
      return profileMap;
    } catch (e) {
      if (_profileCache.containsKey(userId)) {
        developer.log(
          'Using cached profile data due to error: $e',
          name: 'ProfileService',
        );
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
          _profileStreams[userId]!.add(data); // normalized shape
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

    if (response.status >= 400) {
      final data = response.data;
      final error =
          (data is Map && data['error'] is String) ? data['error'] as String : 'Unknown error';
      throw Exception('Failed to delete user: $error');
    }
  }
}

import 'dart:developer' as developer;

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rxdart/rxdart.dart';

class ProfileService {
  // Cache for storing profile data with TTL (Time To Live)
  static final Map<String, Map<String, dynamic>> _profileCache = {};
  static final Map<String, DateTime> _cacheTimestamps = {};
  static const Duration _cacheDuration = Duration(minutes: 5); // Cache for 5 minutes
  
  // Stream controllers for real-time updates
  final Map<String, BehaviorSubject<Map<String, dynamic>>> _profileStreams = {};
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Update the bio for a user in the profiles table
  Future<void> updateBio(String userId, String bio) async {
    await _supabase.from('profiles').update({'bio': bio}).eq('id', userId);
    
    // Invalidate cache for this user
    if (_profileCache.containsKey(userId)) {
      _profileCache[userId]!['profile'] = {
        ..._profileCache[userId]!['profile'],
        'bio': bio,
      };
      _cacheTimestamps[userId] = DateTime.now();
      
      // Notify listeners
      if (_profileStreams.containsKey(userId)) {
        _profileStreams[userId]!.add(_profileCache[userId]!);
      }
    }
  }

  Future<List<String>> getTagsForUser(String userId) async {
    final response = await _supabase.from('user_tags').select('tags(name)').eq('user_id', userId);
    final tagsList = (response as List<dynamic>)
        .map((e) => (e['tags'] as Map)['name'] as String)
        .toList();
    return tagsList;
  }

  Future<void> updateTagsForUser(String userId, List<String> tagNames) async {
    // 1. Get the IDs for the given tag names from the 'tags' table.
    final tagsResponse = await _supabase.from('tags').select('id, name').inFilter('name', tagNames);
    final tagIds = tagsResponse.map((tag) => tag['id'] as String).toList();

    // 2. Call the 'update_user_tags' RPC function to handle the update atomically.
    await _supabase.rpc(
      'update_user_tags',
      params: {'p_user_id': userId, 'p_tag_ids': tagIds},
    );
    
    // Invalidate cache for this user
    if (_profileCache.containsKey(userId)) {
      // Get updated tags
      final updatedTags = await _supabase
          .from('user_tags')
          .select('tags(name)')
          .eq('user_id', userId);
          
      _profileCache[userId]!['tags'] = updatedTags.map((e) => e['tags']).toList();
      _cacheTimestamps[userId] = DateTime.now();
      
      // Notify listeners
      if (_profileStreams.containsKey(userId)) {
        _profileStreams[userId]!.add(_profileCache[userId]!);
      }
    }
  }

  /// Get profile data with caching support
  Future<Map<String, dynamic>> getProfileData(String userId) async {
    // Check if we have a valid cached version
    final now = DateTime.now();
    if (_profileCache.containsKey(userId) && 
        _cacheTimestamps.containsKey(userId) &&
        now.difference(_cacheTimestamps[userId]!) < _cacheDuration) {
      return _profileCache[userId]!;
    }

    try {
      // Fetch all data in parallel
      final results = await Future.wait<dynamic>([
        _supabase.from('profiles').select().eq('id', userId).single(),
        _supabase.from('user_following').select().eq('followed_seller_id', userId).count(),
        _supabase.from('user_following').select().eq('follower_id', userId).count(),
        _supabase.from('user_tags').select('tags(name)').eq('user_id', userId),
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

      // Update cache
      _profileCache[userId] = profileMap;
      _cacheTimestamps[userId] = now;

      // Notify listeners if any
      if (_profileStreams.containsKey(userId)) {
        _profileStreams[userId]!.add(profileMap);
      }

      return profileMap;
    } catch (e) {
      // If we have cached data, return it even if it's stale
      if (_profileCache.containsKey(userId)) {
        developer.log('Using cached profile data due to error: $e', name: 'ProfileService');
        return _profileCache[userId]!;
      }
      rethrow;
    }
  }

  /// Get a stream of profile data that will emit when the profile is updated
  Stream<Map<String, dynamic>>? watchProfileData(String userId) {
    if (!_profileStreams.containsKey(userId)) {
      _profileStreams[userId] = BehaviorSubject<Map<String, dynamic>>();
      // Initial load
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

  /// Clear the cache for a specific user
  void clearCache(String userId) {
    _profileCache.remove(userId);
    _cacheTimestamps.remove(userId);
  }

  /// Clear all cached data
  void clearAllCache() {
    _profileCache.clear();
    _cacheTimestamps.clear();
  }
}

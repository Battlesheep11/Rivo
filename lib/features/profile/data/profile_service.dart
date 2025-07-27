import 'dart:developer' as developer;

import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Update the bio for a user in the profiles table
  Future<void> updateBio(String userId, String bio) async {
    await _supabase.from('profiles').update({'bio': bio}).eq('id', userId);
  }

  Future<Map<String, dynamic>> getProfileData(String userId) async {
    try {
      // Fetch all data in parallel
      final results = await Future.wait<dynamic>([
        _supabase.from('profiles').select().eq('id', userId).single(),
        // Corrected: Count who is following the current user.
        _supabase.from('user_following').select().eq('followed_seller_id', userId).count(),
        // Corrected: Count who the current user is following.
        _supabase.from('user_following').select().eq('follower_id', userId).count(),
        _supabase.from('user_tags').select('tags(name)').eq('user_id', userId),
      ]);

      // Process results
      final profileData = results[0] as Map<String, dynamic>;
      final followerCount = (results[1] as PostgrestResponse).count;
      final followingCount = (results[2] as PostgrestResponse).count;
      final tagsData = results[3] as List<dynamic>;

      final processedTags = tagsData.map((e) => (e as Map)['tags']).toList();

      return {
        'profile': profileData,
        'followers_count': followerCount,
        'following_count': followingCount,
        'tags': processedTags,
      };
    } catch (e) {
      // Handle errors, e.g., user not found, network issues
      developer.log('Error fetching profile data: $e', name: 'ProfileService');
      rethrow;
    }
  }
}

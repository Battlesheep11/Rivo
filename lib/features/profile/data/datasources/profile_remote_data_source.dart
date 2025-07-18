import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rivo_app_beta/core/error_handling/app_exception.dart';
import 'package:rivo_app_beta/features/profile/domain/entities/user_profile_entity.dart';
import 'package:rivo_app_beta/features/profile/domain/entities/social_link_entity.dart';
import 'package:rivo_app_beta/features/feed/domain/entities/feed_post_entity.dart';
import 'package:rivo_app_beta/features/feed/data/datasources/feed_remote_data_source.dart';


/// A data source that handles remote profile-related operations.
///
/// This class is responsible for:
/// - Fetching and updating user profile
/// - Managing seller social links
/// - Handling reblogs and following actions
class ProfileRemoteDataSource {
  final SupabaseClient _client;
  late final FeedRemoteDataSource _feed;


  ProfileRemoteDataSource({required SupabaseClient client}) : _client = client {
    _feed = FeedRemoteDataSource(client: _client);
  }


  Future<bool> isUserSeller(String userId) async {
  final res = await _client
      .from('profiles')
      .select('is_seller')
      .eq('id', userId)
      .maybeSingle();

  if (res == null) {
    throw AppException.notFound('User not found');
  }

  return res['is_seller'] == true;
}

Future<List<FeedPostEntity>> getMyItems(String userId) async {
  return await _feed.getPostsByCreator(userId);
}

Future<List<FeedPostEntity>> getMyDesignPosts(String userId) async {
  final ids = await getRebloggedPostIds(userId);
  return await _feed.getPostsByIds(ids);
}

  Future<UserProfileEntity> getUserProfile(String userId) async {
    try {
      final res = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (res == null) {
        throw AppException.notFound('User not found');
      }

      return UserProfileEntity(
        id: res['id'],
        username: res['username'],
        displayName: res['display_name'],
        avatarUrl: res['avatar_url'],
        bio: res['bio'],
        isSeller: res['is_seller'] ?? false,
        language: res['language'] ?? 'he',
        lastSeenAt: res['last_seen_at'] != null ? DateTime.parse(res['last_seen_at']) : null,
        createdAt: res['created_at'] != null ? DateTime.parse(res['created_at']) : null,
      );
    } on PostgrestException catch (e) {
      throw AppException.network(e.message);
    } catch (e) {
      throw AppException.unexpected('Unexpected error: $e');
    }
  }

  Future<void> updateUserProfile(UserProfileEntity updated) async {
    try {
      await _client.from('profiles').update({
        'display_name': updated.displayName,
        'bio': updated.bio,
        'language': updated.language,
        'last_seen_at': DateTime.now().toIso8601String(),
      }).eq('id', updated.id);
    } catch (e) {
      throw AppException.unexpected('Failed to update profile: $e');
    }
  }

  Future<List<SocialLinkEntity>> getSocialLinks(String userId) async {
    try {
      final res = await _client
          .from('seller_social_links')
          .select()
          .eq('profile_id', userId);

      return (res as List)
          .map((row) => SocialLinkEntity(
                platformId: row['platform_id'],
                url: row['url'],
              ))
          .toList();
    } catch (e) {
      throw AppException.unexpected('Failed to fetch social links: $e');
    }
  }

  Future<void> updateSocialLinks(String userId, List<SocialLinkEntity> links) async {
    try {
      await _client.from('seller_social_links').delete().eq('profile_id', userId);
      if (links.isNotEmpty) {
        final rows = links
            .map((link) => {
                  'profile_id': userId,
                  'platform_id': link.platformId,
                  'url': link.url,
                })
            .toList();

        await _client.from('seller_social_links').insert(rows);
      }
    } catch (e) {
      throw AppException.unexpected('Failed to update social links: $e');
    }
  }

  Future<List<String>> getRebloggedPostIds(String userId) async {
    try {
      final res = await _client
          .from('user_reblogs')
          .select('post_id')
          .eq('user_id', userId);

      return (res as List).map((r) => r['post_id'] as String).toList();
    } catch (e) {
      throw AppException.unexpected('Failed to fetch reblogs: $e');
    }
  }

  Future<void> addReblog(String userId, String postId) async {
    try {
      await _client.from('user_reblogs').insert({
        'user_id': userId,
        'post_id': postId,
      });
    } catch (e) {
      throw AppException.unexpected('Failed to add reblog: $e');
    }
  }

  Future<void> removeReblog(String userId, String postId) async {
    try {
      await _client
          .from('user_reblogs')
          .delete()
          .match({'user_id': userId, 'post_id': postId});
    } catch (e) {
      throw AppException.unexpected('Failed to remove reblog: $e');
    }
  }

  Future<void> followSeller(String userId, String sellerId) async {
    try {
      await _client.from('user_following').insert({
        'follower_id': userId,
        'followed_seller_id': sellerId,
      });
    } catch (e) {
      throw AppException.unexpected('Failed to follow seller: $e');
    }
  }

  Future<void> unfollowSeller(String userId, String sellerId) async {
    try {
      await _client
          .from('user_following')
          .delete()
          .match({'follower_id': userId, 'followed_seller_id': sellerId});
    } catch (e) {
      throw AppException.unexpected('Failed to unfollow seller: $e');
    }
  }

  Future<List<String>> getFollowedSellerIds(String userId) async {
    try {
      final res = await _client
          .from('user_following')
          .select('followed_seller_id')
          .eq('follower_id', userId);

      return (res as List)
          .map((r) => r['followed_seller_id'] as String)
          .toList();
    } catch (e) {
      throw AppException.unexpected('Failed to fetch following list: $e');
    }
  }
}

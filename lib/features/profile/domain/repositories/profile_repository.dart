import 'package:rivo_app_beta/features/profile/domain/entities/user_profile_entity.dart';
import 'package:rivo_app_beta/features/profile/domain/entities/social_link_entity.dart';
import 'package:rivo_app_beta/features/feed/domain/entities/feed_post_entity.dart';

abstract class ProfileRepository {
  Future<UserProfileEntity> getUserProfile(String userId);
  Future<void> updateUserProfile(UserProfileEntity updated);

  Future<List<SocialLinkEntity>> getSocialLinks(String userId);
  Future<void> updateSocialLinks(String userId, List<SocialLinkEntity> links);

  Future<List<String>> getRebloggedPostIds(String userId);
  Future<void> addReblog(String userId, String postId);
  Future<void> removeReblog(String userId, String postId);

  Future<void> followSeller(String userId, String sellerId);
  Future<void> unfollowSeller(String userId, String sellerId);
  Future<List<String>> getFollowedSellerIds(String userId);

  Future<bool> isUserSeller(String userId);
  Future<List<FeedPostEntity>> getMyItems(String userId);        // למוכרים
  Future<List<FeedPostEntity>> getMyDesignPosts(String userId); // לרגילים
}

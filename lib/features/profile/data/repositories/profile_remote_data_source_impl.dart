import 'package:rivo_app_beta/core/error_handling/app_exception.dart';
import 'package:rivo_app_beta/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:rivo_app_beta/features/profile/domain/entities/user_profile_entity.dart';
import 'package:rivo_app_beta/features/profile/domain/entities/social_link_entity.dart';
import 'package:rivo_app_beta/features/profile/domain/repositories/profile_repository.dart';
import 'package:rivo_app_beta/features/feed/domain/entities/feed_post_entity.dart';

/// Implementation of [ProfileRepository].
///
/// Delegates to [ProfileRemoteDataSource] and adds:
/// - Error handling
/// - Separation between domain and infrastructure
class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl({required this.remoteDataSource});

  @override
  Future<UserProfileEntity> getUserProfile(String userId) async {
    try {
      return await remoteDataSource.getUserProfile(userId);
    } on AppException {
      rethrow;
    } catch (e, stackTrace) {
      throw AppException.unexpected('Failed to load profile: $e', stackTrace: stackTrace);
    }
  }

  @override
  Future<void> updateUserProfile(UserProfileEntity updated) async {
    try {
      await remoteDataSource.updateUserProfile(updated);
    } on AppException {
      rethrow;
    } catch (e, stackTrace) {
      throw AppException.unexpected('Failed to update profile: $e', stackTrace: stackTrace);
    }
  }

  @override
  Future<List<SocialLinkEntity>> getSocialLinks(String userId) async {
    try {
      return await remoteDataSource.getSocialLinks(userId);
    } on AppException {
      rethrow;
    } catch (e, stackTrace) {
      throw AppException.unexpected('Failed to get social links: $e', stackTrace: stackTrace);
    }
  }

  @override
  Future<void> updateSocialLinks(String userId, List<SocialLinkEntity> links) async {
    try {
      await remoteDataSource.updateSocialLinks(userId, links);
    } on AppException {
      rethrow;
    } catch (e, stackTrace) {
      throw AppException.unexpected('Failed to update social links: $e', stackTrace: stackTrace);
    }
  }

  @override
  Future<List<String>> getRebloggedPostIds(String userId) async {
    try {
      return await remoteDataSource.getRebloggedPostIds(userId);
    } on AppException {
      rethrow;
    } catch (e, stackTrace) {
      throw AppException.unexpected('Failed to fetch reblogs: $e', stackTrace: stackTrace);
    }
  }

  @override
  Future<void> addReblog(String userId, String postId) async {
    try {
      await remoteDataSource.addReblog(userId, postId);
    } on AppException {
      rethrow;
    } catch (e, stackTrace) {
      throw AppException.unexpected('Failed to add reblog: $e', stackTrace: stackTrace);
    }
  }

  @override
  Future<void> removeReblog(String userId, String postId) async {
    try {
      await remoteDataSource.removeReblog(userId, postId);
    } on AppException {
      rethrow;
    } catch (e, stackTrace) {
      throw AppException.unexpected('Failed to remove reblog: $e', stackTrace: stackTrace);
    }
  }

  @override
  Future<void> followSeller(String userId, String sellerId) async {
    try {
      await remoteDataSource.followSeller(userId, sellerId);
    } on AppException {
      rethrow;
    } catch (e, stackTrace) {
      throw AppException.unexpected('Failed to follow seller: $e', stackTrace: stackTrace);
    }
  }

  @override
  Future<void> unfollowSeller(String userId, String sellerId) async {
    try {
      await remoteDataSource.unfollowSeller(userId, sellerId);
    } on AppException {
      rethrow;
    } catch (e, stackTrace) {
      throw AppException.unexpected('Failed to unfollow seller: $e', stackTrace: stackTrace);
    }
  }

  @override
  Future<List<String>> getFollowedSellerIds(String userId) async {
    try {
      return await remoteDataSource.getFollowedSellerIds(userId);
    } on AppException {
      rethrow;
    } catch (e, stackTrace) {
      throw AppException.unexpected('Failed to fetch followed sellers: $e', stackTrace: stackTrace);
    }
  }

@override
Future<bool> isUserSeller(String userId) async {
  try {
    return await remoteDataSource.isUserSeller(userId);
  } on AppException {
    rethrow;
  } catch (e, stackTrace) {
    throw AppException.unexpected('Failed to check seller status: $e', stackTrace: stackTrace);
  }
}

@override
Future<List<FeedPostEntity>> getMyItems(String userId) async {
  try {
    return await remoteDataSource.getMyItems(userId);
  } on AppException {
    rethrow;
  } catch (e, stackTrace) {
    throw AppException.unexpected('Failed to fetch seller posts: $e', stackTrace: stackTrace);
  }
}

@override
Future<List<FeedPostEntity>> getMyDesignPosts(String userId) async {
  try {
    return await remoteDataSource.getMyDesignPosts(userId);
  } on AppException {
    rethrow;
  } catch (e, stackTrace) {
    throw AppException.unexpected('Failed to fetch reblogs: $e', stackTrace: stackTrace);
  }
}


}

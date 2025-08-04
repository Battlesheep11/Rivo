import 'package:equatable/equatable.dart';
import 'package:rivo_app_beta/core/security/field_security.dart';
import 'package:rivo_app_beta/core/error_handling/app_exception.dart';

/// Represents a post in the feed.
///
/// This class contains all the data needed to display a post in the feed,
/// including post details, creator information, product information,
/// and media content.
///
/// The class extends [Equatable] to enable value-based equality comparison.
class FeedPostEntity extends Equatable {
  /// Unique identifier for the post
  final String id;
  
  /// When the post was created
  final DateTime createdAt;
  
  /// Number of likes the post has received
  final int likeCount;
  
  /// Whether the current user has liked this post
  final bool isLikedByMe;
  
  /// ID of the user who created the post
  final String creatorId;
  
  /// Optional caption/text content of the post
  final String? caption;
  
  /// ID of the product associated with this post, if any
  final String? productId;
  
  /// Username of the post creator
  final String username;
  
  /// URL to the avatar/image of the post creator
  final String? avatarUrl;
  
  /// Title of the associated product
  final String productTitle;
  
  /// Optional description of the associated product
  final String? productDescription;
  
  /// Price of the associated product
  final double productPrice;
  
  /// List of media URLs (images/videos) associated with the post
  final List<String> mediaUrls;
  
  /// List of tags/categories associated with the post
  final List<String> tags;

  /// Creates a new [FeedPostEntity] instance.
  /// 
  /// All parameters are required except for [caption], [avatarUrl], and [productDescription]
  /// which are optional.
  const FeedPostEntity({
    required this.id,
    required this.createdAt,
    required this.likeCount,
    required this.isLikedByMe,
    required this.creatorId,
    this.caption,
    this.productId,
    required this.username,
    this.avatarUrl,
    required this.productTitle,
    this.productDescription,
    required this.productPrice,
    required this.mediaUrls,
    required this.tags,
  });

  /// Creates a copy of this post with the given fields replaced with the new values.
  /// 
  /// Only the [likeCount], [isLikedByMe], and [tags] can be modified.
  /// All other fields remain the same as in the original post.
  /// 
  /// Returns a new [FeedPostEntity] with the updated values.
  FeedPostEntity copyWith({
    int? likeCount,
    bool? isLikedByMe,
    List<String>? tags,
  }) {
    return FeedPostEntity(
      id: id,
      createdAt: createdAt,
      likeCount: likeCount ?? this.likeCount,
      isLikedByMe: isLikedByMe ?? this.isLikedByMe,
      creatorId: creatorId,
      caption: caption,
      productId: productId,
      username: username,
      avatarUrl: avatarUrl,
      productTitle: productTitle,
      productDescription: productDescription,
      productPrice: productPrice,
      mediaUrls: mediaUrls,
      tags: tags ?? this.tags,
    );
  }

  @override
  /// The list of properties that will be used to determine whether two instances
  /// are equal. Used by the [Equatable] package.
  List<Object?> get props => [
        id,
        createdAt,
        likeCount,
        isLikedByMe,
        creatorId,
        caption,
        productId,
        username,
        avatarUrl,
        productTitle,
        productDescription,
        productPrice,
        mediaUrls,
        tags,
      ];

      /// Creates a [FeedPostEntity] from a JSON map.
      /// 
      /// [json]: A map containing the post data
      /// 
      /// Throws [AppException] if any required fields are missing or invalid.
      factory FeedPostEntity.fromMap(Map<String, dynamic> json) {
        try {
          // Extract and validate product data
          final product = json['product'] as Map<String, dynamic>? ?? {};
          final creator = json['creator'] as Map<String, dynamic>? ?? {};
          
          // Get media list safely
          final productMediaList = (product['media'] as List<dynamic>? ?? [])
              .whereType<Map<String, dynamic>>()
              .toList();

          // Sanitize and validate media URLs
          final productMediaUrls = productMediaList
              .map((m) => m['media_url'] as String?)
              .whereType<String>()
              .map((url) => FieldSecurity.sanitizeUrl(
                    value: url,
                    fieldName: 'Media URL',
                  ))
              .whereType<String>()
              .toList();

          // Validate and sanitize all fields
          final id = FieldSecurity.validateId(json['id'], fieldName: 'Post ID');
          final creatorId = FieldSecurity.validateId(
            json['creator_id'],
            fieldName: 'Creator ID',
          );
          
          final username = FieldSecurity.sanitizeString(
            value: creator['username'],
            fieldName: 'Username',
            isRequired: true,
            maxLength: 50,
          ) ?? 'Unknown';

          final avatarUrl = FieldSecurity.sanitizeUrl(
            value: creator['avatar_url'],
            fieldName: 'Avatar URL',
          );

          final productTitle = FieldSecurity.sanitizeString(
            value: product['title'],
            fieldName: 'Product title',
            isRequired: true,
            maxLength: 100,
          ) ?? '';

          final productDescription = FieldSecurity.sanitizeString(
            value: product['description'],
            fieldName: 'Product description',
            maxLength: 1000,
          );

          // Parse and validate price
          double productPrice;
          try {
            final price = product['price'];
            if (price is num) {
              productPrice = price.toDouble();
            } else if (price is String) {
              productPrice = double.tryParse(price) ?? 0.0;
            } else {
              productPrice = 0.0;
            }
            
            // Ensure price is not negative
            if (productPrice < 0) {
              productPrice = 0.0;
            }
          } catch (e) {
            productPrice = 0.0;
          }

          // Parse and validate creation date
          DateTime createdAt;
          try {
            createdAt = DateTime.parse(json['created_at'] as String);
          } catch (e) {
            createdAt = DateTime.now();
          }

          // Get like count safely
          final likeCount = json['like_count'] is int 
              ? (json['like_count'] as int) 
              : 0;

          return FeedPostEntity(
            id: id,
            createdAt: createdAt,
            likeCount: likeCount,
            creatorId: creatorId,
            caption: FieldSecurity.sanitizeString(
              value: json['caption'],
              fieldName: 'Caption',
              maxLength: 500,
            ),
            productId: json['product_id']?.toString(),
            username: username,
            avatarUrl: avatarUrl,
            productTitle: productTitle,
            productDescription: productDescription,
            productPrice: productPrice,
            mediaUrls: productMediaUrls,
            tags: FieldSecurity.sanitizeStringList(
              value: json['tags'],
              fieldName: 'Tags',
              maxItems: 10,
              maxItemLength: 30,
            ),
            isLikedByMe: json['is_liked_by_me'] == true,
          );
        } catch (e) {
          // Log the error and rethrow with a more user-friendly message
          if (e is AppException) rethrow;
          throw AppException.validation('Invalid post data: ${e.toString()}');
        }
      }

}

import 'package:equatable/equatable.dart';

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
  
  /// ID of the product associated with this post
  final String productId;
  
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
    required this.productId,
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

      factory FeedPostEntity.fromMap(Map<String, dynamic> json) {
  final product = json['product'] as Map<String, dynamic>? ?? {};
  final productMediaList = (product['media'] as List<dynamic>? ?? [])
      .cast<Map<String, dynamic>>();

  final productMediaUrls = productMediaList
      .map((m) => m['media_url'] as String?)
      .whereType<String>()
      .toList();

  return FeedPostEntity(
    id: json['id'] as String,
    createdAt: DateTime.parse(json['created_at']),
    likeCount: (json['like_count'] ?? 0) as int,
    creatorId: json['creator_id'] as String,
    caption: json['caption'] as String?,
    productId: json['product_id'] as String,
    username: json['creator']?['username'] ?? 'Unknown',
    avatarUrl: json['creator']?['avatar_url'],
    productTitle: product['title'] ?? '',
    productDescription: product['description'],
    productPrice: (product['price'] ?? 0).toDouble(),
    mediaUrls: productMediaUrls,
    tags: [],
    isLikedByMe: false,
  );
}

}

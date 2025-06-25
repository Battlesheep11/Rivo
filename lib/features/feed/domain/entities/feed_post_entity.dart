import 'package:equatable/equatable.dart';

class FeedPostEntity extends Equatable {
  final String id;
  final DateTime createdAt;
  final int likeCount;
  final bool isLikedByMe;
  final String creatorId;
  final String? caption;
  final String productId;
  final String username;
  final String? avatarUrl;
  final String productTitle;
  final String? productDescription;
  final double productPrice;
  final List<String> mediaUrls;
  final List<String> tags;

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
}

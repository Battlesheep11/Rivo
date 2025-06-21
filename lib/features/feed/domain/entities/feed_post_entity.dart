import 'package:equatable/equatable.dart';

class FeedPostEntity extends Equatable {
  final String id;
  final DateTime createdAt;
  final int likeCount;
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

  @override
  List<Object?> get props => [
        id,
        createdAt,
        likeCount,
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

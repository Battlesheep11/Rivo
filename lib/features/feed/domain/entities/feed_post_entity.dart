class FeedPostEntity {
  final String postId;
  final String productId;
  final String title;
  final String caption;
  final List<String> mediaUrls;
  final String username;       
  final String avatarUrl;      

  FeedPostEntity({
    required this.postId,
    required this.productId,
    required this.title,
    required this.caption,
    required this.mediaUrls,
    required this.username,
    required this.avatarUrl,
  });
}

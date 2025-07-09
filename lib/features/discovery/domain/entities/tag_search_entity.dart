class TagSearchEntity {
  final String name;
  final String? imageUrl;
  final int? postCount;

  const TagSearchEntity({
    required this.name,
    this.imageUrl,
    this.postCount,
  });

  factory TagSearchEntity.fromJson(Map<String, dynamic> json) {
    return TagSearchEntity(
      name: json['tag_name'] as String,
      imageUrl: json['image_url'] as String?,
      postCount: json['post_count'] as int?,
    );
  }
}

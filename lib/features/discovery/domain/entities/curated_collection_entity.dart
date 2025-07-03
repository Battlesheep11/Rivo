class CuratedCollectionEntity {
  final String id;
  final String name;
  final int postCount;
  final String? topPostId;
 final String imageUrl;
final String? iconUrl;

  const CuratedCollectionEntity({
    required this.id,
    required this.name,
    required this.postCount,
    this.topPostId,
    required this.imageUrl,
    this.iconUrl,
  });
}

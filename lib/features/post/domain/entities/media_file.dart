class MediaFile {
  final String id;
  final String url;
  final String type; // 'image' or 'video'
  final int? sortOrder;

  MediaFile({
    required this.id,
    required this.url,
    required this.type,
    this.sortOrder,
  });
}

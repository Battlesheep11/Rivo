class MediaFile {
  final String url;
  final String type; // "image" or "video"
  final int? sortOrder;

  MediaFile({
    required this.url,
    required this.type,
    this.sortOrder,
  });
}

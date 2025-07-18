class MediaEntity {
  final String id;
  final String url;

  const MediaEntity({
    required this.id,
    required this.url,
  });

  factory MediaEntity.fromJson(Map<String, dynamic> json) {
  return MediaEntity(
    id: json['id'] as String,
    url: json['media_url'] as String,
  );
}

}

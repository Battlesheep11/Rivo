class DiscoveryProductEntity {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String? ctaLabel;

  const DiscoveryProductEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    this.ctaLabel,
  });
}

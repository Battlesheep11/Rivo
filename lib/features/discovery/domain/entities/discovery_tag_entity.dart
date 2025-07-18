class DiscoveryTagEntity {
  final String id;
  final String name;
   final String? imageUrl;

  const DiscoveryTagEntity({
    required this.id,
    required this.name,
     this.imageUrl,
  });
}

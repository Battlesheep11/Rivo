import 'media_entity.dart';
import 'seller_entity.dart';

class SearchProductEntity {
  final String id;
  final String title;
  final double price;
  final String? brand;
  final List<MediaEntity> media;
  final SellerEntity seller;

  SearchProductEntity({
    required this.id,
    required this.title,
    required this.price,
    this.brand,
    required this.media,
    required this.seller,
  });

  factory SearchProductEntity.fromJson(Map<String, dynamic> json) {
  final mediaList = (json['product_media'] as List<dynamic>? ?? [])
      .map((item) => item['media']) 
      .whereType<Map<String, dynamic>>()
      .map(MediaEntity.fromJson)
      .toList();

  return SearchProductEntity(
    id: json['id'] as String,
    title: json['title'] as String,
    price: (json['price'] as num).toDouble(),
    brand: json['brand'] as String?,
    media: mediaList,
    seller: SellerEntity.fromJson(json['seller']),
  );
}

}

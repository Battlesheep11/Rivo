import 'package:flutter/foundation.dart';

@immutable
class Product {
  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.imageUrls,
    required this.size,
    required this.fabric,
    required this.condition,
    required this.brand,
    required this.sellerId,
    this.postId,
  });

  final String id;
  final String name;
  final double price;
  final String description;
  final List<String> imageUrls;
  final String size;
  final String fabric;
  final String condition;
  final String brand;
  final String sellerId;
  final String? postId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Product &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          price == other.price &&
          description == other.description &&
          listEquals(imageUrls, other.imageUrls) &&
          size == other.size &&
          fabric == other.fabric &&
          condition == other.condition &&
          brand == other.brand &&
          sellerId == other.sellerId &&
          postId == other.postId;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      price.hashCode ^
      description.hashCode ^
      imageUrls.hashCode ^
      size.hashCode ^
      fabric.hashCode ^
      condition.hashCode ^
      brand.hashCode ^
      sellerId.hashCode ^
      postId.hashCode;

  Product copyWith({
    String? id,
    String? name,
    double? price,
    String? description,
    List<String>? imageUrls,
    String? size,
    String? fabric,
    String? condition,
    String? brand,
    String? sellerId,
    String? postId,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      description: description ?? this.description,
      imageUrls: imageUrls ?? this.imageUrls,
      size: size ?? this.size,
      fabric: fabric ?? this.fabric,
      condition: condition ?? this.condition,
      brand: brand ?? this.brand,
      sellerId: sellerId ?? this.sellerId,
      postId: postId ?? this.postId,
    );
  }
}

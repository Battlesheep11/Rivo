import 'package:flutter/foundation.dart';

@immutable
class Seller {
  const Seller({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.rating,
    required this.reviewCount,
  });

  final String id;
  final String name;
  final String avatarUrl;
  final double rating;
  final int reviewCount;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Seller &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          avatarUrl == other.avatarUrl &&
          rating == other.rating &&
          reviewCount == other.reviewCount;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      avatarUrl.hashCode ^
      rating.hashCode ^
      reviewCount.hashCode;
}

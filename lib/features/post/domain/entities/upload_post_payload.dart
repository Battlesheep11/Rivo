import 'media_file.dart';
import 'tag_entity.dart';

class UploadPostPayload {
  // האם לכלול מוצר כחלק מהפוסט
  final bool hasProduct;

  // שדות מוצר (אם hasProduct == true)
  final String? productTitle;
  final String? productDescription;
  final double? productPrice;
  final String? categoryId;
  final double? chest;
  final double? waist;
  final double? length;

  // שדות פוסט (משותפים)
  final String? caption;
  final List<MediaFile> media;
  final List<TagEntity> tags;

  UploadPostPayload({
    required this.hasProduct,
    this.productTitle,
    this.productDescription,
    this.productPrice,
    this.categoryId,
    this.chest,
    this.waist,
    this.length,
    required this.caption,
    required this.media,
    required this.tags,
  });

  bool get isValid =>
      media.isNotEmpty &&
      (hasProduct
          ? productTitle != null &&
              productPrice != null &&
              categoryId != null
          : true);
}

// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'upload_post_payload.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$UploadPostPayload {
  // Controls if we create a product or just a post
  bool get hasProduct =>
      throw _privateConstructorUsedError; // --- Product basics ---
  String? get productTitle => throw _privateConstructorUsedError;
  String? get productDescription => throw _privateConstructorUsedError;
  double? get productPrice => throw _privateConstructorUsedError;
  String? get categoryId =>
      throw _privateConstructorUsedError; // --- Measurements ---
  double? get chest => throw _privateConstructorUsedError;
  double? get waist => throw _privateConstructorUsedError;
  double? get length => throw _privateConstructorUsedError;
  double? get sleeveLength => throw _privateConstructorUsedError;
  double? get shoulderWidth =>
      throw _privateConstructorUsedError; // --- Brand / Size ---
  String? get brand => throw _privateConstructorUsedError;
  String? get size =>
      throw _privateConstructorUsedError; // --- Legacy display strings (kept so UI doesn’t break) ---
  String? get material => throw _privateConstructorUsedError;
  String? get condition =>
      throw _privateConstructorUsedError; // --- Schema-aligned codes (persist these) ---
  String? get conditionCode =>
      throw _privateConstructorUsedError; // 'never_worn' | 'as_new' | 'good' | 'fair'
  List<String>? get defectCodes =>
      throw _privateConstructorUsedError; // product_defects.defect_code
  List<String>? get materialCodes =>
      throw _privateConstructorUsedError; // product_materials.material_code
  List<String>? get colorCodes =>
      throw _privateConstructorUsedError; // product_colors.color_code
  String get statusCode => throw _privateConstructorUsedError;
  String? get otherMaterial => throw _privateConstructorUsedError;
  String? get otherDefectNote =>
      throw _privateConstructorUsedError; // --- Post ---
  String? get caption =>
      throw _privateConstructorUsedError; // --- Media & Tags ---
  List<UploadableMedia> get media => throw _privateConstructorUsedError;
  List<TagEntity> get tags => throw _privateConstructorUsedError;

  /// Create a copy of UploadPostPayload
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UploadPostPayloadCopyWith<UploadPostPayload> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UploadPostPayloadCopyWith<$Res> {
  factory $UploadPostPayloadCopyWith(
    UploadPostPayload value,
    $Res Function(UploadPostPayload) then,
  ) = _$UploadPostPayloadCopyWithImpl<$Res, UploadPostPayload>;
  @useResult
  $Res call({
    bool hasProduct,
    String? productTitle,
    String? productDescription,
    double? productPrice,
    String? categoryId,
    double? chest,
    double? waist,
    double? length,
    double? sleeveLength,
    double? shoulderWidth,
    String? brand,
    String? size,
    String? material,
    String? condition,
    String? conditionCode,
    List<String>? defectCodes,
    List<String>? materialCodes,
    List<String>? colorCodes,
    String statusCode,
    String? otherMaterial,
    String? otherDefectNote,
    String? caption,
    List<UploadableMedia> media,
    List<TagEntity> tags,
  });
}

/// @nodoc
class _$UploadPostPayloadCopyWithImpl<$Res, $Val extends UploadPostPayload>
    implements $UploadPostPayloadCopyWith<$Res> {
  _$UploadPostPayloadCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UploadPostPayload
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? hasProduct = null,
    Object? productTitle = freezed,
    Object? productDescription = freezed,
    Object? productPrice = freezed,
    Object? categoryId = freezed,
    Object? chest = freezed,
    Object? waist = freezed,
    Object? length = freezed,
    Object? sleeveLength = freezed,
    Object? shoulderWidth = freezed,
    Object? brand = freezed,
    Object? size = freezed,
    Object? material = freezed,
    Object? condition = freezed,
    Object? conditionCode = freezed,
    Object? defectCodes = freezed,
    Object? materialCodes = freezed,
    Object? colorCodes = freezed,
    Object? statusCode = null,
    Object? otherMaterial = freezed,
    Object? otherDefectNote = freezed,
    Object? caption = freezed,
    Object? media = null,
    Object? tags = null,
  }) {
    return _then(
      _value.copyWith(
            hasProduct: null == hasProduct
                ? _value.hasProduct
                : hasProduct // ignore: cast_nullable_to_non_nullable
                      as bool,
            productTitle: freezed == productTitle
                ? _value.productTitle
                : productTitle // ignore: cast_nullable_to_non_nullable
                      as String?,
            productDescription: freezed == productDescription
                ? _value.productDescription
                : productDescription // ignore: cast_nullable_to_non_nullable
                      as String?,
            productPrice: freezed == productPrice
                ? _value.productPrice
                : productPrice // ignore: cast_nullable_to_non_nullable
                      as double?,
            categoryId: freezed == categoryId
                ? _value.categoryId
                : categoryId // ignore: cast_nullable_to_non_nullable
                      as String?,
            chest: freezed == chest
                ? _value.chest
                : chest // ignore: cast_nullable_to_non_nullable
                      as double?,
            waist: freezed == waist
                ? _value.waist
                : waist // ignore: cast_nullable_to_non_nullable
                      as double?,
            length: freezed == length
                ? _value.length
                : length // ignore: cast_nullable_to_non_nullable
                      as double?,
            sleeveLength: freezed == sleeveLength
                ? _value.sleeveLength
                : sleeveLength // ignore: cast_nullable_to_non_nullable
                      as double?,
            shoulderWidth: freezed == shoulderWidth
                ? _value.shoulderWidth
                : shoulderWidth // ignore: cast_nullable_to_non_nullable
                      as double?,
            brand: freezed == brand
                ? _value.brand
                : brand // ignore: cast_nullable_to_non_nullable
                      as String?,
            size: freezed == size
                ? _value.size
                : size // ignore: cast_nullable_to_non_nullable
                      as String?,
            material: freezed == material
                ? _value.material
                : material // ignore: cast_nullable_to_non_nullable
                      as String?,
            condition: freezed == condition
                ? _value.condition
                : condition // ignore: cast_nullable_to_non_nullable
                      as String?,
            conditionCode: freezed == conditionCode
                ? _value.conditionCode
                : conditionCode // ignore: cast_nullable_to_non_nullable
                      as String?,
            defectCodes: freezed == defectCodes
                ? _value.defectCodes
                : defectCodes // ignore: cast_nullable_to_non_nullable
                      as List<String>?,
            materialCodes: freezed == materialCodes
                ? _value.materialCodes
                : materialCodes // ignore: cast_nullable_to_non_nullable
                      as List<String>?,
            colorCodes: freezed == colorCodes
                ? _value.colorCodes
                : colorCodes // ignore: cast_nullable_to_non_nullable
                      as List<String>?,
            statusCode: null == statusCode
                ? _value.statusCode
                : statusCode // ignore: cast_nullable_to_non_nullable
                      as String,
            otherMaterial: freezed == otherMaterial
                ? _value.otherMaterial
                : otherMaterial // ignore: cast_nullable_to_non_nullable
                      as String?,
            otherDefectNote: freezed == otherDefectNote
                ? _value.otherDefectNote
                : otherDefectNote // ignore: cast_nullable_to_non_nullable
                      as String?,
            caption: freezed == caption
                ? _value.caption
                : caption // ignore: cast_nullable_to_non_nullable
                      as String?,
            media: null == media
                ? _value.media
                : media // ignore: cast_nullable_to_non_nullable
                      as List<UploadableMedia>,
            tags: null == tags
                ? _value.tags
                : tags // ignore: cast_nullable_to_non_nullable
                      as List<TagEntity>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UploadPostPayloadImplCopyWith<$Res>
    implements $UploadPostPayloadCopyWith<$Res> {
  factory _$$UploadPostPayloadImplCopyWith(
    _$UploadPostPayloadImpl value,
    $Res Function(_$UploadPostPayloadImpl) then,
  ) = __$$UploadPostPayloadImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    bool hasProduct,
    String? productTitle,
    String? productDescription,
    double? productPrice,
    String? categoryId,
    double? chest,
    double? waist,
    double? length,
    double? sleeveLength,
    double? shoulderWidth,
    String? brand,
    String? size,
    String? material,
    String? condition,
    String? conditionCode,
    List<String>? defectCodes,
    List<String>? materialCodes,
    List<String>? colorCodes,
    String statusCode,
    String? otherMaterial,
    String? otherDefectNote,
    String? caption,
    List<UploadableMedia> media,
    List<TagEntity> tags,
  });
}

/// @nodoc
class __$$UploadPostPayloadImplCopyWithImpl<$Res>
    extends _$UploadPostPayloadCopyWithImpl<$Res, _$UploadPostPayloadImpl>
    implements _$$UploadPostPayloadImplCopyWith<$Res> {
  __$$UploadPostPayloadImplCopyWithImpl(
    _$UploadPostPayloadImpl _value,
    $Res Function(_$UploadPostPayloadImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UploadPostPayload
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? hasProduct = null,
    Object? productTitle = freezed,
    Object? productDescription = freezed,
    Object? productPrice = freezed,
    Object? categoryId = freezed,
    Object? chest = freezed,
    Object? waist = freezed,
    Object? length = freezed,
    Object? sleeveLength = freezed,
    Object? shoulderWidth = freezed,
    Object? brand = freezed,
    Object? size = freezed,
    Object? material = freezed,
    Object? condition = freezed,
    Object? conditionCode = freezed,
    Object? defectCodes = freezed,
    Object? materialCodes = freezed,
    Object? colorCodes = freezed,
    Object? statusCode = null,
    Object? otherMaterial = freezed,
    Object? otherDefectNote = freezed,
    Object? caption = freezed,
    Object? media = null,
    Object? tags = null,
  }) {
    return _then(
      _$UploadPostPayloadImpl(
        hasProduct: null == hasProduct
            ? _value.hasProduct
            : hasProduct // ignore: cast_nullable_to_non_nullable
                  as bool,
        productTitle: freezed == productTitle
            ? _value.productTitle
            : productTitle // ignore: cast_nullable_to_non_nullable
                  as String?,
        productDescription: freezed == productDescription
            ? _value.productDescription
            : productDescription // ignore: cast_nullable_to_non_nullable
                  as String?,
        productPrice: freezed == productPrice
            ? _value.productPrice
            : productPrice // ignore: cast_nullable_to_non_nullable
                  as double?,
        categoryId: freezed == categoryId
            ? _value.categoryId
            : categoryId // ignore: cast_nullable_to_non_nullable
                  as String?,
        chest: freezed == chest
            ? _value.chest
            : chest // ignore: cast_nullable_to_non_nullable
                  as double?,
        waist: freezed == waist
            ? _value.waist
            : waist // ignore: cast_nullable_to_non_nullable
                  as double?,
        length: freezed == length
            ? _value.length
            : length // ignore: cast_nullable_to_non_nullable
                  as double?,
        sleeveLength: freezed == sleeveLength
            ? _value.sleeveLength
            : sleeveLength // ignore: cast_nullable_to_non_nullable
                  as double?,
        shoulderWidth: freezed == shoulderWidth
            ? _value.shoulderWidth
            : shoulderWidth // ignore: cast_nullable_to_non_nullable
                  as double?,
        brand: freezed == brand
            ? _value.brand
            : brand // ignore: cast_nullable_to_non_nullable
                  as String?,
        size: freezed == size
            ? _value.size
            : size // ignore: cast_nullable_to_non_nullable
                  as String?,
        material: freezed == material
            ? _value.material
            : material // ignore: cast_nullable_to_non_nullable
                  as String?,
        condition: freezed == condition
            ? _value.condition
            : condition // ignore: cast_nullable_to_non_nullable
                  as String?,
        conditionCode: freezed == conditionCode
            ? _value.conditionCode
            : conditionCode // ignore: cast_nullable_to_non_nullable
                  as String?,
        defectCodes: freezed == defectCodes
            ? _value._defectCodes
            : defectCodes // ignore: cast_nullable_to_non_nullable
                  as List<String>?,
        materialCodes: freezed == materialCodes
            ? _value._materialCodes
            : materialCodes // ignore: cast_nullable_to_non_nullable
                  as List<String>?,
        colorCodes: freezed == colorCodes
            ? _value._colorCodes
            : colorCodes // ignore: cast_nullable_to_non_nullable
                  as List<String>?,
        statusCode: null == statusCode
            ? _value.statusCode
            : statusCode // ignore: cast_nullable_to_non_nullable
                  as String,
        otherMaterial: freezed == otherMaterial
            ? _value.otherMaterial
            : otherMaterial // ignore: cast_nullable_to_non_nullable
                  as String?,
        otherDefectNote: freezed == otherDefectNote
            ? _value.otherDefectNote
            : otherDefectNote // ignore: cast_nullable_to_non_nullable
                  as String?,
        caption: freezed == caption
            ? _value.caption
            : caption // ignore: cast_nullable_to_non_nullable
                  as String?,
        media: null == media
            ? _value._media
            : media // ignore: cast_nullable_to_non_nullable
                  as List<UploadableMedia>,
        tags: null == tags
            ? _value._tags
            : tags // ignore: cast_nullable_to_non_nullable
                  as List<TagEntity>,
      ),
    );
  }
}

/// @nodoc

class _$UploadPostPayloadImpl implements _UploadPostPayload {
  const _$UploadPostPayloadImpl({
    required this.hasProduct,
    this.productTitle,
    this.productDescription,
    this.productPrice,
    this.categoryId,
    this.chest,
    this.waist,
    this.length,
    this.sleeveLength,
    this.shoulderWidth,
    this.brand,
    this.size,
    this.material,
    this.condition,
    this.conditionCode,
    final List<String>? defectCodes,
    final List<String>? materialCodes,
    final List<String>? colorCodes,
    required this.statusCode,
    this.otherMaterial,
    this.otherDefectNote,
    this.caption,
    required final List<UploadableMedia> media,
    required final List<TagEntity> tags,
  }) : _defectCodes = defectCodes,
       _materialCodes = materialCodes,
       _colorCodes = colorCodes,
       _media = media,
       _tags = tags;

  // Controls if we create a product or just a post
  @override
  final bool hasProduct;
  // --- Product basics ---
  @override
  final String? productTitle;
  @override
  final String? productDescription;
  @override
  final double? productPrice;
  @override
  final String? categoryId;
  // --- Measurements ---
  @override
  final double? chest;
  @override
  final double? waist;
  @override
  final double? length;
  @override
  final double? sleeveLength;
  @override
  final double? shoulderWidth;
  // --- Brand / Size ---
  @override
  final String? brand;
  @override
  final String? size;
  // --- Legacy display strings (kept so UI doesn’t break) ---
  @override
  final String? material;
  @override
  final String? condition;
  // --- Schema-aligned codes (persist these) ---
  @override
  final String? conditionCode;
  // 'never_worn' | 'as_new' | 'good' | 'fair'
  final List<String>? _defectCodes;
  // 'never_worn' | 'as_new' | 'good' | 'fair'
  @override
  List<String>? get defectCodes {
    final value = _defectCodes;
    if (value == null) return null;
    if (_defectCodes is EqualUnmodifiableListView) return _defectCodes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  // product_defects.defect_code
  final List<String>? _materialCodes;
  // product_defects.defect_code
  @override
  List<String>? get materialCodes {
    final value = _materialCodes;
    if (value == null) return null;
    if (_materialCodes is EqualUnmodifiableListView) return _materialCodes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  // product_materials.material_code
  final List<String>? _colorCodes;
  // product_materials.material_code
  @override
  List<String>? get colorCodes {
    final value = _colorCodes;
    if (value == null) return null;
    if (_colorCodes is EqualUnmodifiableListView) return _colorCodes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  // product_colors.color_code
  @override
  final String statusCode;
  @override
  final String? otherMaterial;
  @override
  final String? otherDefectNote;
  // --- Post ---
  @override
  final String? caption;
  // --- Media & Tags ---
  final List<UploadableMedia> _media;
  // --- Media & Tags ---
  @override
  List<UploadableMedia> get media {
    if (_media is EqualUnmodifiableListView) return _media;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_media);
  }

  final List<TagEntity> _tags;
  @override
  List<TagEntity> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  @override
  String toString() {
    return 'UploadPostPayload(hasProduct: $hasProduct, productTitle: $productTitle, productDescription: $productDescription, productPrice: $productPrice, categoryId: $categoryId, chest: $chest, waist: $waist, length: $length, sleeveLength: $sleeveLength, shoulderWidth: $shoulderWidth, brand: $brand, size: $size, material: $material, condition: $condition, conditionCode: $conditionCode, defectCodes: $defectCodes, materialCodes: $materialCodes, colorCodes: $colorCodes, statusCode: $statusCode, otherMaterial: $otherMaterial, otherDefectNote: $otherDefectNote, caption: $caption, media: $media, tags: $tags)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UploadPostPayloadImpl &&
            (identical(other.hasProduct, hasProduct) ||
                other.hasProduct == hasProduct) &&
            (identical(other.productTitle, productTitle) ||
                other.productTitle == productTitle) &&
            (identical(other.productDescription, productDescription) ||
                other.productDescription == productDescription) &&
            (identical(other.productPrice, productPrice) ||
                other.productPrice == productPrice) &&
            (identical(other.categoryId, categoryId) ||
                other.categoryId == categoryId) &&
            (identical(other.chest, chest) || other.chest == chest) &&
            (identical(other.waist, waist) || other.waist == waist) &&
            (identical(other.length, length) || other.length == length) &&
            (identical(other.sleeveLength, sleeveLength) ||
                other.sleeveLength == sleeveLength) &&
            (identical(other.shoulderWidth, shoulderWidth) ||
                other.shoulderWidth == shoulderWidth) &&
            (identical(other.brand, brand) || other.brand == brand) &&
            (identical(other.size, size) || other.size == size) &&
            (identical(other.material, material) ||
                other.material == material) &&
            (identical(other.condition, condition) ||
                other.condition == condition) &&
            (identical(other.conditionCode, conditionCode) ||
                other.conditionCode == conditionCode) &&
            const DeepCollectionEquality().equals(
              other._defectCodes,
              _defectCodes,
            ) &&
            const DeepCollectionEquality().equals(
              other._materialCodes,
              _materialCodes,
            ) &&
            const DeepCollectionEquality().equals(
              other._colorCodes,
              _colorCodes,
            ) &&
            (identical(other.statusCode, statusCode) ||
                other.statusCode == statusCode) &&
            (identical(other.otherMaterial, otherMaterial) ||
                other.otherMaterial == otherMaterial) &&
            (identical(other.otherDefectNote, otherDefectNote) ||
                other.otherDefectNote == otherDefectNote) &&
            (identical(other.caption, caption) || other.caption == caption) &&
            const DeepCollectionEquality().equals(other._media, _media) &&
            const DeepCollectionEquality().equals(other._tags, _tags));
  }

  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    hasProduct,
    productTitle,
    productDescription,
    productPrice,
    categoryId,
    chest,
    waist,
    length,
    sleeveLength,
    shoulderWidth,
    brand,
    size,
    material,
    condition,
    conditionCode,
    const DeepCollectionEquality().hash(_defectCodes),
    const DeepCollectionEquality().hash(_materialCodes),
    const DeepCollectionEquality().hash(_colorCodes),
    statusCode,
    otherMaterial,
    otherDefectNote,
    caption,
    const DeepCollectionEquality().hash(_media),
    const DeepCollectionEquality().hash(_tags),
  ]);

  /// Create a copy of UploadPostPayload
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UploadPostPayloadImplCopyWith<_$UploadPostPayloadImpl> get copyWith =>
      __$$UploadPostPayloadImplCopyWithImpl<_$UploadPostPayloadImpl>(
        this,
        _$identity,
      );
}

abstract class _UploadPostPayload implements UploadPostPayload {
  const factory _UploadPostPayload({
    required final bool hasProduct,
    final String? productTitle,
    final String? productDescription,
    final double? productPrice,
    final String? categoryId,
    final double? chest,
    final double? waist,
    final double? length,
    final double? sleeveLength,
    final double? shoulderWidth,
    final String? brand,
    final String? size,
    final String? material,
    final String? condition,
    final String? conditionCode,
    final List<String>? defectCodes,
    final List<String>? materialCodes,
    final List<String>? colorCodes,
    required final String statusCode,
    final String? otherMaterial,
    final String? otherDefectNote,
    final String? caption,
    required final List<UploadableMedia> media,
    required final List<TagEntity> tags,
  }) = _$UploadPostPayloadImpl;

  // Controls if we create a product or just a post
  @override
  bool get hasProduct; // --- Product basics ---
  @override
  String? get productTitle;
  @override
  String? get productDescription;
  @override
  double? get productPrice;
  @override
  String? get categoryId; // --- Measurements ---
  @override
  double? get chest;
  @override
  double? get waist;
  @override
  double? get length;
  @override
  double? get sleeveLength;
  @override
  double? get shoulderWidth; // --- Brand / Size ---
  @override
  String? get brand;
  @override
  String? get size; // --- Legacy display strings (kept so UI doesn’t break) ---
  @override
  String? get material;
  @override
  String? get condition; // --- Schema-aligned codes (persist these) ---
  @override
  String? get conditionCode; // 'never_worn' | 'as_new' | 'good' | 'fair'
  @override
  List<String>? get defectCodes; // product_defects.defect_code
  @override
  List<String>? get materialCodes; // product_materials.material_code
  @override
  List<String>? get colorCodes; // product_colors.color_code
  @override
  String get statusCode;
  @override
  String? get otherMaterial;
  @override
  String? get otherDefectNote; // --- Post ---
  @override
  String? get caption; // --- Media & Tags ---
  @override
  List<UploadableMedia> get media;
  @override
  List<TagEntity> get tags;

  /// Create a copy of UploadPostPayload
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UploadPostPayloadImplCopyWith<_$UploadPostPayloadImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

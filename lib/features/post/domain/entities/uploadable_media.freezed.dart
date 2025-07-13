// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'uploadable_media.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$UploadableMedia {
  MediaFile get media => throw _privateConstructorUsedError;
  UploadMediaStatus get status => throw _privateConstructorUsedError;
  File? get file => throw _privateConstructorUsedError; //direct access to file
  String? get errorMessage => throw _privateConstructorUsedError;

  /// Create a copy of UploadableMedia
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UploadableMediaCopyWith<UploadableMedia> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UploadableMediaCopyWith<$Res> {
  factory $UploadableMediaCopyWith(
    UploadableMedia value,
    $Res Function(UploadableMedia) then,
  ) = _$UploadableMediaCopyWithImpl<$Res, UploadableMedia>;
  @useResult
  $Res call({
    MediaFile media,
    UploadMediaStatus status,
    File? file,
    String? errorMessage,
  });
}

/// @nodoc
class _$UploadableMediaCopyWithImpl<$Res, $Val extends UploadableMedia>
    implements $UploadableMediaCopyWith<$Res> {
  _$UploadableMediaCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UploadableMedia
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? media = null,
    Object? status = null,
    Object? file = freezed,
    Object? errorMessage = freezed,
  }) {
    return _then(
      _value.copyWith(
            media: null == media
                ? _value.media
                : media // ignore: cast_nullable_to_non_nullable
                      as MediaFile,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as UploadMediaStatus,
            file: freezed == file
                ? _value.file
                : file // ignore: cast_nullable_to_non_nullable
                      as File?,
            errorMessage: freezed == errorMessage
                ? _value.errorMessage
                : errorMessage // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UploadableMediaImplCopyWith<$Res>
    implements $UploadableMediaCopyWith<$Res> {
  factory _$$UploadableMediaImplCopyWith(
    _$UploadableMediaImpl value,
    $Res Function(_$UploadableMediaImpl) then,
  ) = __$$UploadableMediaImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    MediaFile media,
    UploadMediaStatus status,
    File? file,
    String? errorMessage,
  });
}

/// @nodoc
class __$$UploadableMediaImplCopyWithImpl<$Res>
    extends _$UploadableMediaCopyWithImpl<$Res, _$UploadableMediaImpl>
    implements _$$UploadableMediaImplCopyWith<$Res> {
  __$$UploadableMediaImplCopyWithImpl(
    _$UploadableMediaImpl _value,
    $Res Function(_$UploadableMediaImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UploadableMedia
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? media = null,
    Object? status = null,
    Object? file = freezed,
    Object? errorMessage = freezed,
  }) {
    return _then(
      _$UploadableMediaImpl(
        media: null == media
            ? _value.media
            : media // ignore: cast_nullable_to_non_nullable
                  as MediaFile,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as UploadMediaStatus,
        file: freezed == file
            ? _value.file
            : file // ignore: cast_nullable_to_non_nullable
                  as File?,
        errorMessage: freezed == errorMessage
            ? _value.errorMessage
            : errorMessage // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$UploadableMediaImpl implements _UploadableMedia {
  const _$UploadableMediaImpl({
    required this.media,
    required this.status,
    this.file,
    this.errorMessage,
  });

  @override
  final MediaFile media;
  @override
  final UploadMediaStatus status;
  @override
  final File? file;
  //direct access to file
  @override
  final String? errorMessage;

  @override
  String toString() {
    return 'UploadableMedia(media: $media, status: $status, file: $file, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UploadableMediaImpl &&
            (identical(other.media, media) || other.media == media) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.file, file) || other.file == file) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, media, status, file, errorMessage);

  /// Create a copy of UploadableMedia
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UploadableMediaImplCopyWith<_$UploadableMediaImpl> get copyWith =>
      __$$UploadableMediaImplCopyWithImpl<_$UploadableMediaImpl>(
        this,
        _$identity,
      );
}

abstract class _UploadableMedia implements UploadableMedia {
  const factory _UploadableMedia({
    required final MediaFile media,
    required final UploadMediaStatus status,
    final File? file,
    final String? errorMessage,
  }) = _$UploadableMediaImpl;

  @override
  MediaFile get media;
  @override
  UploadMediaStatus get status;
  @override
  File? get file; //direct access to file
  @override
  String? get errorMessage;

  /// Create a copy of UploadableMedia
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UploadableMediaImplCopyWith<_$UploadableMediaImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

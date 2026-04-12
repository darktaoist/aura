// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reading.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Reading _$ReadingFromJson(Map<String, dynamic> json) {
  return _Reading.fromJson(json);
}

/// @nodoc
mixin _$Reading {
  String get id => throw _privateConstructorUsedError;
  String? get userId => throw _privateConstructorUsedError;
  ReadingType get type => throw _privateConstructorUsedError;
  String? get imagePath => throw _privateConstructorUsedError;
  Map<String, dynamic> get landmarks => throw _privateConstructorUsedError;
  Map<String, dynamic>? get features => throw _privateConstructorUsedError;
  String get resultText => throw _privateConstructorUsedError;
  String? get modelUsed => throw _privateConstructorUsedError;
  String? get locale => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this Reading to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Reading
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReadingCopyWith<Reading> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReadingCopyWith<$Res> {
  factory $ReadingCopyWith(Reading value, $Res Function(Reading) then) =
      _$ReadingCopyWithImpl<$Res, Reading>;
  @useResult
  $Res call({
    String id,
    String? userId,
    ReadingType type,
    String? imagePath,
    Map<String, dynamic> landmarks,
    Map<String, dynamic>? features,
    String resultText,
    String? modelUsed,
    String? locale,
    DateTime createdAt,
  });
}

/// @nodoc
class _$ReadingCopyWithImpl<$Res, $Val extends Reading>
    implements $ReadingCopyWith<$Res> {
  _$ReadingCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Reading
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = freezed,
    Object? type = null,
    Object? imagePath = freezed,
    Object? landmarks = null,
    Object? features = freezed,
    Object? resultText = null,
    Object? modelUsed = freezed,
    Object? locale = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            userId: freezed == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String?,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as ReadingType,
            imagePath: freezed == imagePath
                ? _value.imagePath
                : imagePath // ignore: cast_nullable_to_non_nullable
                      as String?,
            landmarks: null == landmarks
                ? _value.landmarks
                : landmarks // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>,
            features: freezed == features
                ? _value.features
                : features // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
            resultText: null == resultText
                ? _value.resultText
                : resultText // ignore: cast_nullable_to_non_nullable
                      as String,
            modelUsed: freezed == modelUsed
                ? _value.modelUsed
                : modelUsed // ignore: cast_nullable_to_non_nullable
                      as String?,
            locale: freezed == locale
                ? _value.locale
                : locale // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ReadingImplCopyWith<$Res> implements $ReadingCopyWith<$Res> {
  factory _$$ReadingImplCopyWith(
    _$ReadingImpl value,
    $Res Function(_$ReadingImpl) then,
  ) = __$$ReadingImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String? userId,
    ReadingType type,
    String? imagePath,
    Map<String, dynamic> landmarks,
    Map<String, dynamic>? features,
    String resultText,
    String? modelUsed,
    String? locale,
    DateTime createdAt,
  });
}

/// @nodoc
class __$$ReadingImplCopyWithImpl<$Res>
    extends _$ReadingCopyWithImpl<$Res, _$ReadingImpl>
    implements _$$ReadingImplCopyWith<$Res> {
  __$$ReadingImplCopyWithImpl(
    _$ReadingImpl _value,
    $Res Function(_$ReadingImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Reading
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = freezed,
    Object? type = null,
    Object? imagePath = freezed,
    Object? landmarks = null,
    Object? features = freezed,
    Object? resultText = null,
    Object? modelUsed = freezed,
    Object? locale = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _$ReadingImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: freezed == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String?,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as ReadingType,
        imagePath: freezed == imagePath
            ? _value.imagePath
            : imagePath // ignore: cast_nullable_to_non_nullable
                  as String?,
        landmarks: null == landmarks
            ? _value._landmarks
            : landmarks // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>,
        features: freezed == features
            ? _value._features
            : features // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
        resultText: null == resultText
            ? _value.resultText
            : resultText // ignore: cast_nullable_to_non_nullable
                  as String,
        modelUsed: freezed == modelUsed
            ? _value.modelUsed
            : modelUsed // ignore: cast_nullable_to_non_nullable
                  as String?,
        locale: freezed == locale
            ? _value.locale
            : locale // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ReadingImpl implements _Reading {
  const _$ReadingImpl({
    required this.id,
    this.userId,
    required this.type,
    this.imagePath,
    required final Map<String, dynamic> landmarks,
    final Map<String, dynamic>? features,
    required this.resultText,
    this.modelUsed,
    this.locale,
    required this.createdAt,
  }) : _landmarks = landmarks,
       _features = features;

  factory _$ReadingImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReadingImplFromJson(json);

  @override
  final String id;
  @override
  final String? userId;
  @override
  final ReadingType type;
  @override
  final String? imagePath;
  final Map<String, dynamic> _landmarks;
  @override
  Map<String, dynamic> get landmarks {
    if (_landmarks is EqualUnmodifiableMapView) return _landmarks;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_landmarks);
  }

  final Map<String, dynamic>? _features;
  @override
  Map<String, dynamic>? get features {
    final value = _features;
    if (value == null) return null;
    if (_features is EqualUnmodifiableMapView) return _features;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final String resultText;
  @override
  final String? modelUsed;
  @override
  final String? locale;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'Reading(id: $id, userId: $userId, type: $type, imagePath: $imagePath, landmarks: $landmarks, features: $features, resultText: $resultText, modelUsed: $modelUsed, locale: $locale, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReadingImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.imagePath, imagePath) ||
                other.imagePath == imagePath) &&
            const DeepCollectionEquality().equals(
              other._landmarks,
              _landmarks,
            ) &&
            const DeepCollectionEquality().equals(other._features, _features) &&
            (identical(other.resultText, resultText) ||
                other.resultText == resultText) &&
            (identical(other.modelUsed, modelUsed) ||
                other.modelUsed == modelUsed) &&
            (identical(other.locale, locale) || other.locale == locale) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    userId,
    type,
    imagePath,
    const DeepCollectionEquality().hash(_landmarks),
    const DeepCollectionEquality().hash(_features),
    resultText,
    modelUsed,
    locale,
    createdAt,
  );

  /// Create a copy of Reading
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReadingImplCopyWith<_$ReadingImpl> get copyWith =>
      __$$ReadingImplCopyWithImpl<_$ReadingImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReadingImplToJson(this);
  }
}

abstract class _Reading implements Reading {
  const factory _Reading({
    required final String id,
    final String? userId,
    required final ReadingType type,
    final String? imagePath,
    required final Map<String, dynamic> landmarks,
    final Map<String, dynamic>? features,
    required final String resultText,
    final String? modelUsed,
    final String? locale,
    required final DateTime createdAt,
  }) = _$ReadingImpl;

  factory _Reading.fromJson(Map<String, dynamic> json) = _$ReadingImpl.fromJson;

  @override
  String get id;
  @override
  String? get userId;
  @override
  ReadingType get type;
  @override
  String? get imagePath;
  @override
  Map<String, dynamic> get landmarks;
  @override
  Map<String, dynamic>? get features;
  @override
  String get resultText;
  @override
  String? get modelUsed;
  @override
  String? get locale;
  @override
  DateTime get createdAt;

  /// Create a copy of Reading
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReadingImplCopyWith<_$ReadingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

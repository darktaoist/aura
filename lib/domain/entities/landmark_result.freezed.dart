// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'landmark_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

LandmarkPoint _$LandmarkPointFromJson(Map<String, dynamic> json) {
  return _LandmarkPoint.fromJson(json);
}

/// @nodoc
mixin _$LandmarkPoint {
  double get x => throw _privateConstructorUsedError;
  double get y => throw _privateConstructorUsedError;
  double get z => throw _privateConstructorUsedError;

  /// Serializes this LandmarkPoint to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LandmarkPoint
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LandmarkPointCopyWith<LandmarkPoint> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LandmarkPointCopyWith<$Res> {
  factory $LandmarkPointCopyWith(
    LandmarkPoint value,
    $Res Function(LandmarkPoint) then,
  ) = _$LandmarkPointCopyWithImpl<$Res, LandmarkPoint>;
  @useResult
  $Res call({double x, double y, double z});
}

/// @nodoc
class _$LandmarkPointCopyWithImpl<$Res, $Val extends LandmarkPoint>
    implements $LandmarkPointCopyWith<$Res> {
  _$LandmarkPointCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LandmarkPoint
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? x = null, Object? y = null, Object? z = null}) {
    return _then(
      _value.copyWith(
            x: null == x
                ? _value.x
                : x // ignore: cast_nullable_to_non_nullable
                      as double,
            y: null == y
                ? _value.y
                : y // ignore: cast_nullable_to_non_nullable
                      as double,
            z: null == z
                ? _value.z
                : z // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$LandmarkPointImplCopyWith<$Res>
    implements $LandmarkPointCopyWith<$Res> {
  factory _$$LandmarkPointImplCopyWith(
    _$LandmarkPointImpl value,
    $Res Function(_$LandmarkPointImpl) then,
  ) = __$$LandmarkPointImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({double x, double y, double z});
}

/// @nodoc
class __$$LandmarkPointImplCopyWithImpl<$Res>
    extends _$LandmarkPointCopyWithImpl<$Res, _$LandmarkPointImpl>
    implements _$$LandmarkPointImplCopyWith<$Res> {
  __$$LandmarkPointImplCopyWithImpl(
    _$LandmarkPointImpl _value,
    $Res Function(_$LandmarkPointImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LandmarkPoint
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? x = null, Object? y = null, Object? z = null}) {
    return _then(
      _$LandmarkPointImpl(
        x: null == x
            ? _value.x
            : x // ignore: cast_nullable_to_non_nullable
                  as double,
        y: null == y
            ? _value.y
            : y // ignore: cast_nullable_to_non_nullable
                  as double,
        z: null == z
            ? _value.z
            : z // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$LandmarkPointImpl implements _LandmarkPoint {
  const _$LandmarkPointImpl({required this.x, required this.y, this.z = 0.0});

  factory _$LandmarkPointImpl.fromJson(Map<String, dynamic> json) =>
      _$$LandmarkPointImplFromJson(json);

  @override
  final double x;
  @override
  final double y;
  @override
  @JsonKey()
  final double z;

  @override
  String toString() {
    return 'LandmarkPoint(x: $x, y: $y, z: $z)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LandmarkPointImpl &&
            (identical(other.x, x) || other.x == x) &&
            (identical(other.y, y) || other.y == y) &&
            (identical(other.z, z) || other.z == z));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, x, y, z);

  /// Create a copy of LandmarkPoint
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LandmarkPointImplCopyWith<_$LandmarkPointImpl> get copyWith =>
      __$$LandmarkPointImplCopyWithImpl<_$LandmarkPointImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LandmarkPointImplToJson(this);
  }
}

abstract class _LandmarkPoint implements LandmarkPoint {
  const factory _LandmarkPoint({
    required final double x,
    required final double y,
    final double z,
  }) = _$LandmarkPointImpl;

  factory _LandmarkPoint.fromJson(Map<String, dynamic> json) =
      _$LandmarkPointImpl.fromJson;

  @override
  double get x;
  @override
  double get y;
  @override
  double get z;

  /// Create a copy of LandmarkPoint
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LandmarkPointImplCopyWith<_$LandmarkPointImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

FaceFeatures _$FaceFeaturesFromJson(Map<String, dynamic> json) {
  return _FaceFeatures.fromJson(json);
}

/// @nodoc
mixin _$FaceFeatures {
  double get eyeSpan => throw _privateConstructorUsedError;
  double get faceHeight => throw _privateConstructorUsedError;
  double get noseRatio => throw _privateConstructorUsedError;
  double get mouthWidth => throw _privateConstructorUsedError;
  double get symmetry => throw _privateConstructorUsedError;
  double get foreheadHeight => throw _privateConstructorUsedError;
  double get eyebrowDistance => throw _privateConstructorUsedError;

  /// Serializes this FaceFeatures to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FaceFeatures
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FaceFeaturesCopyWith<FaceFeatures> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FaceFeaturesCopyWith<$Res> {
  factory $FaceFeaturesCopyWith(
    FaceFeatures value,
    $Res Function(FaceFeatures) then,
  ) = _$FaceFeaturesCopyWithImpl<$Res, FaceFeatures>;
  @useResult
  $Res call({
    double eyeSpan,
    double faceHeight,
    double noseRatio,
    double mouthWidth,
    double symmetry,
    double foreheadHeight,
    double eyebrowDistance,
  });
}

/// @nodoc
class _$FaceFeaturesCopyWithImpl<$Res, $Val extends FaceFeatures>
    implements $FaceFeaturesCopyWith<$Res> {
  _$FaceFeaturesCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FaceFeatures
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? eyeSpan = null,
    Object? faceHeight = null,
    Object? noseRatio = null,
    Object? mouthWidth = null,
    Object? symmetry = null,
    Object? foreheadHeight = null,
    Object? eyebrowDistance = null,
  }) {
    return _then(
      _value.copyWith(
            eyeSpan: null == eyeSpan
                ? _value.eyeSpan
                : eyeSpan // ignore: cast_nullable_to_non_nullable
                      as double,
            faceHeight: null == faceHeight
                ? _value.faceHeight
                : faceHeight // ignore: cast_nullable_to_non_nullable
                      as double,
            noseRatio: null == noseRatio
                ? _value.noseRatio
                : noseRatio // ignore: cast_nullable_to_non_nullable
                      as double,
            mouthWidth: null == mouthWidth
                ? _value.mouthWidth
                : mouthWidth // ignore: cast_nullable_to_non_nullable
                      as double,
            symmetry: null == symmetry
                ? _value.symmetry
                : symmetry // ignore: cast_nullable_to_non_nullable
                      as double,
            foreheadHeight: null == foreheadHeight
                ? _value.foreheadHeight
                : foreheadHeight // ignore: cast_nullable_to_non_nullable
                      as double,
            eyebrowDistance: null == eyebrowDistance
                ? _value.eyebrowDistance
                : eyebrowDistance // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$FaceFeaturesImplCopyWith<$Res>
    implements $FaceFeaturesCopyWith<$Res> {
  factory _$$FaceFeaturesImplCopyWith(
    _$FaceFeaturesImpl value,
    $Res Function(_$FaceFeaturesImpl) then,
  ) = __$$FaceFeaturesImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    double eyeSpan,
    double faceHeight,
    double noseRatio,
    double mouthWidth,
    double symmetry,
    double foreheadHeight,
    double eyebrowDistance,
  });
}

/// @nodoc
class __$$FaceFeaturesImplCopyWithImpl<$Res>
    extends _$FaceFeaturesCopyWithImpl<$Res, _$FaceFeaturesImpl>
    implements _$$FaceFeaturesImplCopyWith<$Res> {
  __$$FaceFeaturesImplCopyWithImpl(
    _$FaceFeaturesImpl _value,
    $Res Function(_$FaceFeaturesImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FaceFeatures
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? eyeSpan = null,
    Object? faceHeight = null,
    Object? noseRatio = null,
    Object? mouthWidth = null,
    Object? symmetry = null,
    Object? foreheadHeight = null,
    Object? eyebrowDistance = null,
  }) {
    return _then(
      _$FaceFeaturesImpl(
        eyeSpan: null == eyeSpan
            ? _value.eyeSpan
            : eyeSpan // ignore: cast_nullable_to_non_nullable
                  as double,
        faceHeight: null == faceHeight
            ? _value.faceHeight
            : faceHeight // ignore: cast_nullable_to_non_nullable
                  as double,
        noseRatio: null == noseRatio
            ? _value.noseRatio
            : noseRatio // ignore: cast_nullable_to_non_nullable
                  as double,
        mouthWidth: null == mouthWidth
            ? _value.mouthWidth
            : mouthWidth // ignore: cast_nullable_to_non_nullable
                  as double,
        symmetry: null == symmetry
            ? _value.symmetry
            : symmetry // ignore: cast_nullable_to_non_nullable
                  as double,
        foreheadHeight: null == foreheadHeight
            ? _value.foreheadHeight
            : foreheadHeight // ignore: cast_nullable_to_non_nullable
                  as double,
        eyebrowDistance: null == eyebrowDistance
            ? _value.eyebrowDistance
            : eyebrowDistance // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$FaceFeaturesImpl implements _FaceFeatures {
  const _$FaceFeaturesImpl({
    required this.eyeSpan,
    required this.faceHeight,
    required this.noseRatio,
    required this.mouthWidth,
    required this.symmetry,
    required this.foreheadHeight,
    required this.eyebrowDistance,
  });

  factory _$FaceFeaturesImpl.fromJson(Map<String, dynamic> json) =>
      _$$FaceFeaturesImplFromJson(json);

  @override
  final double eyeSpan;
  @override
  final double faceHeight;
  @override
  final double noseRatio;
  @override
  final double mouthWidth;
  @override
  final double symmetry;
  @override
  final double foreheadHeight;
  @override
  final double eyebrowDistance;

  @override
  String toString() {
    return 'FaceFeatures(eyeSpan: $eyeSpan, faceHeight: $faceHeight, noseRatio: $noseRatio, mouthWidth: $mouthWidth, symmetry: $symmetry, foreheadHeight: $foreheadHeight, eyebrowDistance: $eyebrowDistance)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FaceFeaturesImpl &&
            (identical(other.eyeSpan, eyeSpan) || other.eyeSpan == eyeSpan) &&
            (identical(other.faceHeight, faceHeight) ||
                other.faceHeight == faceHeight) &&
            (identical(other.noseRatio, noseRatio) ||
                other.noseRatio == noseRatio) &&
            (identical(other.mouthWidth, mouthWidth) ||
                other.mouthWidth == mouthWidth) &&
            (identical(other.symmetry, symmetry) ||
                other.symmetry == symmetry) &&
            (identical(other.foreheadHeight, foreheadHeight) ||
                other.foreheadHeight == foreheadHeight) &&
            (identical(other.eyebrowDistance, eyebrowDistance) ||
                other.eyebrowDistance == eyebrowDistance));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    eyeSpan,
    faceHeight,
    noseRatio,
    mouthWidth,
    symmetry,
    foreheadHeight,
    eyebrowDistance,
  );

  /// Create a copy of FaceFeatures
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FaceFeaturesImplCopyWith<_$FaceFeaturesImpl> get copyWith =>
      __$$FaceFeaturesImplCopyWithImpl<_$FaceFeaturesImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FaceFeaturesImplToJson(this);
  }
}

abstract class _FaceFeatures implements FaceFeatures {
  const factory _FaceFeatures({
    required final double eyeSpan,
    required final double faceHeight,
    required final double noseRatio,
    required final double mouthWidth,
    required final double symmetry,
    required final double foreheadHeight,
    required final double eyebrowDistance,
  }) = _$FaceFeaturesImpl;

  factory _FaceFeatures.fromJson(Map<String, dynamic> json) =
      _$FaceFeaturesImpl.fromJson;

  @override
  double get eyeSpan;
  @override
  double get faceHeight;
  @override
  double get noseRatio;
  @override
  double get mouthWidth;
  @override
  double get symmetry;
  @override
  double get foreheadHeight;
  @override
  double get eyebrowDistance;

  /// Create a copy of FaceFeatures
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FaceFeaturesImplCopyWith<_$FaceFeaturesImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

FaceLandmarkResult _$FaceLandmarkResultFromJson(Map<String, dynamic> json) {
  return _FaceLandmarkResult.fromJson(json);
}

/// @nodoc
mixin _$FaceLandmarkResult {
  List<LandmarkPoint> get landmarks => throw _privateConstructorUsedError;
  double get score => throw _privateConstructorUsedError;
  FaceFeatures get features => throw _privateConstructorUsedError;
  int get frameWidth => throw _privateConstructorUsedError;
  int get frameHeight => throw _privateConstructorUsedError;

  /// Serializes this FaceLandmarkResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FaceLandmarkResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FaceLandmarkResultCopyWith<FaceLandmarkResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FaceLandmarkResultCopyWith<$Res> {
  factory $FaceLandmarkResultCopyWith(
    FaceLandmarkResult value,
    $Res Function(FaceLandmarkResult) then,
  ) = _$FaceLandmarkResultCopyWithImpl<$Res, FaceLandmarkResult>;
  @useResult
  $Res call({
    List<LandmarkPoint> landmarks,
    double score,
    FaceFeatures features,
    int frameWidth,
    int frameHeight,
  });

  $FaceFeaturesCopyWith<$Res> get features;
}

/// @nodoc
class _$FaceLandmarkResultCopyWithImpl<$Res, $Val extends FaceLandmarkResult>
    implements $FaceLandmarkResultCopyWith<$Res> {
  _$FaceLandmarkResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FaceLandmarkResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? landmarks = null,
    Object? score = null,
    Object? features = null,
    Object? frameWidth = null,
    Object? frameHeight = null,
  }) {
    return _then(
      _value.copyWith(
            landmarks: null == landmarks
                ? _value.landmarks
                : landmarks // ignore: cast_nullable_to_non_nullable
                      as List<LandmarkPoint>,
            score: null == score
                ? _value.score
                : score // ignore: cast_nullable_to_non_nullable
                      as double,
            features: null == features
                ? _value.features
                : features // ignore: cast_nullable_to_non_nullable
                      as FaceFeatures,
            frameWidth: null == frameWidth
                ? _value.frameWidth
                : frameWidth // ignore: cast_nullable_to_non_nullable
                      as int,
            frameHeight: null == frameHeight
                ? _value.frameHeight
                : frameHeight // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }

  /// Create a copy of FaceLandmarkResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $FaceFeaturesCopyWith<$Res> get features {
    return $FaceFeaturesCopyWith<$Res>(_value.features, (value) {
      return _then(_value.copyWith(features: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$FaceLandmarkResultImplCopyWith<$Res>
    implements $FaceLandmarkResultCopyWith<$Res> {
  factory _$$FaceLandmarkResultImplCopyWith(
    _$FaceLandmarkResultImpl value,
    $Res Function(_$FaceLandmarkResultImpl) then,
  ) = __$$FaceLandmarkResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<LandmarkPoint> landmarks,
    double score,
    FaceFeatures features,
    int frameWidth,
    int frameHeight,
  });

  @override
  $FaceFeaturesCopyWith<$Res> get features;
}

/// @nodoc
class __$$FaceLandmarkResultImplCopyWithImpl<$Res>
    extends _$FaceLandmarkResultCopyWithImpl<$Res, _$FaceLandmarkResultImpl>
    implements _$$FaceLandmarkResultImplCopyWith<$Res> {
  __$$FaceLandmarkResultImplCopyWithImpl(
    _$FaceLandmarkResultImpl _value,
    $Res Function(_$FaceLandmarkResultImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FaceLandmarkResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? landmarks = null,
    Object? score = null,
    Object? features = null,
    Object? frameWidth = null,
    Object? frameHeight = null,
  }) {
    return _then(
      _$FaceLandmarkResultImpl(
        landmarks: null == landmarks
            ? _value._landmarks
            : landmarks // ignore: cast_nullable_to_non_nullable
                  as List<LandmarkPoint>,
        score: null == score
            ? _value.score
            : score // ignore: cast_nullable_to_non_nullable
                  as double,
        features: null == features
            ? _value.features
            : features // ignore: cast_nullable_to_non_nullable
                  as FaceFeatures,
        frameWidth: null == frameWidth
            ? _value.frameWidth
            : frameWidth // ignore: cast_nullable_to_non_nullable
                  as int,
        frameHeight: null == frameHeight
            ? _value.frameHeight
            : frameHeight // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$FaceLandmarkResultImpl implements _FaceLandmarkResult {
  const _$FaceLandmarkResultImpl({
    required final List<LandmarkPoint> landmarks,
    required this.score,
    required this.features,
    required this.frameWidth,
    required this.frameHeight,
  }) : _landmarks = landmarks;

  factory _$FaceLandmarkResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$FaceLandmarkResultImplFromJson(json);

  final List<LandmarkPoint> _landmarks;
  @override
  List<LandmarkPoint> get landmarks {
    if (_landmarks is EqualUnmodifiableListView) return _landmarks;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_landmarks);
  }

  @override
  final double score;
  @override
  final FaceFeatures features;
  @override
  final int frameWidth;
  @override
  final int frameHeight;

  @override
  String toString() {
    return 'FaceLandmarkResult(landmarks: $landmarks, score: $score, features: $features, frameWidth: $frameWidth, frameHeight: $frameHeight)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FaceLandmarkResultImpl &&
            const DeepCollectionEquality().equals(
              other._landmarks,
              _landmarks,
            ) &&
            (identical(other.score, score) || other.score == score) &&
            (identical(other.features, features) ||
                other.features == features) &&
            (identical(other.frameWidth, frameWidth) ||
                other.frameWidth == frameWidth) &&
            (identical(other.frameHeight, frameHeight) ||
                other.frameHeight == frameHeight));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_landmarks),
    score,
    features,
    frameWidth,
    frameHeight,
  );

  /// Create a copy of FaceLandmarkResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FaceLandmarkResultImplCopyWith<_$FaceLandmarkResultImpl> get copyWith =>
      __$$FaceLandmarkResultImplCopyWithImpl<_$FaceLandmarkResultImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$FaceLandmarkResultImplToJson(this);
  }
}

abstract class _FaceLandmarkResult implements FaceLandmarkResult {
  const factory _FaceLandmarkResult({
    required final List<LandmarkPoint> landmarks,
    required final double score,
    required final FaceFeatures features,
    required final int frameWidth,
    required final int frameHeight,
  }) = _$FaceLandmarkResultImpl;

  factory _FaceLandmarkResult.fromJson(Map<String, dynamic> json) =
      _$FaceLandmarkResultImpl.fromJson;

  @override
  List<LandmarkPoint> get landmarks;
  @override
  double get score;
  @override
  FaceFeatures get features;
  @override
  int get frameWidth;
  @override
  int get frameHeight;

  /// Create a copy of FaceLandmarkResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FaceLandmarkResultImplCopyWith<_$FaceLandmarkResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

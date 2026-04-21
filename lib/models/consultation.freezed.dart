// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'consultation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Consultation _$ConsultationFromJson(Map<String, dynamic> json) {
  return _Consultation.fromJson(json);
}

/// @nodoc
mixin _$Consultation {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_id')
  String get userId => throw _privateConstructorUsedError;
  @JsonKey(name: 'analysis_type')
  AnalysisType get analysisType => throw _privateConstructorUsedError;
  @JsonKey(name: 'analysis_id')
  String get analysisId => throw _privateConstructorUsedError;
  @JsonKey(name: 'context_summary')
  String get contextSummary => throw _privateConstructorUsedError;
  @JsonKey(name: 'context_features')
  Map<String, dynamic> get contextFeatures =>
      throw _privateConstructorUsedError;
  String? get title => throw _privateConstructorUsedError;
  String get locale => throw _privateConstructorUsedError;
  @JsonKey(name: 'model_used')
  String get modelUsed => throw _privateConstructorUsedError;
  @JsonKey(name: 'message_count')
  int get messageCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'last_message_at')
  DateTime get lastMessageAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this Consultation to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Consultation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ConsultationCopyWith<Consultation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConsultationCopyWith<$Res> {
  factory $ConsultationCopyWith(
    Consultation value,
    $Res Function(Consultation) then,
  ) = _$ConsultationCopyWithImpl<$Res, Consultation>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'user_id') String userId,
    @JsonKey(name: 'analysis_type') AnalysisType analysisType,
    @JsonKey(name: 'analysis_id') String analysisId,
    @JsonKey(name: 'context_summary') String contextSummary,
    @JsonKey(name: 'context_features') Map<String, dynamic> contextFeatures,
    String? title,
    String locale,
    @JsonKey(name: 'model_used') String modelUsed,
    @JsonKey(name: 'message_count') int messageCount,
    @JsonKey(name: 'last_message_at') DateTime lastMessageAt,
    @JsonKey(name: 'created_at') DateTime createdAt,
  });
}

/// @nodoc
class _$ConsultationCopyWithImpl<$Res, $Val extends Consultation>
    implements $ConsultationCopyWith<$Res> {
  _$ConsultationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Consultation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? analysisType = null,
    Object? analysisId = null,
    Object? contextSummary = null,
    Object? contextFeatures = null,
    Object? title = freezed,
    Object? locale = null,
    Object? modelUsed = null,
    Object? messageCount = null,
    Object? lastMessageAt = null,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            analysisType: null == analysisType
                ? _value.analysisType
                : analysisType // ignore: cast_nullable_to_non_nullable
                      as AnalysisType,
            analysisId: null == analysisId
                ? _value.analysisId
                : analysisId // ignore: cast_nullable_to_non_nullable
                      as String,
            contextSummary: null == contextSummary
                ? _value.contextSummary
                : contextSummary // ignore: cast_nullable_to_non_nullable
                      as String,
            contextFeatures: null == contextFeatures
                ? _value.contextFeatures
                : contextFeatures // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>,
            title: freezed == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String?,
            locale: null == locale
                ? _value.locale
                : locale // ignore: cast_nullable_to_non_nullable
                      as String,
            modelUsed: null == modelUsed
                ? _value.modelUsed
                : modelUsed // ignore: cast_nullable_to_non_nullable
                      as String,
            messageCount: null == messageCount
                ? _value.messageCount
                : messageCount // ignore: cast_nullable_to_non_nullable
                      as int,
            lastMessageAt: null == lastMessageAt
                ? _value.lastMessageAt
                : lastMessageAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
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
abstract class _$$ConsultationImplCopyWith<$Res>
    implements $ConsultationCopyWith<$Res> {
  factory _$$ConsultationImplCopyWith(
    _$ConsultationImpl value,
    $Res Function(_$ConsultationImpl) then,
  ) = __$$ConsultationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'user_id') String userId,
    @JsonKey(name: 'analysis_type') AnalysisType analysisType,
    @JsonKey(name: 'analysis_id') String analysisId,
    @JsonKey(name: 'context_summary') String contextSummary,
    @JsonKey(name: 'context_features') Map<String, dynamic> contextFeatures,
    String? title,
    String locale,
    @JsonKey(name: 'model_used') String modelUsed,
    @JsonKey(name: 'message_count') int messageCount,
    @JsonKey(name: 'last_message_at') DateTime lastMessageAt,
    @JsonKey(name: 'created_at') DateTime createdAt,
  });
}

/// @nodoc
class __$$ConsultationImplCopyWithImpl<$Res>
    extends _$ConsultationCopyWithImpl<$Res, _$ConsultationImpl>
    implements _$$ConsultationImplCopyWith<$Res> {
  __$$ConsultationImplCopyWithImpl(
    _$ConsultationImpl _value,
    $Res Function(_$ConsultationImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Consultation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? analysisType = null,
    Object? analysisId = null,
    Object? contextSummary = null,
    Object? contextFeatures = null,
    Object? title = freezed,
    Object? locale = null,
    Object? modelUsed = null,
    Object? messageCount = null,
    Object? lastMessageAt = null,
    Object? createdAt = null,
  }) {
    return _then(
      _$ConsultationImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        analysisType: null == analysisType
            ? _value.analysisType
            : analysisType // ignore: cast_nullable_to_non_nullable
                  as AnalysisType,
        analysisId: null == analysisId
            ? _value.analysisId
            : analysisId // ignore: cast_nullable_to_non_nullable
                  as String,
        contextSummary: null == contextSummary
            ? _value.contextSummary
            : contextSummary // ignore: cast_nullable_to_non_nullable
                  as String,
        contextFeatures: null == contextFeatures
            ? _value._contextFeatures
            : contextFeatures // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>,
        title: freezed == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String?,
        locale: null == locale
            ? _value.locale
            : locale // ignore: cast_nullable_to_non_nullable
                  as String,
        modelUsed: null == modelUsed
            ? _value.modelUsed
            : modelUsed // ignore: cast_nullable_to_non_nullable
                  as String,
        messageCount: null == messageCount
            ? _value.messageCount
            : messageCount // ignore: cast_nullable_to_non_nullable
                  as int,
        lastMessageAt: null == lastMessageAt
            ? _value.lastMessageAt
            : lastMessageAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
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
class _$ConsultationImpl implements _Consultation {
  const _$ConsultationImpl({
    required this.id,
    @JsonKey(name: 'user_id') required this.userId,
    @JsonKey(name: 'analysis_type') required this.analysisType,
    @JsonKey(name: 'analysis_id') required this.analysisId,
    @JsonKey(name: 'context_summary') required this.contextSummary,
    @JsonKey(name: 'context_features')
    required final Map<String, dynamic> contextFeatures,
    this.title,
    required this.locale,
    @JsonKey(name: 'model_used') required this.modelUsed,
    @JsonKey(name: 'message_count') required this.messageCount,
    @JsonKey(name: 'last_message_at') required this.lastMessageAt,
    @JsonKey(name: 'created_at') required this.createdAt,
  }) : _contextFeatures = contextFeatures;

  factory _$ConsultationImpl.fromJson(Map<String, dynamic> json) =>
      _$$ConsultationImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'user_id')
  final String userId;
  @override
  @JsonKey(name: 'analysis_type')
  final AnalysisType analysisType;
  @override
  @JsonKey(name: 'analysis_id')
  final String analysisId;
  @override
  @JsonKey(name: 'context_summary')
  final String contextSummary;
  final Map<String, dynamic> _contextFeatures;
  @override
  @JsonKey(name: 'context_features')
  Map<String, dynamic> get contextFeatures {
    if (_contextFeatures is EqualUnmodifiableMapView) return _contextFeatures;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_contextFeatures);
  }

  @override
  final String? title;
  @override
  final String locale;
  @override
  @JsonKey(name: 'model_used')
  final String modelUsed;
  @override
  @JsonKey(name: 'message_count')
  final int messageCount;
  @override
  @JsonKey(name: 'last_message_at')
  final DateTime lastMessageAt;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @override
  String toString() {
    return 'Consultation(id: $id, userId: $userId, analysisType: $analysisType, analysisId: $analysisId, contextSummary: $contextSummary, contextFeatures: $contextFeatures, title: $title, locale: $locale, modelUsed: $modelUsed, messageCount: $messageCount, lastMessageAt: $lastMessageAt, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConsultationImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.analysisType, analysisType) ||
                other.analysisType == analysisType) &&
            (identical(other.analysisId, analysisId) ||
                other.analysisId == analysisId) &&
            (identical(other.contextSummary, contextSummary) ||
                other.contextSummary == contextSummary) &&
            const DeepCollectionEquality().equals(
              other._contextFeatures,
              _contextFeatures,
            ) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.locale, locale) || other.locale == locale) &&
            (identical(other.modelUsed, modelUsed) ||
                other.modelUsed == modelUsed) &&
            (identical(other.messageCount, messageCount) ||
                other.messageCount == messageCount) &&
            (identical(other.lastMessageAt, lastMessageAt) ||
                other.lastMessageAt == lastMessageAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    userId,
    analysisType,
    analysisId,
    contextSummary,
    const DeepCollectionEquality().hash(_contextFeatures),
    title,
    locale,
    modelUsed,
    messageCount,
    lastMessageAt,
    createdAt,
  );

  /// Create a copy of Consultation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ConsultationImplCopyWith<_$ConsultationImpl> get copyWith =>
      __$$ConsultationImplCopyWithImpl<_$ConsultationImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ConsultationImplToJson(this);
  }
}

abstract class _Consultation implements Consultation {
  const factory _Consultation({
    required final String id,
    @JsonKey(name: 'user_id') required final String userId,
    @JsonKey(name: 'analysis_type') required final AnalysisType analysisType,
    @JsonKey(name: 'analysis_id') required final String analysisId,
    @JsonKey(name: 'context_summary') required final String contextSummary,
    @JsonKey(name: 'context_features')
    required final Map<String, dynamic> contextFeatures,
    final String? title,
    required final String locale,
    @JsonKey(name: 'model_used') required final String modelUsed,
    @JsonKey(name: 'message_count') required final int messageCount,
    @JsonKey(name: 'last_message_at') required final DateTime lastMessageAt,
    @JsonKey(name: 'created_at') required final DateTime createdAt,
  }) = _$ConsultationImpl;

  factory _Consultation.fromJson(Map<String, dynamic> json) =
      _$ConsultationImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'user_id')
  String get userId;
  @override
  @JsonKey(name: 'analysis_type')
  AnalysisType get analysisType;
  @override
  @JsonKey(name: 'analysis_id')
  String get analysisId;
  @override
  @JsonKey(name: 'context_summary')
  String get contextSummary;
  @override
  @JsonKey(name: 'context_features')
  Map<String, dynamic> get contextFeatures;
  @override
  String? get title;
  @override
  String get locale;
  @override
  @JsonKey(name: 'model_used')
  String get modelUsed;
  @override
  @JsonKey(name: 'message_count')
  int get messageCount;
  @override
  @JsonKey(name: 'last_message_at')
  DateTime get lastMessageAt;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;

  /// Create a copy of Consultation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ConsultationImplCopyWith<_$ConsultationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'consultation_message.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ConsultationMessage _$ConsultationMessageFromJson(Map<String, dynamic> json) {
  return _ConsultationMessage.fromJson(json);
}

/// @nodoc
mixin _$ConsultationMessage {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'consultation_id')
  String get consultationId => throw _privateConstructorUsedError;
  MessageRole get role => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  @JsonKey(name: 'token_count')
  int? get tokenCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this ConsultationMessage to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ConsultationMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ConsultationMessageCopyWith<ConsultationMessage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConsultationMessageCopyWith<$Res> {
  factory $ConsultationMessageCopyWith(
    ConsultationMessage value,
    $Res Function(ConsultationMessage) then,
  ) = _$ConsultationMessageCopyWithImpl<$Res, ConsultationMessage>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'consultation_id') String consultationId,
    MessageRole role,
    String content,
    @JsonKey(name: 'token_count') int? tokenCount,
    @JsonKey(name: 'created_at') DateTime createdAt,
  });
}

/// @nodoc
class _$ConsultationMessageCopyWithImpl<$Res, $Val extends ConsultationMessage>
    implements $ConsultationMessageCopyWith<$Res> {
  _$ConsultationMessageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ConsultationMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? consultationId = null,
    Object? role = null,
    Object? content = null,
    Object? tokenCount = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            consultationId: null == consultationId
                ? _value.consultationId
                : consultationId // ignore: cast_nullable_to_non_nullable
                      as String,
            role: null == role
                ? _value.role
                : role // ignore: cast_nullable_to_non_nullable
                      as MessageRole,
            content: null == content
                ? _value.content
                : content // ignore: cast_nullable_to_non_nullable
                      as String,
            tokenCount: freezed == tokenCount
                ? _value.tokenCount
                : tokenCount // ignore: cast_nullable_to_non_nullable
                      as int?,
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
abstract class _$$ConsultationMessageImplCopyWith<$Res>
    implements $ConsultationMessageCopyWith<$Res> {
  factory _$$ConsultationMessageImplCopyWith(
    _$ConsultationMessageImpl value,
    $Res Function(_$ConsultationMessageImpl) then,
  ) = __$$ConsultationMessageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'consultation_id') String consultationId,
    MessageRole role,
    String content,
    @JsonKey(name: 'token_count') int? tokenCount,
    @JsonKey(name: 'created_at') DateTime createdAt,
  });
}

/// @nodoc
class __$$ConsultationMessageImplCopyWithImpl<$Res>
    extends _$ConsultationMessageCopyWithImpl<$Res, _$ConsultationMessageImpl>
    implements _$$ConsultationMessageImplCopyWith<$Res> {
  __$$ConsultationMessageImplCopyWithImpl(
    _$ConsultationMessageImpl _value,
    $Res Function(_$ConsultationMessageImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ConsultationMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? consultationId = null,
    Object? role = null,
    Object? content = null,
    Object? tokenCount = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _$ConsultationMessageImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        consultationId: null == consultationId
            ? _value.consultationId
            : consultationId // ignore: cast_nullable_to_non_nullable
                  as String,
        role: null == role
            ? _value.role
            : role // ignore: cast_nullable_to_non_nullable
                  as MessageRole,
        content: null == content
            ? _value.content
            : content // ignore: cast_nullable_to_non_nullable
                  as String,
        tokenCount: freezed == tokenCount
            ? _value.tokenCount
            : tokenCount // ignore: cast_nullable_to_non_nullable
                  as int?,
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
class _$ConsultationMessageImpl implements _ConsultationMessage {
  const _$ConsultationMessageImpl({
    required this.id,
    @JsonKey(name: 'consultation_id') required this.consultationId,
    required this.role,
    required this.content,
    @JsonKey(name: 'token_count') this.tokenCount,
    @JsonKey(name: 'created_at') required this.createdAt,
  });

  factory _$ConsultationMessageImpl.fromJson(Map<String, dynamic> json) =>
      _$$ConsultationMessageImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'consultation_id')
  final String consultationId;
  @override
  final MessageRole role;
  @override
  final String content;
  @override
  @JsonKey(name: 'token_count')
  final int? tokenCount;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @override
  String toString() {
    return 'ConsultationMessage(id: $id, consultationId: $consultationId, role: $role, content: $content, tokenCount: $tokenCount, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConsultationMessageImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.consultationId, consultationId) ||
                other.consultationId == consultationId) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.tokenCount, tokenCount) ||
                other.tokenCount == tokenCount) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    consultationId,
    role,
    content,
    tokenCount,
    createdAt,
  );

  /// Create a copy of ConsultationMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ConsultationMessageImplCopyWith<_$ConsultationMessageImpl> get copyWith =>
      __$$ConsultationMessageImplCopyWithImpl<_$ConsultationMessageImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ConsultationMessageImplToJson(this);
  }
}

abstract class _ConsultationMessage implements ConsultationMessage {
  const factory _ConsultationMessage({
    required final String id,
    @JsonKey(name: 'consultation_id') required final String consultationId,
    required final MessageRole role,
    required final String content,
    @JsonKey(name: 'token_count') final int? tokenCount,
    @JsonKey(name: 'created_at') required final DateTime createdAt,
  }) = _$ConsultationMessageImpl;

  factory _ConsultationMessage.fromJson(Map<String, dynamic> json) =
      _$ConsultationMessageImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'consultation_id')
  String get consultationId;
  @override
  MessageRole get role;
  @override
  String get content;
  @override
  @JsonKey(name: 'token_count')
  int? get tokenCount;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;

  /// Create a copy of ConsultationMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ConsultationMessageImplCopyWith<_$ConsultationMessageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'commission_rule.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

CommissionRule _$CommissionRuleFromJson(Map<String, dynamic> json) {
  return _CommissionRule.fromJson(json);
}

/// @nodoc
mixin _$CommissionRule {
  String get id => throw _privateConstructorUsedError;
  String get stationId => throw _privateConstructorUsedError;
  String? get serviceId => throw _privateConstructorUsedError;
  double get rate =>
      throw _privateConstructorUsedError; // percentage (e.g., 10 means 10%)
  bool get isActive => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this CommissionRule to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CommissionRule
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CommissionRuleCopyWith<CommissionRule> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CommissionRuleCopyWith<$Res> {
  factory $CommissionRuleCopyWith(
    CommissionRule value,
    $Res Function(CommissionRule) then,
  ) = _$CommissionRuleCopyWithImpl<$Res, CommissionRule>;
  @useResult
  $Res call({
    String id,
    String stationId,
    String? serviceId,
    double rate,
    bool isActive,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class _$CommissionRuleCopyWithImpl<$Res, $Val extends CommissionRule>
    implements $CommissionRuleCopyWith<$Res> {
  _$CommissionRuleCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CommissionRule
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? stationId = null,
    Object? serviceId = freezed,
    Object? rate = null,
    Object? isActive = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            stationId: null == stationId
                ? _value.stationId
                : stationId // ignore: cast_nullable_to_non_nullable
                      as String,
            serviceId: freezed == serviceId
                ? _value.serviceId
                : serviceId // ignore: cast_nullable_to_non_nullable
                      as String?,
            rate: null == rate
                ? _value.rate
                : rate // ignore: cast_nullable_to_non_nullable
                      as double,
            isActive: null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CommissionRuleImplCopyWith<$Res>
    implements $CommissionRuleCopyWith<$Res> {
  factory _$$CommissionRuleImplCopyWith(
    _$CommissionRuleImpl value,
    $Res Function(_$CommissionRuleImpl) then,
  ) = __$$CommissionRuleImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String stationId,
    String? serviceId,
    double rate,
    bool isActive,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class __$$CommissionRuleImplCopyWithImpl<$Res>
    extends _$CommissionRuleCopyWithImpl<$Res, _$CommissionRuleImpl>
    implements _$$CommissionRuleImplCopyWith<$Res> {
  __$$CommissionRuleImplCopyWithImpl(
    _$CommissionRuleImpl _value,
    $Res Function(_$CommissionRuleImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CommissionRule
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? stationId = null,
    Object? serviceId = freezed,
    Object? rate = null,
    Object? isActive = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$CommissionRuleImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        stationId: null == stationId
            ? _value.stationId
            : stationId // ignore: cast_nullable_to_non_nullable
                  as String,
        serviceId: freezed == serviceId
            ? _value.serviceId
            : serviceId // ignore: cast_nullable_to_non_nullable
                  as String?,
        rate: null == rate
            ? _value.rate
            : rate // ignore: cast_nullable_to_non_nullable
                  as double,
        isActive: null == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CommissionRuleImpl implements _CommissionRule {
  const _$CommissionRuleImpl({
    required this.id,
    required this.stationId,
    this.serviceId,
    required this.rate,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory _$CommissionRuleImpl.fromJson(Map<String, dynamic> json) =>
      _$$CommissionRuleImplFromJson(json);

  @override
  final String id;
  @override
  final String stationId;
  @override
  final String? serviceId;
  @override
  final double rate;
  // percentage (e.g., 10 means 10%)
  @override
  @JsonKey()
  final bool isActive;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'CommissionRule(id: $id, stationId: $stationId, serviceId: $serviceId, rate: $rate, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CommissionRuleImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.stationId, stationId) ||
                other.stationId == stationId) &&
            (identical(other.serviceId, serviceId) ||
                other.serviceId == serviceId) &&
            (identical(other.rate, rate) || other.rate == rate) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    stationId,
    serviceId,
    rate,
    isActive,
    createdAt,
    updatedAt,
  );

  /// Create a copy of CommissionRule
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CommissionRuleImplCopyWith<_$CommissionRuleImpl> get copyWith =>
      __$$CommissionRuleImplCopyWithImpl<_$CommissionRuleImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CommissionRuleImplToJson(this);
  }
}

abstract class _CommissionRule implements CommissionRule {
  const factory _CommissionRule({
    required final String id,
    required final String stationId,
    final String? serviceId,
    required final double rate,
    final bool isActive,
    required final DateTime createdAt,
    required final DateTime updatedAt,
  }) = _$CommissionRuleImpl;

  factory _CommissionRule.fromJson(Map<String, dynamic> json) =
      _$CommissionRuleImpl.fromJson;

  @override
  String get id;
  @override
  String get stationId;
  @override
  String? get serviceId;
  @override
  double get rate; // percentage (e.g., 10 means 10%)
  @override
  bool get isActive;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of CommissionRule
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CommissionRuleImplCopyWith<_$CommissionRuleImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

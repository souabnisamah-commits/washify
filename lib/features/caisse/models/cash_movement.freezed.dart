// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cash_movement.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

CashMovement _$CashMovementFromJson(Map<String, dynamic> json) {
  return _CashMovement.fromJson(json);
}

/// @nodoc
mixin _$CashMovement {
  String get id => throw _privateConstructorUsedError;
  String get stationId => throw _privateConstructorUsedError;
  String get sessionId => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError; // 'in', 'out'
  String get reason =>
      throw _privateConstructorUsedError; // 'Acompte ouvrier', 'Achat consommables', 'Alimentation caisse', 'Recette' etc.
  String get paymentMethod => throw _privateConstructorUsedError;
  String? get employeeId => throw _privateConstructorUsedError;
  String? get employeeName => throw _privateConstructorUsedError;
  String get performedBy => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this CashMovement to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CashMovement
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CashMovementCopyWith<CashMovement> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CashMovementCopyWith<$Res> {
  factory $CashMovementCopyWith(
    CashMovement value,
    $Res Function(CashMovement) then,
  ) = _$CashMovementCopyWithImpl<$Res, CashMovement>;
  @useResult
  $Res call({
    String id,
    String stationId,
    String sessionId,
    double amount,
    String type,
    String reason,
    String paymentMethod,
    String? employeeId,
    String? employeeName,
    String performedBy,
    DateTime createdAt,
  });
}

/// @nodoc
class _$CashMovementCopyWithImpl<$Res, $Val extends CashMovement>
    implements $CashMovementCopyWith<$Res> {
  _$CashMovementCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CashMovement
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? stationId = null,
    Object? sessionId = null,
    Object? amount = null,
    Object? type = null,
    Object? reason = null,
    Object? paymentMethod = null,
    Object? employeeId = freezed,
    Object? employeeName = freezed,
    Object? performedBy = null,
    Object? createdAt = null,
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
            sessionId: null == sessionId
                ? _value.sessionId
                : sessionId // ignore: cast_nullable_to_non_nullable
                      as String,
            amount: null == amount
                ? _value.amount
                : amount // ignore: cast_nullable_to_non_nullable
                      as double,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as String,
            reason: null == reason
                ? _value.reason
                : reason // ignore: cast_nullable_to_non_nullable
                      as String,
            paymentMethod: null == paymentMethod
                ? _value.paymentMethod
                : paymentMethod // ignore: cast_nullable_to_non_nullable
                      as String,
            employeeId: freezed == employeeId
                ? _value.employeeId
                : employeeId // ignore: cast_nullable_to_non_nullable
                      as String?,
            employeeName: freezed == employeeName
                ? _value.employeeName
                : employeeName // ignore: cast_nullable_to_non_nullable
                      as String?,
            performedBy: null == performedBy
                ? _value.performedBy
                : performedBy // ignore: cast_nullable_to_non_nullable
                      as String,
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
abstract class _$$CashMovementImplCopyWith<$Res>
    implements $CashMovementCopyWith<$Res> {
  factory _$$CashMovementImplCopyWith(
    _$CashMovementImpl value,
    $Res Function(_$CashMovementImpl) then,
  ) = __$$CashMovementImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String stationId,
    String sessionId,
    double amount,
    String type,
    String reason,
    String paymentMethod,
    String? employeeId,
    String? employeeName,
    String performedBy,
    DateTime createdAt,
  });
}

/// @nodoc
class __$$CashMovementImplCopyWithImpl<$Res>
    extends _$CashMovementCopyWithImpl<$Res, _$CashMovementImpl>
    implements _$$CashMovementImplCopyWith<$Res> {
  __$$CashMovementImplCopyWithImpl(
    _$CashMovementImpl _value,
    $Res Function(_$CashMovementImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CashMovement
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? stationId = null,
    Object? sessionId = null,
    Object? amount = null,
    Object? type = null,
    Object? reason = null,
    Object? paymentMethod = null,
    Object? employeeId = freezed,
    Object? employeeName = freezed,
    Object? performedBy = null,
    Object? createdAt = null,
  }) {
    return _then(
      _$CashMovementImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        stationId: null == stationId
            ? _value.stationId
            : stationId // ignore: cast_nullable_to_non_nullable
                  as String,
        sessionId: null == sessionId
            ? _value.sessionId
            : sessionId // ignore: cast_nullable_to_non_nullable
                  as String,
        amount: null == amount
            ? _value.amount
            : amount // ignore: cast_nullable_to_non_nullable
                  as double,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String,
        reason: null == reason
            ? _value.reason
            : reason // ignore: cast_nullable_to_non_nullable
                  as String,
        paymentMethod: null == paymentMethod
            ? _value.paymentMethod
            : paymentMethod // ignore: cast_nullable_to_non_nullable
                  as String,
        employeeId: freezed == employeeId
            ? _value.employeeId
            : employeeId // ignore: cast_nullable_to_non_nullable
                  as String?,
        employeeName: freezed == employeeName
            ? _value.employeeName
            : employeeName // ignore: cast_nullable_to_non_nullable
                  as String?,
        performedBy: null == performedBy
            ? _value.performedBy
            : performedBy // ignore: cast_nullable_to_non_nullable
                  as String,
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
class _$CashMovementImpl implements _CashMovement {
  const _$CashMovementImpl({
    required this.id,
    required this.stationId,
    required this.sessionId,
    required this.amount,
    required this.type,
    required this.reason,
    this.paymentMethod = 'cash',
    this.employeeId,
    this.employeeName,
    required this.performedBy,
    required this.createdAt,
  });

  factory _$CashMovementImpl.fromJson(Map<String, dynamic> json) =>
      _$$CashMovementImplFromJson(json);

  @override
  final String id;
  @override
  final String stationId;
  @override
  final String sessionId;
  @override
  final double amount;
  @override
  final String type;
  // 'in', 'out'
  @override
  final String reason;
  // 'Acompte ouvrier', 'Achat consommables', 'Alimentation caisse', 'Recette' etc.
  @override
  @JsonKey()
  final String paymentMethod;
  @override
  final String? employeeId;
  @override
  final String? employeeName;
  @override
  final String performedBy;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'CashMovement(id: $id, stationId: $stationId, sessionId: $sessionId, amount: $amount, type: $type, reason: $reason, paymentMethod: $paymentMethod, employeeId: $employeeId, employeeName: $employeeName, performedBy: $performedBy, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CashMovementImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.stationId, stationId) ||
                other.stationId == stationId) &&
            (identical(other.sessionId, sessionId) ||
                other.sessionId == sessionId) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.reason, reason) || other.reason == reason) &&
            (identical(other.paymentMethod, paymentMethod) ||
                other.paymentMethod == paymentMethod) &&
            (identical(other.employeeId, employeeId) ||
                other.employeeId == employeeId) &&
            (identical(other.employeeName, employeeName) ||
                other.employeeName == employeeName) &&
            (identical(other.performedBy, performedBy) ||
                other.performedBy == performedBy) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    stationId,
    sessionId,
    amount,
    type,
    reason,
    paymentMethod,
    employeeId,
    employeeName,
    performedBy,
    createdAt,
  );

  /// Create a copy of CashMovement
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CashMovementImplCopyWith<_$CashMovementImpl> get copyWith =>
      __$$CashMovementImplCopyWithImpl<_$CashMovementImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CashMovementImplToJson(this);
  }
}

abstract class _CashMovement implements CashMovement {
  const factory _CashMovement({
    required final String id,
    required final String stationId,
    required final String sessionId,
    required final double amount,
    required final String type,
    required final String reason,
    final String paymentMethod,
    final String? employeeId,
    final String? employeeName,
    required final String performedBy,
    required final DateTime createdAt,
  }) = _$CashMovementImpl;

  factory _CashMovement.fromJson(Map<String, dynamic> json) =
      _$CashMovementImpl.fromJson;

  @override
  String get id;
  @override
  String get stationId;
  @override
  String get sessionId;
  @override
  double get amount;
  @override
  String get type; // 'in', 'out'
  @override
  String get reason; // 'Acompte ouvrier', 'Achat consommables', 'Alimentation caisse', 'Recette' etc.
  @override
  String get paymentMethod;
  @override
  String? get employeeId;
  @override
  String? get employeeName;
  @override
  String get performedBy;
  @override
  DateTime get createdAt;

  /// Create a copy of CashMovement
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CashMovementImplCopyWith<_$CashMovementImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

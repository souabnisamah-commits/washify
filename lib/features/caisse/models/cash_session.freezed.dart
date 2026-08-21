// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cash_session.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

CashSession _$CashSessionFromJson(Map<String, dynamic> json) {
  return _CashSession.fromJson(json);
}

/// @nodoc
mixin _$CashSession {
  String get id => throw _privateConstructorUsedError;
  String get stationId => throw _privateConstructorUsedError;
  DateTime get openingDate => throw _privateConstructorUsedError;
  DateTime? get closingDate => throw _privateConstructorUsedError;
  String get openedBy => throw _privateConstructorUsedError;
  String? get closedBy => throw _privateConstructorUsedError;
  double get initialBalance => throw _privateConstructorUsedError;
  double? get finalBalance => throw _privateConstructorUsedError;
  double get totalCashIn => throw _privateConstructorUsedError;
  double get totalCashOut => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError; // 'open', 'closed'
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this CashSession to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CashSession
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CashSessionCopyWith<CashSession> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CashSessionCopyWith<$Res> {
  factory $CashSessionCopyWith(
    CashSession value,
    $Res Function(CashSession) then,
  ) = _$CashSessionCopyWithImpl<$Res, CashSession>;
  @useResult
  $Res call({
    String id,
    String stationId,
    DateTime openingDate,
    DateTime? closingDate,
    String openedBy,
    String? closedBy,
    double initialBalance,
    double? finalBalance,
    double totalCashIn,
    double totalCashOut,
    String status,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class _$CashSessionCopyWithImpl<$Res, $Val extends CashSession>
    implements $CashSessionCopyWith<$Res> {
  _$CashSessionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CashSession
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? stationId = null,
    Object? openingDate = null,
    Object? closingDate = freezed,
    Object? openedBy = null,
    Object? closedBy = freezed,
    Object? initialBalance = null,
    Object? finalBalance = freezed,
    Object? totalCashIn = null,
    Object? totalCashOut = null,
    Object? status = null,
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
            openingDate: null == openingDate
                ? _value.openingDate
                : openingDate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            closingDate: freezed == closingDate
                ? _value.closingDate
                : closingDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            openedBy: null == openedBy
                ? _value.openedBy
                : openedBy // ignore: cast_nullable_to_non_nullable
                      as String,
            closedBy: freezed == closedBy
                ? _value.closedBy
                : closedBy // ignore: cast_nullable_to_non_nullable
                      as String?,
            initialBalance: null == initialBalance
                ? _value.initialBalance
                : initialBalance // ignore: cast_nullable_to_non_nullable
                      as double,
            finalBalance: freezed == finalBalance
                ? _value.finalBalance
                : finalBalance // ignore: cast_nullable_to_non_nullable
                      as double?,
            totalCashIn: null == totalCashIn
                ? _value.totalCashIn
                : totalCashIn // ignore: cast_nullable_to_non_nullable
                      as double,
            totalCashOut: null == totalCashOut
                ? _value.totalCashOut
                : totalCashOut // ignore: cast_nullable_to_non_nullable
                      as double,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
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
abstract class _$$CashSessionImplCopyWith<$Res>
    implements $CashSessionCopyWith<$Res> {
  factory _$$CashSessionImplCopyWith(
    _$CashSessionImpl value,
    $Res Function(_$CashSessionImpl) then,
  ) = __$$CashSessionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String stationId,
    DateTime openingDate,
    DateTime? closingDate,
    String openedBy,
    String? closedBy,
    double initialBalance,
    double? finalBalance,
    double totalCashIn,
    double totalCashOut,
    String status,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class __$$CashSessionImplCopyWithImpl<$Res>
    extends _$CashSessionCopyWithImpl<$Res, _$CashSessionImpl>
    implements _$$CashSessionImplCopyWith<$Res> {
  __$$CashSessionImplCopyWithImpl(
    _$CashSessionImpl _value,
    $Res Function(_$CashSessionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CashSession
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? stationId = null,
    Object? openingDate = null,
    Object? closingDate = freezed,
    Object? openedBy = null,
    Object? closedBy = freezed,
    Object? initialBalance = null,
    Object? finalBalance = freezed,
    Object? totalCashIn = null,
    Object? totalCashOut = null,
    Object? status = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$CashSessionImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        stationId: null == stationId
            ? _value.stationId
            : stationId // ignore: cast_nullable_to_non_nullable
                  as String,
        openingDate: null == openingDate
            ? _value.openingDate
            : openingDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        closingDate: freezed == closingDate
            ? _value.closingDate
            : closingDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        openedBy: null == openedBy
            ? _value.openedBy
            : openedBy // ignore: cast_nullable_to_non_nullable
                  as String,
        closedBy: freezed == closedBy
            ? _value.closedBy
            : closedBy // ignore: cast_nullable_to_non_nullable
                  as String?,
        initialBalance: null == initialBalance
            ? _value.initialBalance
            : initialBalance // ignore: cast_nullable_to_non_nullable
                  as double,
        finalBalance: freezed == finalBalance
            ? _value.finalBalance
            : finalBalance // ignore: cast_nullable_to_non_nullable
                  as double?,
        totalCashIn: null == totalCashIn
            ? _value.totalCashIn
            : totalCashIn // ignore: cast_nullable_to_non_nullable
                  as double,
        totalCashOut: null == totalCashOut
            ? _value.totalCashOut
            : totalCashOut // ignore: cast_nullable_to_non_nullable
                  as double,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
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
class _$CashSessionImpl implements _CashSession {
  const _$CashSessionImpl({
    required this.id,
    required this.stationId,
    required this.openingDate,
    this.closingDate,
    required this.openedBy,
    this.closedBy,
    required this.initialBalance,
    this.finalBalance,
    this.totalCashIn = 0.0,
    this.totalCashOut = 0.0,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory _$CashSessionImpl.fromJson(Map<String, dynamic> json) =>
      _$$CashSessionImplFromJson(json);

  @override
  final String id;
  @override
  final String stationId;
  @override
  final DateTime openingDate;
  @override
  final DateTime? closingDate;
  @override
  final String openedBy;
  @override
  final String? closedBy;
  @override
  final double initialBalance;
  @override
  final double? finalBalance;
  @override
  @JsonKey()
  final double totalCashIn;
  @override
  @JsonKey()
  final double totalCashOut;
  @override
  final String status;
  // 'open', 'closed'
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'CashSession(id: $id, stationId: $stationId, openingDate: $openingDate, closingDate: $closingDate, openedBy: $openedBy, closedBy: $closedBy, initialBalance: $initialBalance, finalBalance: $finalBalance, totalCashIn: $totalCashIn, totalCashOut: $totalCashOut, status: $status, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CashSessionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.stationId, stationId) ||
                other.stationId == stationId) &&
            (identical(other.openingDate, openingDate) ||
                other.openingDate == openingDate) &&
            (identical(other.closingDate, closingDate) ||
                other.closingDate == closingDate) &&
            (identical(other.openedBy, openedBy) ||
                other.openedBy == openedBy) &&
            (identical(other.closedBy, closedBy) ||
                other.closedBy == closedBy) &&
            (identical(other.initialBalance, initialBalance) ||
                other.initialBalance == initialBalance) &&
            (identical(other.finalBalance, finalBalance) ||
                other.finalBalance == finalBalance) &&
            (identical(other.totalCashIn, totalCashIn) ||
                other.totalCashIn == totalCashIn) &&
            (identical(other.totalCashOut, totalCashOut) ||
                other.totalCashOut == totalCashOut) &&
            (identical(other.status, status) || other.status == status) &&
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
    openingDate,
    closingDate,
    openedBy,
    closedBy,
    initialBalance,
    finalBalance,
    totalCashIn,
    totalCashOut,
    status,
    createdAt,
    updatedAt,
  );

  /// Create a copy of CashSession
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CashSessionImplCopyWith<_$CashSessionImpl> get copyWith =>
      __$$CashSessionImplCopyWithImpl<_$CashSessionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CashSessionImplToJson(this);
  }
}

abstract class _CashSession implements CashSession {
  const factory _CashSession({
    required final String id,
    required final String stationId,
    required final DateTime openingDate,
    final DateTime? closingDate,
    required final String openedBy,
    final String? closedBy,
    required final double initialBalance,
    final double? finalBalance,
    final double totalCashIn,
    final double totalCashOut,
    required final String status,
    required final DateTime createdAt,
    required final DateTime updatedAt,
  }) = _$CashSessionImpl;

  factory _CashSession.fromJson(Map<String, dynamic> json) =
      _$CashSessionImpl.fromJson;

  @override
  String get id;
  @override
  String get stationId;
  @override
  DateTime get openingDate;
  @override
  DateTime? get closingDate;
  @override
  String get openedBy;
  @override
  String? get closedBy;
  @override
  double get initialBalance;
  @override
  double? get finalBalance;
  @override
  double get totalCashIn;
  @override
  double get totalCashOut;
  @override
  String get status; // 'open', 'closed'
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of CashSession
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CashSessionImplCopyWith<_$CashSessionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

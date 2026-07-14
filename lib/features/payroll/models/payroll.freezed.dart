// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'payroll.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

PayrollTransaction _$PayrollTransactionFromJson(Map<String, dynamic> json) {
  return _PayrollTransaction.fromJson(json);
}

/// @nodoc
mixin _$PayrollTransaction {
  String get id => throw _privateConstructorUsedError;
  String get payrollId => throw _privateConstructorUsedError;
  String get employeeId => throw _privateConstructorUsedError;
  @JsonKey(readValue: readTenantId)
  String get tenantId => throw _privateConstructorUsedError;
  PayrollTransactionType get type =>
      throw _privateConstructorUsedError; // salaire, prime, avance, cnss
  double get amount => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this PayrollTransaction to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PayrollTransaction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PayrollTransactionCopyWith<PayrollTransaction> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PayrollTransactionCopyWith<$Res> {
  factory $PayrollTransactionCopyWith(
    PayrollTransaction value,
    $Res Function(PayrollTransaction) then,
  ) = _$PayrollTransactionCopyWithImpl<$Res, PayrollTransaction>;
  @useResult
  $Res call({
    String id,
    String payrollId,
    String employeeId,
    @JsonKey(readValue: readTenantId) String tenantId,
    PayrollTransactionType type,
    double amount,
    String description,
    DateTime createdAt,
  });
}

/// @nodoc
class _$PayrollTransactionCopyWithImpl<$Res, $Val extends PayrollTransaction>
    implements $PayrollTransactionCopyWith<$Res> {
  _$PayrollTransactionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PayrollTransaction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? payrollId = null,
    Object? employeeId = null,
    Object? tenantId = null,
    Object? type = null,
    Object? amount = null,
    Object? description = null,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            payrollId: null == payrollId
                ? _value.payrollId
                : payrollId // ignore: cast_nullable_to_non_nullable
                      as String,
            employeeId: null == employeeId
                ? _value.employeeId
                : employeeId // ignore: cast_nullable_to_non_nullable
                      as String,
            tenantId: null == tenantId
                ? _value.tenantId
                : tenantId // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as PayrollTransactionType,
            amount: null == amount
                ? _value.amount
                : amount // ignore: cast_nullable_to_non_nullable
                      as double,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
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
abstract class _$$PayrollTransactionImplCopyWith<$Res>
    implements $PayrollTransactionCopyWith<$Res> {
  factory _$$PayrollTransactionImplCopyWith(
    _$PayrollTransactionImpl value,
    $Res Function(_$PayrollTransactionImpl) then,
  ) = __$$PayrollTransactionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String payrollId,
    String employeeId,
    @JsonKey(readValue: readTenantId) String tenantId,
    PayrollTransactionType type,
    double amount,
    String description,
    DateTime createdAt,
  });
}

/// @nodoc
class __$$PayrollTransactionImplCopyWithImpl<$Res>
    extends _$PayrollTransactionCopyWithImpl<$Res, _$PayrollTransactionImpl>
    implements _$$PayrollTransactionImplCopyWith<$Res> {
  __$$PayrollTransactionImplCopyWithImpl(
    _$PayrollTransactionImpl _value,
    $Res Function(_$PayrollTransactionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PayrollTransaction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? payrollId = null,
    Object? employeeId = null,
    Object? tenantId = null,
    Object? type = null,
    Object? amount = null,
    Object? description = null,
    Object? createdAt = null,
  }) {
    return _then(
      _$PayrollTransactionImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        payrollId: null == payrollId
            ? _value.payrollId
            : payrollId // ignore: cast_nullable_to_non_nullable
                  as String,
        employeeId: null == employeeId
            ? _value.employeeId
            : employeeId // ignore: cast_nullable_to_non_nullable
                  as String,
        tenantId: null == tenantId
            ? _value.tenantId
            : tenantId // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as PayrollTransactionType,
        amount: null == amount
            ? _value.amount
            : amount // ignore: cast_nullable_to_non_nullable
                  as double,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
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
class _$PayrollTransactionImpl extends _PayrollTransaction {
  const _$PayrollTransactionImpl({
    required this.id,
    required this.payrollId,
    required this.employeeId,
    @JsonKey(readValue: readTenantId) required this.tenantId,
    required this.type,
    required this.amount,
    required this.description,
    required this.createdAt,
  }) : super._();

  factory _$PayrollTransactionImpl.fromJson(Map<String, dynamic> json) =>
      _$$PayrollTransactionImplFromJson(json);

  @override
  final String id;
  @override
  final String payrollId;
  @override
  final String employeeId;
  @override
  @JsonKey(readValue: readTenantId)
  final String tenantId;
  @override
  final PayrollTransactionType type;
  // salaire, prime, avance, cnss
  @override
  final double amount;
  @override
  final String description;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'PayrollTransaction(id: $id, payrollId: $payrollId, employeeId: $employeeId, tenantId: $tenantId, type: $type, amount: $amount, description: $description, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PayrollTransactionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.payrollId, payrollId) ||
                other.payrollId == payrollId) &&
            (identical(other.employeeId, employeeId) ||
                other.employeeId == employeeId) &&
            (identical(other.tenantId, tenantId) ||
                other.tenantId == tenantId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    payrollId,
    employeeId,
    tenantId,
    type,
    amount,
    description,
    createdAt,
  );

  /// Create a copy of PayrollTransaction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PayrollTransactionImplCopyWith<_$PayrollTransactionImpl> get copyWith =>
      __$$PayrollTransactionImplCopyWithImpl<_$PayrollTransactionImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$PayrollTransactionImplToJson(this);
  }
}

abstract class _PayrollTransaction extends PayrollTransaction {
  const factory _PayrollTransaction({
    required final String id,
    required final String payrollId,
    required final String employeeId,
    @JsonKey(readValue: readTenantId) required final String tenantId,
    required final PayrollTransactionType type,
    required final double amount,
    required final String description,
    required final DateTime createdAt,
  }) = _$PayrollTransactionImpl;
  const _PayrollTransaction._() : super._();

  factory _PayrollTransaction.fromJson(Map<String, dynamic> json) =
      _$PayrollTransactionImpl.fromJson;

  @override
  String get id;
  @override
  String get payrollId;
  @override
  String get employeeId;
  @override
  @JsonKey(readValue: readTenantId)
  String get tenantId;
  @override
  PayrollTransactionType get type; // salaire, prime, avance, cnss
  @override
  double get amount;
  @override
  String get description;
  @override
  DateTime get createdAt;

  /// Create a copy of PayrollTransaction
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PayrollTransactionImplCopyWith<_$PayrollTransactionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Payroll _$PayrollFromJson(Map<String, dynamic> json) {
  return _Payroll.fromJson(json);
}

/// @nodoc
mixin _$Payroll {
  String get id => throw _privateConstructorUsedError;
  String get employeeId => throw _privateConstructorUsedError;
  String get employeeName => throw _privateConstructorUsedError;
  @JsonKey(readValue: readTenantId)
  String get tenantId => throw _privateConstructorUsedError;
  double get baseSalary => throw _privateConstructorUsedError;
  double get commissionTotal => throw _privateConstructorUsedError;
  double get bonuses => throw _privateConstructorUsedError;
  double get deductions => throw _privateConstructorUsedError;
  double get netAmount => throw _privateConstructorUsedError;
  String get period => throw _privateConstructorUsedError; // e.g., "2026-06"
  String get status =>
      throw _privateConstructorUsedError; // pending, approved, paid
  String? get approvedBy => throw _privateConstructorUsedError;
  DateTime? get paidAt => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this Payroll to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Payroll
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PayrollCopyWith<Payroll> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PayrollCopyWith<$Res> {
  factory $PayrollCopyWith(Payroll value, $Res Function(Payroll) then) =
      _$PayrollCopyWithImpl<$Res, Payroll>;
  @useResult
  $Res call({
    String id,
    String employeeId,
    String employeeName,
    @JsonKey(readValue: readTenantId) String tenantId,
    double baseSalary,
    double commissionTotal,
    double bonuses,
    double deductions,
    double netAmount,
    String period,
    String status,
    String? approvedBy,
    DateTime? paidAt,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class _$PayrollCopyWithImpl<$Res, $Val extends Payroll>
    implements $PayrollCopyWith<$Res> {
  _$PayrollCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Payroll
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? employeeId = null,
    Object? employeeName = null,
    Object? tenantId = null,
    Object? baseSalary = null,
    Object? commissionTotal = null,
    Object? bonuses = null,
    Object? deductions = null,
    Object? netAmount = null,
    Object? period = null,
    Object? status = null,
    Object? approvedBy = freezed,
    Object? paidAt = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            employeeId: null == employeeId
                ? _value.employeeId
                : employeeId // ignore: cast_nullable_to_non_nullable
                      as String,
            employeeName: null == employeeName
                ? _value.employeeName
                : employeeName // ignore: cast_nullable_to_non_nullable
                      as String,
            tenantId: null == tenantId
                ? _value.tenantId
                : tenantId // ignore: cast_nullable_to_non_nullable
                      as String,
            baseSalary: null == baseSalary
                ? _value.baseSalary
                : baseSalary // ignore: cast_nullable_to_non_nullable
                      as double,
            commissionTotal: null == commissionTotal
                ? _value.commissionTotal
                : commissionTotal // ignore: cast_nullable_to_non_nullable
                      as double,
            bonuses: null == bonuses
                ? _value.bonuses
                : bonuses // ignore: cast_nullable_to_non_nullable
                      as double,
            deductions: null == deductions
                ? _value.deductions
                : deductions // ignore: cast_nullable_to_non_nullable
                      as double,
            netAmount: null == netAmount
                ? _value.netAmount
                : netAmount // ignore: cast_nullable_to_non_nullable
                      as double,
            period: null == period
                ? _value.period
                : period // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            approvedBy: freezed == approvedBy
                ? _value.approvedBy
                : approvedBy // ignore: cast_nullable_to_non_nullable
                      as String?,
            paidAt: freezed == paidAt
                ? _value.paidAt
                : paidAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
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
abstract class _$$PayrollImplCopyWith<$Res> implements $PayrollCopyWith<$Res> {
  factory _$$PayrollImplCopyWith(
    _$PayrollImpl value,
    $Res Function(_$PayrollImpl) then,
  ) = __$$PayrollImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String employeeId,
    String employeeName,
    @JsonKey(readValue: readTenantId) String tenantId,
    double baseSalary,
    double commissionTotal,
    double bonuses,
    double deductions,
    double netAmount,
    String period,
    String status,
    String? approvedBy,
    DateTime? paidAt,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class __$$PayrollImplCopyWithImpl<$Res>
    extends _$PayrollCopyWithImpl<$Res, _$PayrollImpl>
    implements _$$PayrollImplCopyWith<$Res> {
  __$$PayrollImplCopyWithImpl(
    _$PayrollImpl _value,
    $Res Function(_$PayrollImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Payroll
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? employeeId = null,
    Object? employeeName = null,
    Object? tenantId = null,
    Object? baseSalary = null,
    Object? commissionTotal = null,
    Object? bonuses = null,
    Object? deductions = null,
    Object? netAmount = null,
    Object? period = null,
    Object? status = null,
    Object? approvedBy = freezed,
    Object? paidAt = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$PayrollImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        employeeId: null == employeeId
            ? _value.employeeId
            : employeeId // ignore: cast_nullable_to_non_nullable
                  as String,
        employeeName: null == employeeName
            ? _value.employeeName
            : employeeName // ignore: cast_nullable_to_non_nullable
                  as String,
        tenantId: null == tenantId
            ? _value.tenantId
            : tenantId // ignore: cast_nullable_to_non_nullable
                  as String,
        baseSalary: null == baseSalary
            ? _value.baseSalary
            : baseSalary // ignore: cast_nullable_to_non_nullable
                  as double,
        commissionTotal: null == commissionTotal
            ? _value.commissionTotal
            : commissionTotal // ignore: cast_nullable_to_non_nullable
                  as double,
        bonuses: null == bonuses
            ? _value.bonuses
            : bonuses // ignore: cast_nullable_to_non_nullable
                  as double,
        deductions: null == deductions
            ? _value.deductions
            : deductions // ignore: cast_nullable_to_non_nullable
                  as double,
        netAmount: null == netAmount
            ? _value.netAmount
            : netAmount // ignore: cast_nullable_to_non_nullable
                  as double,
        period: null == period
            ? _value.period
            : period // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        approvedBy: freezed == approvedBy
            ? _value.approvedBy
            : approvedBy // ignore: cast_nullable_to_non_nullable
                  as String?,
        paidAt: freezed == paidAt
            ? _value.paidAt
            : paidAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
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
class _$PayrollImpl extends _Payroll {
  const _$PayrollImpl({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    @JsonKey(readValue: readTenantId) required this.tenantId,
    required this.baseSalary,
    required this.commissionTotal,
    required this.bonuses,
    required this.deductions,
    required this.netAmount,
    required this.period,
    required this.status,
    this.approvedBy,
    this.paidAt,
    required this.createdAt,
    required this.updatedAt,
  }) : super._();

  factory _$PayrollImpl.fromJson(Map<String, dynamic> json) =>
      _$$PayrollImplFromJson(json);

  @override
  final String id;
  @override
  final String employeeId;
  @override
  final String employeeName;
  @override
  @JsonKey(readValue: readTenantId)
  final String tenantId;
  @override
  final double baseSalary;
  @override
  final double commissionTotal;
  @override
  final double bonuses;
  @override
  final double deductions;
  @override
  final double netAmount;
  @override
  final String period;
  // e.g., "2026-06"
  @override
  final String status;
  // pending, approved, paid
  @override
  final String? approvedBy;
  @override
  final DateTime? paidAt;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'Payroll(id: $id, employeeId: $employeeId, employeeName: $employeeName, tenantId: $tenantId, baseSalary: $baseSalary, commissionTotal: $commissionTotal, bonuses: $bonuses, deductions: $deductions, netAmount: $netAmount, period: $period, status: $status, approvedBy: $approvedBy, paidAt: $paidAt, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PayrollImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.employeeId, employeeId) ||
                other.employeeId == employeeId) &&
            (identical(other.employeeName, employeeName) ||
                other.employeeName == employeeName) &&
            (identical(other.tenantId, tenantId) ||
                other.tenantId == tenantId) &&
            (identical(other.baseSalary, baseSalary) ||
                other.baseSalary == baseSalary) &&
            (identical(other.commissionTotal, commissionTotal) ||
                other.commissionTotal == commissionTotal) &&
            (identical(other.bonuses, bonuses) || other.bonuses == bonuses) &&
            (identical(other.deductions, deductions) ||
                other.deductions == deductions) &&
            (identical(other.netAmount, netAmount) ||
                other.netAmount == netAmount) &&
            (identical(other.period, period) || other.period == period) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.approvedBy, approvedBy) ||
                other.approvedBy == approvedBy) &&
            (identical(other.paidAt, paidAt) || other.paidAt == paidAt) &&
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
    employeeId,
    employeeName,
    tenantId,
    baseSalary,
    commissionTotal,
    bonuses,
    deductions,
    netAmount,
    period,
    status,
    approvedBy,
    paidAt,
    createdAt,
    updatedAt,
  );

  /// Create a copy of Payroll
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PayrollImplCopyWith<_$PayrollImpl> get copyWith =>
      __$$PayrollImplCopyWithImpl<_$PayrollImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PayrollImplToJson(this);
  }
}

abstract class _Payroll extends Payroll {
  const factory _Payroll({
    required final String id,
    required final String employeeId,
    required final String employeeName,
    @JsonKey(readValue: readTenantId) required final String tenantId,
    required final double baseSalary,
    required final double commissionTotal,
    required final double bonuses,
    required final double deductions,
    required final double netAmount,
    required final String period,
    required final String status,
    final String? approvedBy,
    final DateTime? paidAt,
    required final DateTime createdAt,
    required final DateTime updatedAt,
  }) = _$PayrollImpl;
  const _Payroll._() : super._();

  factory _Payroll.fromJson(Map<String, dynamic> json) = _$PayrollImpl.fromJson;

  @override
  String get id;
  @override
  String get employeeId;
  @override
  String get employeeName;
  @override
  @JsonKey(readValue: readTenantId)
  String get tenantId;
  @override
  double get baseSalary;
  @override
  double get commissionTotal;
  @override
  double get bonuses;
  @override
  double get deductions;
  @override
  double get netAmount;
  @override
  String get period; // e.g., "2026-06"
  @override
  String get status; // pending, approved, paid
  @override
  String? get approvedBy;
  @override
  DateTime? get paidAt;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of Payroll
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PayrollImplCopyWith<_$PayrollImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

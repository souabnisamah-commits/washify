// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'wallet.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Wallet _$WalletFromJson(Map<String, dynamic> json) {
  return _Wallet.fromJson(json);
}

/// @nodoc
mixin _$Wallet {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get userName => throw _privateConstructorUsedError;
  String get tenantId => throw _privateConstructorUsedError;
  double get walletBalanceCache =>
      throw _privateConstructorUsedError; // Solde calculé uniquement par Cloud Functions
  double get totalEarned => throw _privateConstructorUsedError;
  double get totalWithdrawn => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this Wallet to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Wallet
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WalletCopyWith<Wallet> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WalletCopyWith<$Res> {
  factory $WalletCopyWith(Wallet value, $Res Function(Wallet) then) =
      _$WalletCopyWithImpl<$Res, Wallet>;
  @useResult
  $Res call({
    String id,
    String userId,
    String userName,
    String tenantId,
    double walletBalanceCache,
    double totalEarned,
    double totalWithdrawn,
    DateTime updatedAt,
  });
}

/// @nodoc
class _$WalletCopyWithImpl<$Res, $Val extends Wallet>
    implements $WalletCopyWith<$Res> {
  _$WalletCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Wallet
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? userName = null,
    Object? tenantId = null,
    Object? walletBalanceCache = null,
    Object? totalEarned = null,
    Object? totalWithdrawn = null,
    Object? updatedAt = null,
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
            userName: null == userName
                ? _value.userName
                : userName // ignore: cast_nullable_to_non_nullable
                      as String,
            tenantId: null == tenantId
                ? _value.tenantId
                : tenantId // ignore: cast_nullable_to_non_nullable
                      as String,
            walletBalanceCache: null == walletBalanceCache
                ? _value.walletBalanceCache
                : walletBalanceCache // ignore: cast_nullable_to_non_nullable
                      as double,
            totalEarned: null == totalEarned
                ? _value.totalEarned
                : totalEarned // ignore: cast_nullable_to_non_nullable
                      as double,
            totalWithdrawn: null == totalWithdrawn
                ? _value.totalWithdrawn
                : totalWithdrawn // ignore: cast_nullable_to_non_nullable
                      as double,
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
abstract class _$$WalletImplCopyWith<$Res> implements $WalletCopyWith<$Res> {
  factory _$$WalletImplCopyWith(
    _$WalletImpl value,
    $Res Function(_$WalletImpl) then,
  ) = __$$WalletImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String userId,
    String userName,
    String tenantId,
    double walletBalanceCache,
    double totalEarned,
    double totalWithdrawn,
    DateTime updatedAt,
  });
}

/// @nodoc
class __$$WalletImplCopyWithImpl<$Res>
    extends _$WalletCopyWithImpl<$Res, _$WalletImpl>
    implements _$$WalletImplCopyWith<$Res> {
  __$$WalletImplCopyWithImpl(
    _$WalletImpl _value,
    $Res Function(_$WalletImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Wallet
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? userName = null,
    Object? tenantId = null,
    Object? walletBalanceCache = null,
    Object? totalEarned = null,
    Object? totalWithdrawn = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$WalletImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        userName: null == userName
            ? _value.userName
            : userName // ignore: cast_nullable_to_non_nullable
                  as String,
        tenantId: null == tenantId
            ? _value.tenantId
            : tenantId // ignore: cast_nullable_to_non_nullable
                  as String,
        walletBalanceCache: null == walletBalanceCache
            ? _value.walletBalanceCache
            : walletBalanceCache // ignore: cast_nullable_to_non_nullable
                  as double,
        totalEarned: null == totalEarned
            ? _value.totalEarned
            : totalEarned // ignore: cast_nullable_to_non_nullable
                  as double,
        totalWithdrawn: null == totalWithdrawn
            ? _value.totalWithdrawn
            : totalWithdrawn // ignore: cast_nullable_to_non_nullable
                  as double,
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
class _$WalletImpl extends _Wallet {
  const _$WalletImpl({
    required this.id,
    required this.userId,
    required this.userName,
    required this.tenantId,
    required this.walletBalanceCache,
    required this.totalEarned,
    required this.totalWithdrawn,
    required this.updatedAt,
  }) : super._();

  factory _$WalletImpl.fromJson(Map<String, dynamic> json) =>
      _$$WalletImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String userName;
  @override
  final String tenantId;
  @override
  final double walletBalanceCache;
  // Solde calculé uniquement par Cloud Functions
  @override
  final double totalEarned;
  @override
  final double totalWithdrawn;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'Wallet(id: $id, userId: $userId, userName: $userName, tenantId: $tenantId, walletBalanceCache: $walletBalanceCache, totalEarned: $totalEarned, totalWithdrawn: $totalWithdrawn, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WalletImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.userName, userName) ||
                other.userName == userName) &&
            (identical(other.tenantId, tenantId) ||
                other.tenantId == tenantId) &&
            (identical(other.walletBalanceCache, walletBalanceCache) ||
                other.walletBalanceCache == walletBalanceCache) &&
            (identical(other.totalEarned, totalEarned) ||
                other.totalEarned == totalEarned) &&
            (identical(other.totalWithdrawn, totalWithdrawn) ||
                other.totalWithdrawn == totalWithdrawn) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    userId,
    userName,
    tenantId,
    walletBalanceCache,
    totalEarned,
    totalWithdrawn,
    updatedAt,
  );

  /// Create a copy of Wallet
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WalletImplCopyWith<_$WalletImpl> get copyWith =>
      __$$WalletImplCopyWithImpl<_$WalletImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WalletImplToJson(this);
  }
}

abstract class _Wallet extends Wallet {
  const factory _Wallet({
    required final String id,
    required final String userId,
    required final String userName,
    required final String tenantId,
    required final double walletBalanceCache,
    required final double totalEarned,
    required final double totalWithdrawn,
    required final DateTime updatedAt,
  }) = _$WalletImpl;
  const _Wallet._() : super._();

  factory _Wallet.fromJson(Map<String, dynamic> json) = _$WalletImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get userName;
  @override
  String get tenantId;
  @override
  double get walletBalanceCache; // Solde calculé uniquement par Cloud Functions
  @override
  double get totalEarned;
  @override
  double get totalWithdrawn;
  @override
  DateTime get updatedAt;

  /// Create a copy of Wallet
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WalletImplCopyWith<_$WalletImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

WalletTransaction _$WalletTransactionFromJson(Map<String, dynamic> json) {
  return _WalletTransaction.fromJson(json);
}

/// @nodoc
mixin _$WalletTransaction {
  String get id => throw _privateConstructorUsedError;
  String get walletId => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get tenantId => throw _privateConstructorUsedError;
  WalletTransactionType get type =>
      throw _privateConstructorUsedError; // gain_ticket, bonus, retrait, ajustement
  double get amount => throw _privateConstructorUsedError;
  double get balanceBefore => throw _privateConstructorUsedError;
  double get balanceAfter => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String? get referenceId =>
      throw _privateConstructorUsedError; // ticketId reference
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this WalletTransaction to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WalletTransaction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WalletTransactionCopyWith<WalletTransaction> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WalletTransactionCopyWith<$Res> {
  factory $WalletTransactionCopyWith(
    WalletTransaction value,
    $Res Function(WalletTransaction) then,
  ) = _$WalletTransactionCopyWithImpl<$Res, WalletTransaction>;
  @useResult
  $Res call({
    String id,
    String walletId,
    String userId,
    String tenantId,
    WalletTransactionType type,
    double amount,
    double balanceBefore,
    double balanceAfter,
    String description,
    String? referenceId,
    DateTime createdAt,
  });
}

/// @nodoc
class _$WalletTransactionCopyWithImpl<$Res, $Val extends WalletTransaction>
    implements $WalletTransactionCopyWith<$Res> {
  _$WalletTransactionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WalletTransaction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? walletId = null,
    Object? userId = null,
    Object? tenantId = null,
    Object? type = null,
    Object? amount = null,
    Object? balanceBefore = null,
    Object? balanceAfter = null,
    Object? description = null,
    Object? referenceId = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            walletId: null == walletId
                ? _value.walletId
                : walletId // ignore: cast_nullable_to_non_nullable
                      as String,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            tenantId: null == tenantId
                ? _value.tenantId
                : tenantId // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as WalletTransactionType,
            amount: null == amount
                ? _value.amount
                : amount // ignore: cast_nullable_to_non_nullable
                      as double,
            balanceBefore: null == balanceBefore
                ? _value.balanceBefore
                : balanceBefore // ignore: cast_nullable_to_non_nullable
                      as double,
            balanceAfter: null == balanceAfter
                ? _value.balanceAfter
                : balanceAfter // ignore: cast_nullable_to_non_nullable
                      as double,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            referenceId: freezed == referenceId
                ? _value.referenceId
                : referenceId // ignore: cast_nullable_to_non_nullable
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
abstract class _$$WalletTransactionImplCopyWith<$Res>
    implements $WalletTransactionCopyWith<$Res> {
  factory _$$WalletTransactionImplCopyWith(
    _$WalletTransactionImpl value,
    $Res Function(_$WalletTransactionImpl) then,
  ) = __$$WalletTransactionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String walletId,
    String userId,
    String tenantId,
    WalletTransactionType type,
    double amount,
    double balanceBefore,
    double balanceAfter,
    String description,
    String? referenceId,
    DateTime createdAt,
  });
}

/// @nodoc
class __$$WalletTransactionImplCopyWithImpl<$Res>
    extends _$WalletTransactionCopyWithImpl<$Res, _$WalletTransactionImpl>
    implements _$$WalletTransactionImplCopyWith<$Res> {
  __$$WalletTransactionImplCopyWithImpl(
    _$WalletTransactionImpl _value,
    $Res Function(_$WalletTransactionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WalletTransaction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? walletId = null,
    Object? userId = null,
    Object? tenantId = null,
    Object? type = null,
    Object? amount = null,
    Object? balanceBefore = null,
    Object? balanceAfter = null,
    Object? description = null,
    Object? referenceId = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _$WalletTransactionImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        walletId: null == walletId
            ? _value.walletId
            : walletId // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        tenantId: null == tenantId
            ? _value.tenantId
            : tenantId // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as WalletTransactionType,
        amount: null == amount
            ? _value.amount
            : amount // ignore: cast_nullable_to_non_nullable
                  as double,
        balanceBefore: null == balanceBefore
            ? _value.balanceBefore
            : balanceBefore // ignore: cast_nullable_to_non_nullable
                  as double,
        balanceAfter: null == balanceAfter
            ? _value.balanceAfter
            : balanceAfter // ignore: cast_nullable_to_non_nullable
                  as double,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        referenceId: freezed == referenceId
            ? _value.referenceId
            : referenceId // ignore: cast_nullable_to_non_nullable
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
class _$WalletTransactionImpl extends _WalletTransaction {
  const _$WalletTransactionImpl({
    required this.id,
    required this.walletId,
    required this.userId,
    required this.tenantId,
    required this.type,
    required this.amount,
    required this.balanceBefore,
    required this.balanceAfter,
    required this.description,
    this.referenceId,
    required this.createdAt,
  }) : super._();

  factory _$WalletTransactionImpl.fromJson(Map<String, dynamic> json) =>
      _$$WalletTransactionImplFromJson(json);

  @override
  final String id;
  @override
  final String walletId;
  @override
  final String userId;
  @override
  final String tenantId;
  @override
  final WalletTransactionType type;
  // gain_ticket, bonus, retrait, ajustement
  @override
  final double amount;
  @override
  final double balanceBefore;
  @override
  final double balanceAfter;
  @override
  final String description;
  @override
  final String? referenceId;
  // ticketId reference
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'WalletTransaction(id: $id, walletId: $walletId, userId: $userId, tenantId: $tenantId, type: $type, amount: $amount, balanceBefore: $balanceBefore, balanceAfter: $balanceAfter, description: $description, referenceId: $referenceId, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WalletTransactionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.walletId, walletId) ||
                other.walletId == walletId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.tenantId, tenantId) ||
                other.tenantId == tenantId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.balanceBefore, balanceBefore) ||
                other.balanceBefore == balanceBefore) &&
            (identical(other.balanceAfter, balanceAfter) ||
                other.balanceAfter == balanceAfter) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.referenceId, referenceId) ||
                other.referenceId == referenceId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    walletId,
    userId,
    tenantId,
    type,
    amount,
    balanceBefore,
    balanceAfter,
    description,
    referenceId,
    createdAt,
  );

  /// Create a copy of WalletTransaction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WalletTransactionImplCopyWith<_$WalletTransactionImpl> get copyWith =>
      __$$WalletTransactionImplCopyWithImpl<_$WalletTransactionImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$WalletTransactionImplToJson(this);
  }
}

abstract class _WalletTransaction extends WalletTransaction {
  const factory _WalletTransaction({
    required final String id,
    required final String walletId,
    required final String userId,
    required final String tenantId,
    required final WalletTransactionType type,
    required final double amount,
    required final double balanceBefore,
    required final double balanceAfter,
    required final String description,
    final String? referenceId,
    required final DateTime createdAt,
  }) = _$WalletTransactionImpl;
  const _WalletTransaction._() : super._();

  factory _WalletTransaction.fromJson(Map<String, dynamic> json) =
      _$WalletTransactionImpl.fromJson;

  @override
  String get id;
  @override
  String get walletId;
  @override
  String get userId;
  @override
  String get tenantId;
  @override
  WalletTransactionType get type; // gain_ticket, bonus, retrait, ajustement
  @override
  double get amount;
  @override
  double get balanceBefore;
  @override
  double get balanceAfter;
  @override
  String get description;
  @override
  String? get referenceId; // ticketId reference
  @override
  DateTime get createdAt;

  /// Create a copy of WalletTransaction
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WalletTransactionImplCopyWith<_$WalletTransactionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

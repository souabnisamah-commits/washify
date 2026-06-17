// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'stock.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

StockLevel _$StockLevelFromJson(Map<String, dynamic> json) {
  return _StockLevel.fromJson(json);
}

/// @nodoc
mixin _$StockLevel {
  String get id => throw _privateConstructorUsedError;
  String get tenantId => throw _privateConstructorUsedError;
  String get productId => throw _privateConstructorUsedError;
  String get productName => throw _privateConstructorUsedError;
  int get currentQuantity =>
      throw _privateConstructorUsedError; // Consommation en unités entières
  int get minStock => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this StockLevel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StockLevel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StockLevelCopyWith<StockLevel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StockLevelCopyWith<$Res> {
  factory $StockLevelCopyWith(
    StockLevel value,
    $Res Function(StockLevel) then,
  ) = _$StockLevelCopyWithImpl<$Res, StockLevel>;
  @useResult
  $Res call({
    String id,
    String tenantId,
    String productId,
    String productName,
    int currentQuantity,
    int minStock,
    DateTime updatedAt,
  });
}

/// @nodoc
class _$StockLevelCopyWithImpl<$Res, $Val extends StockLevel>
    implements $StockLevelCopyWith<$Res> {
  _$StockLevelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StockLevel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tenantId = null,
    Object? productId = null,
    Object? productName = null,
    Object? currentQuantity = null,
    Object? minStock = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            tenantId: null == tenantId
                ? _value.tenantId
                : tenantId // ignore: cast_nullable_to_non_nullable
                      as String,
            productId: null == productId
                ? _value.productId
                : productId // ignore: cast_nullable_to_non_nullable
                      as String,
            productName: null == productName
                ? _value.productName
                : productName // ignore: cast_nullable_to_non_nullable
                      as String,
            currentQuantity: null == currentQuantity
                ? _value.currentQuantity
                : currentQuantity // ignore: cast_nullable_to_non_nullable
                      as int,
            minStock: null == minStock
                ? _value.minStock
                : minStock // ignore: cast_nullable_to_non_nullable
                      as int,
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
abstract class _$$StockLevelImplCopyWith<$Res>
    implements $StockLevelCopyWith<$Res> {
  factory _$$StockLevelImplCopyWith(
    _$StockLevelImpl value,
    $Res Function(_$StockLevelImpl) then,
  ) = __$$StockLevelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String tenantId,
    String productId,
    String productName,
    int currentQuantity,
    int minStock,
    DateTime updatedAt,
  });
}

/// @nodoc
class __$$StockLevelImplCopyWithImpl<$Res>
    extends _$StockLevelCopyWithImpl<$Res, _$StockLevelImpl>
    implements _$$StockLevelImplCopyWith<$Res> {
  __$$StockLevelImplCopyWithImpl(
    _$StockLevelImpl _value,
    $Res Function(_$StockLevelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of StockLevel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tenantId = null,
    Object? productId = null,
    Object? productName = null,
    Object? currentQuantity = null,
    Object? minStock = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$StockLevelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        tenantId: null == tenantId
            ? _value.tenantId
            : tenantId // ignore: cast_nullable_to_non_nullable
                  as String,
        productId: null == productId
            ? _value.productId
            : productId // ignore: cast_nullable_to_non_nullable
                  as String,
        productName: null == productName
            ? _value.productName
            : productName // ignore: cast_nullable_to_non_nullable
                  as String,
        currentQuantity: null == currentQuantity
            ? _value.currentQuantity
            : currentQuantity // ignore: cast_nullable_to_non_nullable
                  as int,
        minStock: null == minStock
            ? _value.minStock
            : minStock // ignore: cast_nullable_to_non_nullable
                  as int,
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
class _$StockLevelImpl extends _StockLevel {
  const _$StockLevelImpl({
    required this.id,
    required this.tenantId,
    required this.productId,
    required this.productName,
    required this.currentQuantity,
    required this.minStock,
    required this.updatedAt,
  }) : super._();

  factory _$StockLevelImpl.fromJson(Map<String, dynamic> json) =>
      _$$StockLevelImplFromJson(json);

  @override
  final String id;
  @override
  final String tenantId;
  @override
  final String productId;
  @override
  final String productName;
  @override
  final int currentQuantity;
  // Consommation en unités entières
  @override
  final int minStock;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'StockLevel(id: $id, tenantId: $tenantId, productId: $productId, productName: $productName, currentQuantity: $currentQuantity, minStock: $minStock, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StockLevelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.tenantId, tenantId) ||
                other.tenantId == tenantId) &&
            (identical(other.productId, productId) ||
                other.productId == productId) &&
            (identical(other.productName, productName) ||
                other.productName == productName) &&
            (identical(other.currentQuantity, currentQuantity) ||
                other.currentQuantity == currentQuantity) &&
            (identical(other.minStock, minStock) ||
                other.minStock == minStock) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    tenantId,
    productId,
    productName,
    currentQuantity,
    minStock,
    updatedAt,
  );

  /// Create a copy of StockLevel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StockLevelImplCopyWith<_$StockLevelImpl> get copyWith =>
      __$$StockLevelImplCopyWithImpl<_$StockLevelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StockLevelImplToJson(this);
  }
}

abstract class _StockLevel extends StockLevel {
  const factory _StockLevel({
    required final String id,
    required final String tenantId,
    required final String productId,
    required final String productName,
    required final int currentQuantity,
    required final int minStock,
    required final DateTime updatedAt,
  }) = _$StockLevelImpl;
  const _StockLevel._() : super._();

  factory _StockLevel.fromJson(Map<String, dynamic> json) =
      _$StockLevelImpl.fromJson;

  @override
  String get id;
  @override
  String get tenantId;
  @override
  String get productId;
  @override
  String get productName;
  @override
  int get currentQuantity; // Consommation en unités entières
  @override
  int get minStock;
  @override
  DateTime get updatedAt;

  /// Create a copy of StockLevel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StockLevelImplCopyWith<_$StockLevelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

StockMovement _$StockMovementFromJson(Map<String, dynamic> json) {
  return _StockMovement.fromJson(json);
}

/// @nodoc
mixin _$StockMovement {
  String get id => throw _privateConstructorUsedError;
  String get tenantId => throw _privateConstructorUsedError;
  String get productId => throw _privateConstructorUsedError;
  String get productName => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError; // in, out, adjustment
  int get quantity => throw _privateConstructorUsedError;
  int get previousQuantity => throw _privateConstructorUsedError;
  int get newQuantity => throw _privateConstructorUsedError;
  String get reason => throw _privateConstructorUsedError;
  String get performedBy => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this StockMovement to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StockMovement
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StockMovementCopyWith<StockMovement> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StockMovementCopyWith<$Res> {
  factory $StockMovementCopyWith(
    StockMovement value,
    $Res Function(StockMovement) then,
  ) = _$StockMovementCopyWithImpl<$Res, StockMovement>;
  @useResult
  $Res call({
    String id,
    String tenantId,
    String productId,
    String productName,
    String type,
    int quantity,
    int previousQuantity,
    int newQuantity,
    String reason,
    String performedBy,
    DateTime createdAt,
  });
}

/// @nodoc
class _$StockMovementCopyWithImpl<$Res, $Val extends StockMovement>
    implements $StockMovementCopyWith<$Res> {
  _$StockMovementCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StockMovement
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tenantId = null,
    Object? productId = null,
    Object? productName = null,
    Object? type = null,
    Object? quantity = null,
    Object? previousQuantity = null,
    Object? newQuantity = null,
    Object? reason = null,
    Object? performedBy = null,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            tenantId: null == tenantId
                ? _value.tenantId
                : tenantId // ignore: cast_nullable_to_non_nullable
                      as String,
            productId: null == productId
                ? _value.productId
                : productId // ignore: cast_nullable_to_non_nullable
                      as String,
            productName: null == productName
                ? _value.productName
                : productName // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as String,
            quantity: null == quantity
                ? _value.quantity
                : quantity // ignore: cast_nullable_to_non_nullable
                      as int,
            previousQuantity: null == previousQuantity
                ? _value.previousQuantity
                : previousQuantity // ignore: cast_nullable_to_non_nullable
                      as int,
            newQuantity: null == newQuantity
                ? _value.newQuantity
                : newQuantity // ignore: cast_nullable_to_non_nullable
                      as int,
            reason: null == reason
                ? _value.reason
                : reason // ignore: cast_nullable_to_non_nullable
                      as String,
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
abstract class _$$StockMovementImplCopyWith<$Res>
    implements $StockMovementCopyWith<$Res> {
  factory _$$StockMovementImplCopyWith(
    _$StockMovementImpl value,
    $Res Function(_$StockMovementImpl) then,
  ) = __$$StockMovementImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String tenantId,
    String productId,
    String productName,
    String type,
    int quantity,
    int previousQuantity,
    int newQuantity,
    String reason,
    String performedBy,
    DateTime createdAt,
  });
}

/// @nodoc
class __$$StockMovementImplCopyWithImpl<$Res>
    extends _$StockMovementCopyWithImpl<$Res, _$StockMovementImpl>
    implements _$$StockMovementImplCopyWith<$Res> {
  __$$StockMovementImplCopyWithImpl(
    _$StockMovementImpl _value,
    $Res Function(_$StockMovementImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of StockMovement
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tenantId = null,
    Object? productId = null,
    Object? productName = null,
    Object? type = null,
    Object? quantity = null,
    Object? previousQuantity = null,
    Object? newQuantity = null,
    Object? reason = null,
    Object? performedBy = null,
    Object? createdAt = null,
  }) {
    return _then(
      _$StockMovementImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        tenantId: null == tenantId
            ? _value.tenantId
            : tenantId // ignore: cast_nullable_to_non_nullable
                  as String,
        productId: null == productId
            ? _value.productId
            : productId // ignore: cast_nullable_to_non_nullable
                  as String,
        productName: null == productName
            ? _value.productName
            : productName // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String,
        quantity: null == quantity
            ? _value.quantity
            : quantity // ignore: cast_nullable_to_non_nullable
                  as int,
        previousQuantity: null == previousQuantity
            ? _value.previousQuantity
            : previousQuantity // ignore: cast_nullable_to_non_nullable
                  as int,
        newQuantity: null == newQuantity
            ? _value.newQuantity
            : newQuantity // ignore: cast_nullable_to_non_nullable
                  as int,
        reason: null == reason
            ? _value.reason
            : reason // ignore: cast_nullable_to_non_nullable
                  as String,
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
class _$StockMovementImpl extends _StockMovement {
  const _$StockMovementImpl({
    required this.id,
    required this.tenantId,
    required this.productId,
    required this.productName,
    required this.type,
    required this.quantity,
    required this.previousQuantity,
    required this.newQuantity,
    required this.reason,
    required this.performedBy,
    required this.createdAt,
  }) : super._();

  factory _$StockMovementImpl.fromJson(Map<String, dynamic> json) =>
      _$$StockMovementImplFromJson(json);

  @override
  final String id;
  @override
  final String tenantId;
  @override
  final String productId;
  @override
  final String productName;
  @override
  final String type;
  // in, out, adjustment
  @override
  final int quantity;
  @override
  final int previousQuantity;
  @override
  final int newQuantity;
  @override
  final String reason;
  @override
  final String performedBy;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'StockMovement(id: $id, tenantId: $tenantId, productId: $productId, productName: $productName, type: $type, quantity: $quantity, previousQuantity: $previousQuantity, newQuantity: $newQuantity, reason: $reason, performedBy: $performedBy, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StockMovementImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.tenantId, tenantId) ||
                other.tenantId == tenantId) &&
            (identical(other.productId, productId) ||
                other.productId == productId) &&
            (identical(other.productName, productName) ||
                other.productName == productName) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.previousQuantity, previousQuantity) ||
                other.previousQuantity == previousQuantity) &&
            (identical(other.newQuantity, newQuantity) ||
                other.newQuantity == newQuantity) &&
            (identical(other.reason, reason) || other.reason == reason) &&
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
    tenantId,
    productId,
    productName,
    type,
    quantity,
    previousQuantity,
    newQuantity,
    reason,
    performedBy,
    createdAt,
  );

  /// Create a copy of StockMovement
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StockMovementImplCopyWith<_$StockMovementImpl> get copyWith =>
      __$$StockMovementImplCopyWithImpl<_$StockMovementImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StockMovementImplToJson(this);
  }
}

abstract class _StockMovement extends StockMovement {
  const factory _StockMovement({
    required final String id,
    required final String tenantId,
    required final String productId,
    required final String productName,
    required final String type,
    required final int quantity,
    required final int previousQuantity,
    required final int newQuantity,
    required final String reason,
    required final String performedBy,
    required final DateTime createdAt,
  }) = _$StockMovementImpl;
  const _StockMovement._() : super._();

  factory _StockMovement.fromJson(Map<String, dynamic> json) =
      _$StockMovementImpl.fromJson;

  @override
  String get id;
  @override
  String get tenantId;
  @override
  String get productId;
  @override
  String get productName;
  @override
  String get type; // in, out, adjustment
  @override
  int get quantity;
  @override
  int get previousQuantity;
  @override
  int get newQuantity;
  @override
  String get reason;
  @override
  String get performedBy;
  @override
  DateTime get createdAt;

  /// Create a copy of StockMovement
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StockMovementImplCopyWith<_$StockMovementImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

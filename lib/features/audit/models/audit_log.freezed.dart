// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'audit_log.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

AuditLog _$AuditLogFromJson(Map<String, dynamic> json) {
  return _AuditLog.fromJson(json);
}

/// @nodoc
mixin _$AuditLog {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(readValue: readTenantId)
  String get tenantId => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get userName => throw _privateConstructorUsedError;
  String get action =>
      throw _privateConstructorUsedError; // ticket_paye, ticket_rembourse, stock_modifie, wallet_ajuste, licence_modifiee
  String get module =>
      throw _privateConstructorUsedError; // tickets, stock, wallet, admin
  String get description => throw _privateConstructorUsedError;
  Map<String, dynamic>? get previousData => throw _privateConstructorUsedError;
  Map<String, dynamic>? get newData => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this AuditLog to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AuditLog
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AuditLogCopyWith<AuditLog> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AuditLogCopyWith<$Res> {
  factory $AuditLogCopyWith(AuditLog value, $Res Function(AuditLog) then) =
      _$AuditLogCopyWithImpl<$Res, AuditLog>;
  @useResult
  $Res call({
    String id,
    @JsonKey(readValue: readTenantId) String tenantId,
    String userId,
    String userName,
    String action,
    String module,
    String description,
    Map<String, dynamic>? previousData,
    Map<String, dynamic>? newData,
    DateTime createdAt,
  });
}

/// @nodoc
class _$AuditLogCopyWithImpl<$Res, $Val extends AuditLog>
    implements $AuditLogCopyWith<$Res> {
  _$AuditLogCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AuditLog
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tenantId = null,
    Object? userId = null,
    Object? userName = null,
    Object? action = null,
    Object? module = null,
    Object? description = null,
    Object? previousData = freezed,
    Object? newData = freezed,
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
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            userName: null == userName
                ? _value.userName
                : userName // ignore: cast_nullable_to_non_nullable
                      as String,
            action: null == action
                ? _value.action
                : action // ignore: cast_nullable_to_non_nullable
                      as String,
            module: null == module
                ? _value.module
                : module // ignore: cast_nullable_to_non_nullable
                      as String,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            previousData: freezed == previousData
                ? _value.previousData
                : previousData // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
            newData: freezed == newData
                ? _value.newData
                : newData // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
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
abstract class _$$AuditLogImplCopyWith<$Res>
    implements $AuditLogCopyWith<$Res> {
  factory _$$AuditLogImplCopyWith(
    _$AuditLogImpl value,
    $Res Function(_$AuditLogImpl) then,
  ) = __$$AuditLogImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(readValue: readTenantId) String tenantId,
    String userId,
    String userName,
    String action,
    String module,
    String description,
    Map<String, dynamic>? previousData,
    Map<String, dynamic>? newData,
    DateTime createdAt,
  });
}

/// @nodoc
class __$$AuditLogImplCopyWithImpl<$Res>
    extends _$AuditLogCopyWithImpl<$Res, _$AuditLogImpl>
    implements _$$AuditLogImplCopyWith<$Res> {
  __$$AuditLogImplCopyWithImpl(
    _$AuditLogImpl _value,
    $Res Function(_$AuditLogImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AuditLog
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tenantId = null,
    Object? userId = null,
    Object? userName = null,
    Object? action = null,
    Object? module = null,
    Object? description = null,
    Object? previousData = freezed,
    Object? newData = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _$AuditLogImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        tenantId: null == tenantId
            ? _value.tenantId
            : tenantId // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        userName: null == userName
            ? _value.userName
            : userName // ignore: cast_nullable_to_non_nullable
                  as String,
        action: null == action
            ? _value.action
            : action // ignore: cast_nullable_to_non_nullable
                  as String,
        module: null == module
            ? _value.module
            : module // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        previousData: freezed == previousData
            ? _value._previousData
            : previousData // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
        newData: freezed == newData
            ? _value._newData
            : newData // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
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
class _$AuditLogImpl extends _AuditLog {
  const _$AuditLogImpl({
    required this.id,
    @JsonKey(readValue: readTenantId) required this.tenantId,
    required this.userId,
    required this.userName,
    required this.action,
    required this.module,
    required this.description,
    final Map<String, dynamic>? previousData,
    final Map<String, dynamic>? newData,
    required this.createdAt,
  }) : _previousData = previousData,
       _newData = newData,
       super._();

  factory _$AuditLogImpl.fromJson(Map<String, dynamic> json) =>
      _$$AuditLogImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(readValue: readTenantId)
  final String tenantId;
  @override
  final String userId;
  @override
  final String userName;
  @override
  final String action;
  // ticket_paye, ticket_rembourse, stock_modifie, wallet_ajuste, licence_modifiee
  @override
  final String module;
  // tickets, stock, wallet, admin
  @override
  final String description;
  final Map<String, dynamic>? _previousData;
  @override
  Map<String, dynamic>? get previousData {
    final value = _previousData;
    if (value == null) return null;
    if (_previousData is EqualUnmodifiableMapView) return _previousData;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  final Map<String, dynamic>? _newData;
  @override
  Map<String, dynamic>? get newData {
    final value = _newData;
    if (value == null) return null;
    if (_newData is EqualUnmodifiableMapView) return _newData;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'AuditLog(id: $id, tenantId: $tenantId, userId: $userId, userName: $userName, action: $action, module: $module, description: $description, previousData: $previousData, newData: $newData, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AuditLogImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.tenantId, tenantId) ||
                other.tenantId == tenantId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.userName, userName) ||
                other.userName == userName) &&
            (identical(other.action, action) || other.action == action) &&
            (identical(other.module, module) || other.module == module) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality().equals(
              other._previousData,
              _previousData,
            ) &&
            const DeepCollectionEquality().equals(other._newData, _newData) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    tenantId,
    userId,
    userName,
    action,
    module,
    description,
    const DeepCollectionEquality().hash(_previousData),
    const DeepCollectionEquality().hash(_newData),
    createdAt,
  );

  /// Create a copy of AuditLog
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AuditLogImplCopyWith<_$AuditLogImpl> get copyWith =>
      __$$AuditLogImplCopyWithImpl<_$AuditLogImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AuditLogImplToJson(this);
  }
}

abstract class _AuditLog extends AuditLog {
  const factory _AuditLog({
    required final String id,
    @JsonKey(readValue: readTenantId) required final String tenantId,
    required final String userId,
    required final String userName,
    required final String action,
    required final String module,
    required final String description,
    final Map<String, dynamic>? previousData,
    final Map<String, dynamic>? newData,
    required final DateTime createdAt,
  }) = _$AuditLogImpl;
  const _AuditLog._() : super._();

  factory _AuditLog.fromJson(Map<String, dynamic> json) =
      _$AuditLogImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(readValue: readTenantId)
  String get tenantId;
  @override
  String get userId;
  @override
  String get userName;
  @override
  String get action; // ticket_paye, ticket_rembourse, stock_modifie, wallet_ajuste, licence_modifiee
  @override
  String get module; // tickets, stock, wallet, admin
  @override
  String get description;
  @override
  Map<String, dynamic>? get previousData;
  @override
  Map<String, dynamic>? get newData;
  @override
  DateTime get createdAt;

  /// Create a copy of AuditLog
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AuditLogImplCopyWith<_$AuditLogImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

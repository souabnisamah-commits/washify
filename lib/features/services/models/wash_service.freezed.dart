// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'wash_service.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

WashService _$WashServiceFromJson(Map<String, dynamic> json) {
  return _WashService.fromJson(json);
}

/// @nodoc
mixin _$WashService {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(readValue: readTenantId)
  String get tenantId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  double get price => throw _privateConstructorUsedError;
  int get durationMinutes => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this WashService to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WashService
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WashServiceCopyWith<WashService> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WashServiceCopyWith<$Res> {
  factory $WashServiceCopyWith(
    WashService value,
    $Res Function(WashService) then,
  ) = _$WashServiceCopyWithImpl<$Res, WashService>;
  @useResult
  $Res call({
    String id,
    @JsonKey(readValue: readTenantId) String tenantId,
    String name,
    String description,
    double price,
    int durationMinutes,
    bool isActive,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class _$WashServiceCopyWithImpl<$Res, $Val extends WashService>
    implements $WashServiceCopyWith<$Res> {
  _$WashServiceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WashService
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tenantId = null,
    Object? name = null,
    Object? description = null,
    Object? price = null,
    Object? durationMinutes = null,
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
            tenantId: null == tenantId
                ? _value.tenantId
                : tenantId // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            price: null == price
                ? _value.price
                : price // ignore: cast_nullable_to_non_nullable
                      as double,
            durationMinutes: null == durationMinutes
                ? _value.durationMinutes
                : durationMinutes // ignore: cast_nullable_to_non_nullable
                      as int,
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
abstract class _$$WashServiceImplCopyWith<$Res>
    implements $WashServiceCopyWith<$Res> {
  factory _$$WashServiceImplCopyWith(
    _$WashServiceImpl value,
    $Res Function(_$WashServiceImpl) then,
  ) = __$$WashServiceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(readValue: readTenantId) String tenantId,
    String name,
    String description,
    double price,
    int durationMinutes,
    bool isActive,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class __$$WashServiceImplCopyWithImpl<$Res>
    extends _$WashServiceCopyWithImpl<$Res, _$WashServiceImpl>
    implements _$$WashServiceImplCopyWith<$Res> {
  __$$WashServiceImplCopyWithImpl(
    _$WashServiceImpl _value,
    $Res Function(_$WashServiceImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WashService
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tenantId = null,
    Object? name = null,
    Object? description = null,
    Object? price = null,
    Object? durationMinutes = null,
    Object? isActive = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$WashServiceImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        tenantId: null == tenantId
            ? _value.tenantId
            : tenantId // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        price: null == price
            ? _value.price
            : price // ignore: cast_nullable_to_non_nullable
                  as double,
        durationMinutes: null == durationMinutes
            ? _value.durationMinutes
            : durationMinutes // ignore: cast_nullable_to_non_nullable
                  as int,
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
class _$WashServiceImpl extends _WashService {
  const _$WashServiceImpl({
    required this.id,
    @JsonKey(readValue: readTenantId) required this.tenantId,
    required this.name,
    required this.description,
    required this.price,
    required this.durationMinutes,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  }) : super._();

  factory _$WashServiceImpl.fromJson(Map<String, dynamic> json) =>
      _$$WashServiceImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(readValue: readTenantId)
  final String tenantId;
  @override
  final String name;
  @override
  final String description;
  @override
  final double price;
  @override
  final int durationMinutes;
  @override
  @JsonKey()
  final bool isActive;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'WashService(id: $id, tenantId: $tenantId, name: $name, description: $description, price: $price, durationMinutes: $durationMinutes, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WashServiceImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.tenantId, tenantId) ||
                other.tenantId == tenantId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.durationMinutes, durationMinutes) ||
                other.durationMinutes == durationMinutes) &&
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
    tenantId,
    name,
    description,
    price,
    durationMinutes,
    isActive,
    createdAt,
    updatedAt,
  );

  /// Create a copy of WashService
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WashServiceImplCopyWith<_$WashServiceImpl> get copyWith =>
      __$$WashServiceImplCopyWithImpl<_$WashServiceImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WashServiceImplToJson(this);
  }
}

abstract class _WashService extends WashService {
  const factory _WashService({
    required final String id,
    @JsonKey(readValue: readTenantId) required final String tenantId,
    required final String name,
    required final String description,
    required final double price,
    required final int durationMinutes,
    final bool isActive,
    required final DateTime createdAt,
    required final DateTime updatedAt,
  }) = _$WashServiceImpl;
  const _WashService._() : super._();

  factory _WashService.fromJson(Map<String, dynamic> json) =
      _$WashServiceImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(readValue: readTenantId)
  String get tenantId;
  @override
  String get name;
  @override
  String get description;
  @override
  double get price;
  @override
  int get durationMinutes;
  @override
  bool get isActive;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of WashService
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WashServiceImplCopyWith<_$WashServiceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

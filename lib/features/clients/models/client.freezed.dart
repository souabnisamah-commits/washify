// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'client.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Client _$ClientFromJson(Map<String, dynamic> json) {
  return _Client.fromJson(json);
}

/// @nodoc
mixin _$Client {
  String get id => throw _privateConstructorUsedError;
  String get tenantId => throw _privateConstructorUsedError;
  String get companyName => throw _privateConstructorUsedError;
  String get contactName => throw _privateConstructorUsedError;
  String get taxId => throw _privateConstructorUsedError; // Matricule Fiscale
  String get phone => throw _privateConstructorUsedError;
  double get alertThreshold =>
      throw _privateConstructorUsedError; // Seuil d'alerte
  double get currentBalance =>
      throw _privateConstructorUsedError; // Montant total non payé
  @VehicleListConverter()
  List<ClientVehicle> get vehicles => throw _privateConstructorUsedError; // Véhicules du client
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this Client to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Client
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ClientCopyWith<Client> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ClientCopyWith<$Res> {
  factory $ClientCopyWith(Client value, $Res Function(Client) then) =
      _$ClientCopyWithImpl<$Res, Client>;
  @useResult
  $Res call({
    String id,
    String tenantId,
    String companyName,
    String contactName,
    String taxId,
    String phone,
    double alertThreshold,
    double currentBalance,
    @VehicleListConverter() List<ClientVehicle> vehicles,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class _$ClientCopyWithImpl<$Res, $Val extends Client>
    implements $ClientCopyWith<$Res> {
  _$ClientCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Client
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tenantId = null,
    Object? companyName = null,
    Object? contactName = null,
    Object? taxId = null,
    Object? phone = null,
    Object? alertThreshold = null,
    Object? currentBalance = null,
    Object? vehicles = null,
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
            companyName: null == companyName
                ? _value.companyName
                : companyName // ignore: cast_nullable_to_non_nullable
                      as String,
            contactName: null == contactName
                ? _value.contactName
                : contactName // ignore: cast_nullable_to_non_nullable
                      as String,
            taxId: null == taxId
                ? _value.taxId
                : taxId // ignore: cast_nullable_to_non_nullable
                      as String,
            phone: null == phone
                ? _value.phone
                : phone // ignore: cast_nullable_to_non_nullable
                      as String,
            alertThreshold: null == alertThreshold
                ? _value.alertThreshold
                : alertThreshold // ignore: cast_nullable_to_non_nullable
                      as double,
            currentBalance: null == currentBalance
                ? _value.currentBalance
                : currentBalance // ignore: cast_nullable_to_non_nullable
                      as double,
            vehicles: null == vehicles
                ? _value.vehicles
                : vehicles // ignore: cast_nullable_to_non_nullable
                      as List<ClientVehicle>,
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
abstract class _$$ClientImplCopyWith<$Res> implements $ClientCopyWith<$Res> {
  factory _$$ClientImplCopyWith(
    _$ClientImpl value,
    $Res Function(_$ClientImpl) then,
  ) = __$$ClientImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String tenantId,
    String companyName,
    String contactName,
    String taxId,
    String phone,
    double alertThreshold,
    double currentBalance,
    @VehicleListConverter() List<ClientVehicle> vehicles,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class __$$ClientImplCopyWithImpl<$Res>
    extends _$ClientCopyWithImpl<$Res, _$ClientImpl>
    implements _$$ClientImplCopyWith<$Res> {
  __$$ClientImplCopyWithImpl(
    _$ClientImpl _value,
    $Res Function(_$ClientImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Client
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tenantId = null,
    Object? companyName = null,
    Object? contactName = null,
    Object? taxId = null,
    Object? phone = null,
    Object? alertThreshold = null,
    Object? currentBalance = null,
    Object? vehicles = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$ClientImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        tenantId: null == tenantId
            ? _value.tenantId
            : tenantId // ignore: cast_nullable_to_non_nullable
                  as String,
        companyName: null == companyName
            ? _value.companyName
            : companyName // ignore: cast_nullable_to_non_nullable
                  as String,
        contactName: null == contactName
            ? _value.contactName
            : contactName // ignore: cast_nullable_to_non_nullable
                  as String,
        taxId: null == taxId
            ? _value.taxId
            : taxId // ignore: cast_nullable_to_non_nullable
                  as String,
        phone: null == phone
            ? _value.phone
            : phone // ignore: cast_nullable_to_non_nullable
                  as String,
        alertThreshold: null == alertThreshold
            ? _value.alertThreshold
            : alertThreshold // ignore: cast_nullable_to_non_nullable
                  as double,
        currentBalance: null == currentBalance
            ? _value.currentBalance
            : currentBalance // ignore: cast_nullable_to_non_nullable
                  as double,
        vehicles: null == vehicles
            ? _value._vehicles
            : vehicles // ignore: cast_nullable_to_non_nullable
                  as List<ClientVehicle>,
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
class _$ClientImpl implements _Client {
  const _$ClientImpl({
    required this.id,
    required this.tenantId,
    required this.companyName,
    required this.contactName,
    required this.taxId,
    required this.phone,
    this.alertThreshold = 0.0,
    this.currentBalance = 0.0,
    @VehicleListConverter() final List<ClientVehicle> vehicles = const [],
    required this.createdAt,
    required this.updatedAt,
  }) : _vehicles = vehicles;

  factory _$ClientImpl.fromJson(Map<String, dynamic> json) =>
      _$$ClientImplFromJson(json);

  @override
  final String id;
  @override
  final String tenantId;
  @override
  final String companyName;
  @override
  final String contactName;
  @override
  final String taxId;
  // Matricule Fiscale
  @override
  final String phone;
  @override
  @JsonKey()
  final double alertThreshold;
  // Seuil d'alerte
  @override
  @JsonKey()
  final double currentBalance;
  // Montant total non payé
  final List<ClientVehicle> _vehicles;
  // Montant total non payé
  @override
  @JsonKey()
  @VehicleListConverter()
  List<ClientVehicle> get vehicles {
    if (_vehicles is EqualUnmodifiableListView) return _vehicles;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_vehicles);
  }

  // Véhicules du client
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'Client(id: $id, tenantId: $tenantId, companyName: $companyName, contactName: $contactName, taxId: $taxId, phone: $phone, alertThreshold: $alertThreshold, currentBalance: $currentBalance, vehicles: $vehicles, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ClientImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.tenantId, tenantId) ||
                other.tenantId == tenantId) &&
            (identical(other.companyName, companyName) ||
                other.companyName == companyName) &&
            (identical(other.contactName, contactName) ||
                other.contactName == contactName) &&
            (identical(other.taxId, taxId) || other.taxId == taxId) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.alertThreshold, alertThreshold) ||
                other.alertThreshold == alertThreshold) &&
            (identical(other.currentBalance, currentBalance) ||
                other.currentBalance == currentBalance) &&
            const DeepCollectionEquality().equals(other._vehicles, _vehicles) &&
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
    companyName,
    contactName,
    taxId,
    phone,
    alertThreshold,
    currentBalance,
    const DeepCollectionEquality().hash(_vehicles),
    createdAt,
    updatedAt,
  );

  /// Create a copy of Client
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ClientImplCopyWith<_$ClientImpl> get copyWith =>
      __$$ClientImplCopyWithImpl<_$ClientImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ClientImplToJson(this);
  }
}

abstract class _Client implements Client {
  const factory _Client({
    required final String id,
    required final String tenantId,
    required final String companyName,
    required final String contactName,
    required final String taxId,
    required final String phone,
    final double alertThreshold,
    final double currentBalance,
    @VehicleListConverter() final List<ClientVehicle> vehicles,
    required final DateTime createdAt,
    required final DateTime updatedAt,
  }) = _$ClientImpl;

  factory _Client.fromJson(Map<String, dynamic> json) = _$ClientImpl.fromJson;

  @override
  String get id;
  @override
  String get tenantId;
  @override
  String get companyName;
  @override
  String get contactName;
  @override
  String get taxId; // Matricule Fiscale
  @override
  String get phone;
  @override
  double get alertThreshold; // Seuil d'alerte
  @override
  double get currentBalance; // Montant total non payé
  @override
  @VehicleListConverter()
  List<ClientVehicle> get vehicles; // Véhicules du client
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of Client
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ClientImplCopyWith<_$ClientImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

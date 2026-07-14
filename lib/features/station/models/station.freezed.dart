// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'station.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Station _$StationFromJson(Map<String, dynamic> json) {
  return _Station.fromJson(json);
}

/// @nodoc
mixin _$Station {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(readValue: readTenantId)
  String get tenantId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get gerantName => throw _privateConstructorUsedError;
  String get phone => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  String get matriculeFiscale => throw _privateConstructorUsedError;
  double get latitude => throw _privateConstructorUsedError;
  double get longitude => throw _privateConstructorUsedError;
  String get logoUrl => throw _privateConstructorUsedError;
  LicenceStatus get licence => throw _privateConstructorUsedError;
  DateTime? get subscriptionDate => throw _privateConstructorUsedError;
  DateTime? get expiryDate => throw _privateConstructorUsedError;
  String get address => throw _privateConstructorUsedError;
  String get city => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this Station to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Station
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StationCopyWith<Station> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StationCopyWith<$Res> {
  factory $StationCopyWith(Station value, $Res Function(Station) then) =
      _$StationCopyWithImpl<$Res, Station>;
  @useResult
  $Res call({
    String id,
    @JsonKey(readValue: readTenantId) String tenantId,
    String name,
    String gerantName,
    String phone,
    String email,
    String matriculeFiscale,
    double latitude,
    double longitude,
    String logoUrl,
    LicenceStatus licence,
    DateTime? subscriptionDate,
    DateTime? expiryDate,
    String address,
    String city,
    bool isActive,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class _$StationCopyWithImpl<$Res, $Val extends Station>
    implements $StationCopyWith<$Res> {
  _$StationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Station
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tenantId = null,
    Object? name = null,
    Object? gerantName = null,
    Object? phone = null,
    Object? email = null,
    Object? matriculeFiscale = null,
    Object? latitude = null,
    Object? longitude = null,
    Object? logoUrl = null,
    Object? licence = null,
    Object? subscriptionDate = freezed,
    Object? expiryDate = freezed,
    Object? address = null,
    Object? city = null,
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
            gerantName: null == gerantName
                ? _value.gerantName
                : gerantName // ignore: cast_nullable_to_non_nullable
                      as String,
            phone: null == phone
                ? _value.phone
                : phone // ignore: cast_nullable_to_non_nullable
                      as String,
            email: null == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String,
            matriculeFiscale: null == matriculeFiscale
                ? _value.matriculeFiscale
                : matriculeFiscale // ignore: cast_nullable_to_non_nullable
                      as String,
            latitude: null == latitude
                ? _value.latitude
                : latitude // ignore: cast_nullable_to_non_nullable
                      as double,
            longitude: null == longitude
                ? _value.longitude
                : longitude // ignore: cast_nullable_to_non_nullable
                      as double,
            logoUrl: null == logoUrl
                ? _value.logoUrl
                : logoUrl // ignore: cast_nullable_to_non_nullable
                      as String,
            licence: null == licence
                ? _value.licence
                : licence // ignore: cast_nullable_to_non_nullable
                      as LicenceStatus,
            subscriptionDate: freezed == subscriptionDate
                ? _value.subscriptionDate
                : subscriptionDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            expiryDate: freezed == expiryDate
                ? _value.expiryDate
                : expiryDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            address: null == address
                ? _value.address
                : address // ignore: cast_nullable_to_non_nullable
                      as String,
            city: null == city
                ? _value.city
                : city // ignore: cast_nullable_to_non_nullable
                      as String,
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
abstract class _$$StationImplCopyWith<$Res> implements $StationCopyWith<$Res> {
  factory _$$StationImplCopyWith(
    _$StationImpl value,
    $Res Function(_$StationImpl) then,
  ) = __$$StationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(readValue: readTenantId) String tenantId,
    String name,
    String gerantName,
    String phone,
    String email,
    String matriculeFiscale,
    double latitude,
    double longitude,
    String logoUrl,
    LicenceStatus licence,
    DateTime? subscriptionDate,
    DateTime? expiryDate,
    String address,
    String city,
    bool isActive,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class __$$StationImplCopyWithImpl<$Res>
    extends _$StationCopyWithImpl<$Res, _$StationImpl>
    implements _$$StationImplCopyWith<$Res> {
  __$$StationImplCopyWithImpl(
    _$StationImpl _value,
    $Res Function(_$StationImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Station
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tenantId = null,
    Object? name = null,
    Object? gerantName = null,
    Object? phone = null,
    Object? email = null,
    Object? matriculeFiscale = null,
    Object? latitude = null,
    Object? longitude = null,
    Object? logoUrl = null,
    Object? licence = null,
    Object? subscriptionDate = freezed,
    Object? expiryDate = freezed,
    Object? address = null,
    Object? city = null,
    Object? isActive = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$StationImpl(
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
        gerantName: null == gerantName
            ? _value.gerantName
            : gerantName // ignore: cast_nullable_to_non_nullable
                  as String,
        phone: null == phone
            ? _value.phone
            : phone // ignore: cast_nullable_to_non_nullable
                  as String,
        email: null == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String,
        matriculeFiscale: null == matriculeFiscale
            ? _value.matriculeFiscale
            : matriculeFiscale // ignore: cast_nullable_to_non_nullable
                  as String,
        latitude: null == latitude
            ? _value.latitude
            : latitude // ignore: cast_nullable_to_non_nullable
                  as double,
        longitude: null == longitude
            ? _value.longitude
            : longitude // ignore: cast_nullable_to_non_nullable
                  as double,
        logoUrl: null == logoUrl
            ? _value.logoUrl
            : logoUrl // ignore: cast_nullable_to_non_nullable
                  as String,
        licence: null == licence
            ? _value.licence
            : licence // ignore: cast_nullable_to_non_nullable
                  as LicenceStatus,
        subscriptionDate: freezed == subscriptionDate
            ? _value.subscriptionDate
            : subscriptionDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        expiryDate: freezed == expiryDate
            ? _value.expiryDate
            : expiryDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        address: null == address
            ? _value.address
            : address // ignore: cast_nullable_to_non_nullable
                  as String,
        city: null == city
            ? _value.city
            : city // ignore: cast_nullable_to_non_nullable
                  as String,
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
class _$StationImpl extends _Station {
  const _$StationImpl({
    required this.id,
    @JsonKey(readValue: readTenantId) required this.tenantId,
    required this.name,
    required this.gerantName,
    required this.phone,
    required this.email,
    required this.matriculeFiscale,
    required this.latitude,
    required this.longitude,
    required this.logoUrl,
    required this.licence,
    this.subscriptionDate,
    this.expiryDate,
    this.address = '',
    this.city = '',
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  }) : super._();

  factory _$StationImpl.fromJson(Map<String, dynamic> json) =>
      _$$StationImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(readValue: readTenantId)
  final String tenantId;
  @override
  final String name;
  @override
  final String gerantName;
  @override
  final String phone;
  @override
  final String email;
  @override
  final String matriculeFiscale;
  @override
  final double latitude;
  @override
  final double longitude;
  @override
  final String logoUrl;
  @override
  final LicenceStatus licence;
  @override
  final DateTime? subscriptionDate;
  @override
  final DateTime? expiryDate;
  @override
  @JsonKey()
  final String address;
  @override
  @JsonKey()
  final String city;
  @override
  @JsonKey()
  final bool isActive;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'Station(id: $id, tenantId: $tenantId, name: $name, gerantName: $gerantName, phone: $phone, email: $email, matriculeFiscale: $matriculeFiscale, latitude: $latitude, longitude: $longitude, logoUrl: $logoUrl, licence: $licence, subscriptionDate: $subscriptionDate, expiryDate: $expiryDate, address: $address, city: $city, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StationImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.tenantId, tenantId) ||
                other.tenantId == tenantId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.gerantName, gerantName) ||
                other.gerantName == gerantName) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.matriculeFiscale, matriculeFiscale) ||
                other.matriculeFiscale == matriculeFiscale) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl) &&
            (identical(other.licence, licence) || other.licence == licence) &&
            (identical(other.subscriptionDate, subscriptionDate) ||
                other.subscriptionDate == subscriptionDate) &&
            (identical(other.expiryDate, expiryDate) ||
                other.expiryDate == expiryDate) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.city, city) || other.city == city) &&
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
    gerantName,
    phone,
    email,
    matriculeFiscale,
    latitude,
    longitude,
    logoUrl,
    licence,
    subscriptionDate,
    expiryDate,
    address,
    city,
    isActive,
    createdAt,
    updatedAt,
  );

  /// Create a copy of Station
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StationImplCopyWith<_$StationImpl> get copyWith =>
      __$$StationImplCopyWithImpl<_$StationImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StationImplToJson(this);
  }
}

abstract class _Station extends Station {
  const factory _Station({
    required final String id,
    @JsonKey(readValue: readTenantId) required final String tenantId,
    required final String name,
    required final String gerantName,
    required final String phone,
    required final String email,
    required final String matriculeFiscale,
    required final double latitude,
    required final double longitude,
    required final String logoUrl,
    required final LicenceStatus licence,
    final DateTime? subscriptionDate,
    final DateTime? expiryDate,
    final String address,
    final String city,
    final bool isActive,
    required final DateTime createdAt,
    required final DateTime updatedAt,
  }) = _$StationImpl;
  const _Station._() : super._();

  factory _Station.fromJson(Map<String, dynamic> json) = _$StationImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(readValue: readTenantId)
  String get tenantId;
  @override
  String get name;
  @override
  String get gerantName;
  @override
  String get phone;
  @override
  String get email;
  @override
  String get matriculeFiscale;
  @override
  double get latitude;
  @override
  double get longitude;
  @override
  String get logoUrl;
  @override
  LicenceStatus get licence;
  @override
  DateTime? get subscriptionDate;
  @override
  DateTime? get expiryDate;
  @override
  String get address;
  @override
  String get city;
  @override
  bool get isActive;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of Station
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StationImplCopyWith<_$StationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

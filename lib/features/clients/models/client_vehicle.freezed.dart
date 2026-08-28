// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'client_vehicle.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ClientVehicle _$ClientVehicleFromJson(Map<String, dynamic> json) {
  return _ClientVehicle.fromJson(json);
}

/// @nodoc
mixin _$ClientVehicle {
  String get plate => throw _privateConstructorUsedError;
  String get brand => throw _privateConstructorUsedError;
  String get model => throw _privateConstructorUsedError;
  String get categoryId => throw _privateConstructorUsedError;
  bool get isBlocked => throw _privateConstructorUsedError;
  String get blockedReason => throw _privateConstructorUsedError;

  /// Serializes this ClientVehicle to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ClientVehicle
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ClientVehicleCopyWith<ClientVehicle> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ClientVehicleCopyWith<$Res> {
  factory $ClientVehicleCopyWith(
    ClientVehicle value,
    $Res Function(ClientVehicle) then,
  ) = _$ClientVehicleCopyWithImpl<$Res, ClientVehicle>;
  @useResult
  $Res call({
    String plate,
    String brand,
    String model,
    String categoryId,
    bool isBlocked,
    String blockedReason,
  });
}

/// @nodoc
class _$ClientVehicleCopyWithImpl<$Res, $Val extends ClientVehicle>
    implements $ClientVehicleCopyWith<$Res> {
  _$ClientVehicleCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ClientVehicle
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? plate = null,
    Object? brand = null,
    Object? model = null,
    Object? categoryId = null,
    Object? isBlocked = null,
    Object? blockedReason = null,
  }) {
    return _then(
      _value.copyWith(
            plate: null == plate
                ? _value.plate
                : plate // ignore: cast_nullable_to_non_nullable
                      as String,
            brand: null == brand
                ? _value.brand
                : brand // ignore: cast_nullable_to_non_nullable
                      as String,
            model: null == model
                ? _value.model
                : model // ignore: cast_nullable_to_non_nullable
                      as String,
            categoryId: null == categoryId
                ? _value.categoryId
                : categoryId // ignore: cast_nullable_to_non_nullable
                      as String,
            isBlocked: null == isBlocked
                ? _value.isBlocked
                : isBlocked // ignore: cast_nullable_to_non_nullable
                      as bool,
            blockedReason: null == blockedReason
                ? _value.blockedReason
                : blockedReason // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ClientVehicleImplCopyWith<$Res>
    implements $ClientVehicleCopyWith<$Res> {
  factory _$$ClientVehicleImplCopyWith(
    _$ClientVehicleImpl value,
    $Res Function(_$ClientVehicleImpl) then,
  ) = __$$ClientVehicleImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String plate,
    String brand,
    String model,
    String categoryId,
    bool isBlocked,
    String blockedReason,
  });
}

/// @nodoc
class __$$ClientVehicleImplCopyWithImpl<$Res>
    extends _$ClientVehicleCopyWithImpl<$Res, _$ClientVehicleImpl>
    implements _$$ClientVehicleImplCopyWith<$Res> {
  __$$ClientVehicleImplCopyWithImpl(
    _$ClientVehicleImpl _value,
    $Res Function(_$ClientVehicleImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ClientVehicle
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? plate = null,
    Object? brand = null,
    Object? model = null,
    Object? categoryId = null,
    Object? isBlocked = null,
    Object? blockedReason = null,
  }) {
    return _then(
      _$ClientVehicleImpl(
        plate: null == plate
            ? _value.plate
            : plate // ignore: cast_nullable_to_non_nullable
                  as String,
        brand: null == brand
            ? _value.brand
            : brand // ignore: cast_nullable_to_non_nullable
                  as String,
        model: null == model
            ? _value.model
            : model // ignore: cast_nullable_to_non_nullable
                  as String,
        categoryId: null == categoryId
            ? _value.categoryId
            : categoryId // ignore: cast_nullable_to_non_nullable
                  as String,
        isBlocked: null == isBlocked
            ? _value.isBlocked
            : isBlocked // ignore: cast_nullable_to_non_nullable
                  as bool,
        blockedReason: null == blockedReason
            ? _value.blockedReason
            : blockedReason // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ClientVehicleImpl implements _ClientVehicle {
  const _$ClientVehicleImpl({
    required this.plate,
    this.brand = '',
    this.model = '',
    this.categoryId = '',
    this.isBlocked = false,
    this.blockedReason = '',
  });

  factory _$ClientVehicleImpl.fromJson(Map<String, dynamic> json) =>
      _$$ClientVehicleImplFromJson(json);

  @override
  final String plate;
  @override
  @JsonKey()
  final String brand;
  @override
  @JsonKey()
  final String model;
  @override
  @JsonKey()
  final String categoryId;
  @override
  @JsonKey()
  final bool isBlocked;
  @override
  @JsonKey()
  final String blockedReason;

  @override
  String toString() {
    return 'ClientVehicle(plate: $plate, brand: $brand, model: $model, categoryId: $categoryId, isBlocked: $isBlocked, blockedReason: $blockedReason)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ClientVehicleImpl &&
            (identical(other.plate, plate) || other.plate == plate) &&
            (identical(other.brand, brand) || other.brand == brand) &&
            (identical(other.model, model) || other.model == model) &&
            (identical(other.categoryId, categoryId) ||
                other.categoryId == categoryId) &&
            (identical(other.isBlocked, isBlocked) ||
                other.isBlocked == isBlocked) &&
            (identical(other.blockedReason, blockedReason) ||
                other.blockedReason == blockedReason));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    plate,
    brand,
    model,
    categoryId,
    isBlocked,
    blockedReason,
  );

  /// Create a copy of ClientVehicle
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ClientVehicleImplCopyWith<_$ClientVehicleImpl> get copyWith =>
      __$$ClientVehicleImplCopyWithImpl<_$ClientVehicleImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ClientVehicleImplToJson(this);
  }
}

abstract class _ClientVehicle implements ClientVehicle {
  const factory _ClientVehicle({
    required final String plate,
    final String brand,
    final String model,
    final String categoryId,
    final bool isBlocked,
    final String blockedReason,
  }) = _$ClientVehicleImpl;

  factory _ClientVehicle.fromJson(Map<String, dynamic> json) =
      _$ClientVehicleImpl.fromJson;

  @override
  String get plate;
  @override
  String get brand;
  @override
  String get model;
  @override
  String get categoryId;
  @override
  bool get isBlocked;
  @override
  String get blockedReason;

  /// Create a copy of ClientVehicle
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ClientVehicleImplCopyWith<_$ClientVehicleImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

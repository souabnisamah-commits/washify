// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'client_payment.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ClientPayment _$ClientPaymentFromJson(Map<String, dynamic> json) {
  return _ClientPayment.fromJson(json);
}

/// @nodoc
mixin _$ClientPayment {
  String get id => throw _privateConstructorUsedError;
  String get clientId => throw _privateConstructorUsedError;
  @JsonKey(readValue: readTenantId)
  String get tenantId => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  String get paymentMethod =>
      throw _privateConstructorUsedError; // Espèces, Chèque, Virement...
  String? get reference =>
      throw _privateConstructorUsedError; // Numéro de chèque, référence virement...
  String get createdBy =>
      throw _privateConstructorUsedError; // ID ou Nom de la personne qui a enregistré le paiement
  DateTime get paymentDate => throw _privateConstructorUsedError;

  /// Serializes this ClientPayment to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ClientPayment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ClientPaymentCopyWith<ClientPayment> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ClientPaymentCopyWith<$Res> {
  factory $ClientPaymentCopyWith(
    ClientPayment value,
    $Res Function(ClientPayment) then,
  ) = _$ClientPaymentCopyWithImpl<$Res, ClientPayment>;
  @useResult
  $Res call({
    String id,
    String clientId,
    @JsonKey(readValue: readTenantId) String tenantId,
    double amount,
    String paymentMethod,
    String? reference,
    String createdBy,
    DateTime paymentDate,
  });
}

/// @nodoc
class _$ClientPaymentCopyWithImpl<$Res, $Val extends ClientPayment>
    implements $ClientPaymentCopyWith<$Res> {
  _$ClientPaymentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ClientPayment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? clientId = null,
    Object? tenantId = null,
    Object? amount = null,
    Object? paymentMethod = null,
    Object? reference = freezed,
    Object? createdBy = null,
    Object? paymentDate = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            clientId: null == clientId
                ? _value.clientId
                : clientId // ignore: cast_nullable_to_non_nullable
                      as String,
            tenantId: null == tenantId
                ? _value.tenantId
                : tenantId // ignore: cast_nullable_to_non_nullable
                      as String,
            amount: null == amount
                ? _value.amount
                : amount // ignore: cast_nullable_to_non_nullable
                      as double,
            paymentMethod: null == paymentMethod
                ? _value.paymentMethod
                : paymentMethod // ignore: cast_nullable_to_non_nullable
                      as String,
            reference: freezed == reference
                ? _value.reference
                : reference // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdBy: null == createdBy
                ? _value.createdBy
                : createdBy // ignore: cast_nullable_to_non_nullable
                      as String,
            paymentDate: null == paymentDate
                ? _value.paymentDate
                : paymentDate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ClientPaymentImplCopyWith<$Res>
    implements $ClientPaymentCopyWith<$Res> {
  factory _$$ClientPaymentImplCopyWith(
    _$ClientPaymentImpl value,
    $Res Function(_$ClientPaymentImpl) then,
  ) = __$$ClientPaymentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String clientId,
    @JsonKey(readValue: readTenantId) String tenantId,
    double amount,
    String paymentMethod,
    String? reference,
    String createdBy,
    DateTime paymentDate,
  });
}

/// @nodoc
class __$$ClientPaymentImplCopyWithImpl<$Res>
    extends _$ClientPaymentCopyWithImpl<$Res, _$ClientPaymentImpl>
    implements _$$ClientPaymentImplCopyWith<$Res> {
  __$$ClientPaymentImplCopyWithImpl(
    _$ClientPaymentImpl _value,
    $Res Function(_$ClientPaymentImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ClientPayment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? clientId = null,
    Object? tenantId = null,
    Object? amount = null,
    Object? paymentMethod = null,
    Object? reference = freezed,
    Object? createdBy = null,
    Object? paymentDate = null,
  }) {
    return _then(
      _$ClientPaymentImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        clientId: null == clientId
            ? _value.clientId
            : clientId // ignore: cast_nullable_to_non_nullable
                  as String,
        tenantId: null == tenantId
            ? _value.tenantId
            : tenantId // ignore: cast_nullable_to_non_nullable
                  as String,
        amount: null == amount
            ? _value.amount
            : amount // ignore: cast_nullable_to_non_nullable
                  as double,
        paymentMethod: null == paymentMethod
            ? _value.paymentMethod
            : paymentMethod // ignore: cast_nullable_to_non_nullable
                  as String,
        reference: freezed == reference
            ? _value.reference
            : reference // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdBy: null == createdBy
            ? _value.createdBy
            : createdBy // ignore: cast_nullable_to_non_nullable
                  as String,
        paymentDate: null == paymentDate
            ? _value.paymentDate
            : paymentDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ClientPaymentImpl implements _ClientPayment {
  const _$ClientPaymentImpl({
    required this.id,
    required this.clientId,
    @JsonKey(readValue: readTenantId) required this.tenantId,
    required this.amount,
    required this.paymentMethod,
    this.reference,
    required this.createdBy,
    required this.paymentDate,
  });

  factory _$ClientPaymentImpl.fromJson(Map<String, dynamic> json) =>
      _$$ClientPaymentImplFromJson(json);

  @override
  final String id;
  @override
  final String clientId;
  @override
  @JsonKey(readValue: readTenantId)
  final String tenantId;
  @override
  final double amount;
  @override
  final String paymentMethod;
  // Espèces, Chèque, Virement...
  @override
  final String? reference;
  // Numéro de chèque, référence virement...
  @override
  final String createdBy;
  // ID ou Nom de la personne qui a enregistré le paiement
  @override
  final DateTime paymentDate;

  @override
  String toString() {
    return 'ClientPayment(id: $id, clientId: $clientId, tenantId: $tenantId, amount: $amount, paymentMethod: $paymentMethod, reference: $reference, createdBy: $createdBy, paymentDate: $paymentDate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ClientPaymentImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.clientId, clientId) ||
                other.clientId == clientId) &&
            (identical(other.tenantId, tenantId) ||
                other.tenantId == tenantId) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.paymentMethod, paymentMethod) ||
                other.paymentMethod == paymentMethod) &&
            (identical(other.reference, reference) ||
                other.reference == reference) &&
            (identical(other.createdBy, createdBy) ||
                other.createdBy == createdBy) &&
            (identical(other.paymentDate, paymentDate) ||
                other.paymentDate == paymentDate));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    clientId,
    tenantId,
    amount,
    paymentMethod,
    reference,
    createdBy,
    paymentDate,
  );

  /// Create a copy of ClientPayment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ClientPaymentImplCopyWith<_$ClientPaymentImpl> get copyWith =>
      __$$ClientPaymentImplCopyWithImpl<_$ClientPaymentImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ClientPaymentImplToJson(this);
  }
}

abstract class _ClientPayment implements ClientPayment {
  const factory _ClientPayment({
    required final String id,
    required final String clientId,
    @JsonKey(readValue: readTenantId) required final String tenantId,
    required final double amount,
    required final String paymentMethod,
    final String? reference,
    required final String createdBy,
    required final DateTime paymentDate,
  }) = _$ClientPaymentImpl;

  factory _ClientPayment.fromJson(Map<String, dynamic> json) =
      _$ClientPaymentImpl.fromJson;

  @override
  String get id;
  @override
  String get clientId;
  @override
  @JsonKey(readValue: readTenantId)
  String get tenantId;
  @override
  double get amount;
  @override
  String get paymentMethod; // Espèces, Chèque, Virement...
  @override
  String? get reference; // Numéro de chèque, référence virement...
  @override
  String get createdBy; // ID ou Nom de la personne qui a enregistré le paiement
  @override
  DateTime get paymentDate;

  /// Create a copy of ClientPayment
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ClientPaymentImplCopyWith<_$ClientPaymentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

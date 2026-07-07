// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ticket.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

TicketProduct _$TicketProductFromJson(Map<String, dynamic> json) {
  return _TicketProduct.fromJson(json);
}

/// @nodoc
mixin _$TicketProduct {
  String get productId => throw _privateConstructorUsedError;
  String get productName => throw _privateConstructorUsedError;
  int get quantity => throw _privateConstructorUsedError;
  double get unitPrice => throw _privateConstructorUsedError;

  /// Serializes this TicketProduct to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TicketProduct
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TicketProductCopyWith<TicketProduct> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TicketProductCopyWith<$Res> {
  factory $TicketProductCopyWith(
    TicketProduct value,
    $Res Function(TicketProduct) then,
  ) = _$TicketProductCopyWithImpl<$Res, TicketProduct>;
  @useResult
  $Res call({
    String productId,
    String productName,
    int quantity,
    double unitPrice,
  });
}

/// @nodoc
class _$TicketProductCopyWithImpl<$Res, $Val extends TicketProduct>
    implements $TicketProductCopyWith<$Res> {
  _$TicketProductCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TicketProduct
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? productId = null,
    Object? productName = null,
    Object? quantity = null,
    Object? unitPrice = null,
  }) {
    return _then(
      _value.copyWith(
            productId: null == productId
                ? _value.productId
                : productId // ignore: cast_nullable_to_non_nullable
                      as String,
            productName: null == productName
                ? _value.productName
                : productName // ignore: cast_nullable_to_non_nullable
                      as String,
            quantity: null == quantity
                ? _value.quantity
                : quantity // ignore: cast_nullable_to_non_nullable
                      as int,
            unitPrice: null == unitPrice
                ? _value.unitPrice
                : unitPrice // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TicketProductImplCopyWith<$Res>
    implements $TicketProductCopyWith<$Res> {
  factory _$$TicketProductImplCopyWith(
    _$TicketProductImpl value,
    $Res Function(_$TicketProductImpl) then,
  ) = __$$TicketProductImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String productId,
    String productName,
    int quantity,
    double unitPrice,
  });
}

/// @nodoc
class __$$TicketProductImplCopyWithImpl<$Res>
    extends _$TicketProductCopyWithImpl<$Res, _$TicketProductImpl>
    implements _$$TicketProductImplCopyWith<$Res> {
  __$$TicketProductImplCopyWithImpl(
    _$TicketProductImpl _value,
    $Res Function(_$TicketProductImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TicketProduct
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? productId = null,
    Object? productName = null,
    Object? quantity = null,
    Object? unitPrice = null,
  }) {
    return _then(
      _$TicketProductImpl(
        productId: null == productId
            ? _value.productId
            : productId // ignore: cast_nullable_to_non_nullable
                  as String,
        productName: null == productName
            ? _value.productName
            : productName // ignore: cast_nullable_to_non_nullable
                  as String,
        quantity: null == quantity
            ? _value.quantity
            : quantity // ignore: cast_nullable_to_non_nullable
                  as int,
        unitPrice: null == unitPrice
            ? _value.unitPrice
            : unitPrice // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TicketProductImpl extends _TicketProduct {
  const _$TicketProductImpl({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
  }) : super._();

  factory _$TicketProductImpl.fromJson(Map<String, dynamic> json) =>
      _$$TicketProductImplFromJson(json);

  @override
  final String productId;
  @override
  final String productName;
  @override
  final int quantity;
  @override
  final double unitPrice;

  @override
  String toString() {
    return 'TicketProduct(productId: $productId, productName: $productName, quantity: $quantity, unitPrice: $unitPrice)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TicketProductImpl &&
            (identical(other.productId, productId) ||
                other.productId == productId) &&
            (identical(other.productName, productName) ||
                other.productName == productName) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.unitPrice, unitPrice) ||
                other.unitPrice == unitPrice));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, productId, productName, quantity, unitPrice);

  /// Create a copy of TicketProduct
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TicketProductImplCopyWith<_$TicketProductImpl> get copyWith =>
      __$$TicketProductImplCopyWithImpl<_$TicketProductImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TicketProductImplToJson(this);
  }
}

abstract class _TicketProduct extends TicketProduct {
  const factory _TicketProduct({
    required final String productId,
    required final String productName,
    required final int quantity,
    required final double unitPrice,
  }) = _$TicketProductImpl;
  const _TicketProduct._() : super._();

  factory _TicketProduct.fromJson(Map<String, dynamic> json) =
      _$TicketProductImpl.fromJson;

  @override
  String get productId;
  @override
  String get productName;
  @override
  int get quantity;
  @override
  double get unitPrice;

  /// Create a copy of TicketProduct
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TicketProductImplCopyWith<_$TicketProductImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TicketService _$TicketServiceFromJson(Map<String, dynamic> json) {
  return _TicketService.fromJson(json);
}

/// @nodoc
mixin _$TicketService {
  String get serviceId => throw _privateConstructorUsedError;
  String get serviceName => throw _privateConstructorUsedError;
  double get price => throw _privateConstructorUsedError;

  /// Serializes this TicketService to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TicketService
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TicketServiceCopyWith<TicketService> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TicketServiceCopyWith<$Res> {
  factory $TicketServiceCopyWith(
    TicketService value,
    $Res Function(TicketService) then,
  ) = _$TicketServiceCopyWithImpl<$Res, TicketService>;
  @useResult
  $Res call({String serviceId, String serviceName, double price});
}

/// @nodoc
class _$TicketServiceCopyWithImpl<$Res, $Val extends TicketService>
    implements $TicketServiceCopyWith<$Res> {
  _$TicketServiceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TicketService
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? serviceId = null,
    Object? serviceName = null,
    Object? price = null,
  }) {
    return _then(
      _value.copyWith(
            serviceId: null == serviceId
                ? _value.serviceId
                : serviceId // ignore: cast_nullable_to_non_nullable
                      as String,
            serviceName: null == serviceName
                ? _value.serviceName
                : serviceName // ignore: cast_nullable_to_non_nullable
                      as String,
            price: null == price
                ? _value.price
                : price // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TicketServiceImplCopyWith<$Res>
    implements $TicketServiceCopyWith<$Res> {
  factory _$$TicketServiceImplCopyWith(
    _$TicketServiceImpl value,
    $Res Function(_$TicketServiceImpl) then,
  ) = __$$TicketServiceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String serviceId, String serviceName, double price});
}

/// @nodoc
class __$$TicketServiceImplCopyWithImpl<$Res>
    extends _$TicketServiceCopyWithImpl<$Res, _$TicketServiceImpl>
    implements _$$TicketServiceImplCopyWith<$Res> {
  __$$TicketServiceImplCopyWithImpl(
    _$TicketServiceImpl _value,
    $Res Function(_$TicketServiceImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TicketService
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? serviceId = null,
    Object? serviceName = null,
    Object? price = null,
  }) {
    return _then(
      _$TicketServiceImpl(
        serviceId: null == serviceId
            ? _value.serviceId
            : serviceId // ignore: cast_nullable_to_non_nullable
                  as String,
        serviceName: null == serviceName
            ? _value.serviceName
            : serviceName // ignore: cast_nullable_to_non_nullable
                  as String,
        price: null == price
            ? _value.price
            : price // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TicketServiceImpl implements _TicketService {
  const _$TicketServiceImpl({
    required this.serviceId,
    required this.serviceName,
    required this.price,
  });

  factory _$TicketServiceImpl.fromJson(Map<String, dynamic> json) =>
      _$$TicketServiceImplFromJson(json);

  @override
  final String serviceId;
  @override
  final String serviceName;
  @override
  final double price;

  @override
  String toString() {
    return 'TicketService(serviceId: $serviceId, serviceName: $serviceName, price: $price)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TicketServiceImpl &&
            (identical(other.serviceId, serviceId) ||
                other.serviceId == serviceId) &&
            (identical(other.serviceName, serviceName) ||
                other.serviceName == serviceName) &&
            (identical(other.price, price) || other.price == price));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, serviceId, serviceName, price);

  /// Create a copy of TicketService
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TicketServiceImplCopyWith<_$TicketServiceImpl> get copyWith =>
      __$$TicketServiceImplCopyWithImpl<_$TicketServiceImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TicketServiceImplToJson(this);
  }
}

abstract class _TicketService implements TicketService {
  const factory _TicketService({
    required final String serviceId,
    required final String serviceName,
    required final double price,
  }) = _$TicketServiceImpl;

  factory _TicketService.fromJson(Map<String, dynamic> json) =
      _$TicketServiceImpl.fromJson;

  @override
  String get serviceId;
  @override
  String get serviceName;
  @override
  double get price;

  /// Create a copy of TicketService
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TicketServiceImplCopyWith<_$TicketServiceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Ticket _$TicketFromJson(Map<String, dynamic> json) {
  return _Ticket.fromJson(json);
}

/// @nodoc
mixin _$Ticket {
  String get id => throw _privateConstructorUsedError; // Firestore Document ID
  String get tenantId => throw _privateConstructorUsedError; // stationId
  String get ticketNumber =>
      throw _privateConstructorUsedError; // ST-{station}-{date}-{heure}-{random}
  String get createdBy =>
      throw _privateConstructorUsedError; // Creator (Worker or Cashier)
  String? get paidBy => throw _privateConstructorUsedError; // Paid cashier
  String? get approvedBy => throw _privateConstructorUsedError; // Approver
  TicketStatus get status =>
      throw _privateConstructorUsedError; // en_attente, paye, rembourse
  double get montant =>
      throw _privateConstructorUsedError; // Total ticket amount
  Map<String, dynamic> get snapshotPrice =>
      throw _privateConstructorUsedError; // Anti-fraud snapshot of service prices
  List<String> get photosAvant =>
      throw _privateConstructorUsedError; // Photos before wash
  List<String> get photosApres =>
      throw _privateConstructorUsedError; // Photos after wash
  String? get vehiclePlate => throw _privateConstructorUsedError;
  String? get vehicleCategoryId =>
      throw _privateConstructorUsedError; // Added to map to Category ID for doses
  String? get vehicleType =>
      throw _privateConstructorUsedError; // Category Name
  String? get vehicleBrand => throw _privateConstructorUsedError;
  String? get vehicleModel => throw _privateConstructorUsedError;
  String? get clientId =>
      throw _privateConstructorUsedError; // B2B client account ID
  String? get clientName => throw _privateConstructorUsedError;
  String? get clientPhone => throw _privateConstructorUsedError;
  String? get paymentMethod =>
      throw _privateConstructorUsedError; // Espèces, TPE, Compte Client
  String? get assignedWorkerId => throw _privateConstructorUsedError;
  String? get assignedWorkerName => throw _privateConstructorUsedError;
  String? get serviceId => throw _privateConstructorUsedError;
  String? get serviceName => throw _privateConstructorUsedError;
  List<TicketService> get servicesSelected =>
      throw _privateConstructorUsedError;
  List<TicketProduct> get productsUsed => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this Ticket to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Ticket
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TicketCopyWith<Ticket> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TicketCopyWith<$Res> {
  factory $TicketCopyWith(Ticket value, $Res Function(Ticket) then) =
      _$TicketCopyWithImpl<$Res, Ticket>;
  @useResult
  $Res call({
    String id,
    String tenantId,
    String ticketNumber,
    String createdBy,
    String? paidBy,
    String? approvedBy,
    TicketStatus status,
    double montant,
    Map<String, dynamic> snapshotPrice,
    List<String> photosAvant,
    List<String> photosApres,
    String? vehiclePlate,
    String? vehicleCategoryId,
    String? vehicleType,
    String? vehicleBrand,
    String? vehicleModel,
    String? clientId,
    String? clientName,
    String? clientPhone,
    String? paymentMethod,
    String? assignedWorkerId,
    String? assignedWorkerName,
    String? serviceId,
    String? serviceName,
    List<TicketService> servicesSelected,
    List<TicketProduct> productsUsed,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class _$TicketCopyWithImpl<$Res, $Val extends Ticket>
    implements $TicketCopyWith<$Res> {
  _$TicketCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Ticket
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tenantId = null,
    Object? ticketNumber = null,
    Object? createdBy = null,
    Object? paidBy = freezed,
    Object? approvedBy = freezed,
    Object? status = null,
    Object? montant = null,
    Object? snapshotPrice = null,
    Object? photosAvant = null,
    Object? photosApres = null,
    Object? vehiclePlate = freezed,
    Object? vehicleCategoryId = freezed,
    Object? vehicleType = freezed,
    Object? vehicleBrand = freezed,
    Object? vehicleModel = freezed,
    Object? clientId = freezed,
    Object? clientName = freezed,
    Object? clientPhone = freezed,
    Object? paymentMethod = freezed,
    Object? assignedWorkerId = freezed,
    Object? assignedWorkerName = freezed,
    Object? serviceId = freezed,
    Object? serviceName = freezed,
    Object? servicesSelected = null,
    Object? productsUsed = null,
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
            ticketNumber: null == ticketNumber
                ? _value.ticketNumber
                : ticketNumber // ignore: cast_nullable_to_non_nullable
                      as String,
            createdBy: null == createdBy
                ? _value.createdBy
                : createdBy // ignore: cast_nullable_to_non_nullable
                      as String,
            paidBy: freezed == paidBy
                ? _value.paidBy
                : paidBy // ignore: cast_nullable_to_non_nullable
                      as String?,
            approvedBy: freezed == approvedBy
                ? _value.approvedBy
                : approvedBy // ignore: cast_nullable_to_non_nullable
                      as String?,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as TicketStatus,
            montant: null == montant
                ? _value.montant
                : montant // ignore: cast_nullable_to_non_nullable
                      as double,
            snapshotPrice: null == snapshotPrice
                ? _value.snapshotPrice
                : snapshotPrice // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>,
            photosAvant: null == photosAvant
                ? _value.photosAvant
                : photosAvant // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            photosApres: null == photosApres
                ? _value.photosApres
                : photosApres // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            vehiclePlate: freezed == vehiclePlate
                ? _value.vehiclePlate
                : vehiclePlate // ignore: cast_nullable_to_non_nullable
                      as String?,
            vehicleCategoryId: freezed == vehicleCategoryId
                ? _value.vehicleCategoryId
                : vehicleCategoryId // ignore: cast_nullable_to_non_nullable
                      as String?,
            vehicleType: freezed == vehicleType
                ? _value.vehicleType
                : vehicleType // ignore: cast_nullable_to_non_nullable
                      as String?,
            vehicleBrand: freezed == vehicleBrand
                ? _value.vehicleBrand
                : vehicleBrand // ignore: cast_nullable_to_non_nullable
                      as String?,
            vehicleModel: freezed == vehicleModel
                ? _value.vehicleModel
                : vehicleModel // ignore: cast_nullable_to_non_nullable
                      as String?,
            clientId: freezed == clientId
                ? _value.clientId
                : clientId // ignore: cast_nullable_to_non_nullable
                      as String?,
            clientName: freezed == clientName
                ? _value.clientName
                : clientName // ignore: cast_nullable_to_non_nullable
                      as String?,
            clientPhone: freezed == clientPhone
                ? _value.clientPhone
                : clientPhone // ignore: cast_nullable_to_non_nullable
                      as String?,
            paymentMethod: freezed == paymentMethod
                ? _value.paymentMethod
                : paymentMethod // ignore: cast_nullable_to_non_nullable
                      as String?,
            assignedWorkerId: freezed == assignedWorkerId
                ? _value.assignedWorkerId
                : assignedWorkerId // ignore: cast_nullable_to_non_nullable
                      as String?,
            assignedWorkerName: freezed == assignedWorkerName
                ? _value.assignedWorkerName
                : assignedWorkerName // ignore: cast_nullable_to_non_nullable
                      as String?,
            serviceId: freezed == serviceId
                ? _value.serviceId
                : serviceId // ignore: cast_nullable_to_non_nullable
                      as String?,
            serviceName: freezed == serviceName
                ? _value.serviceName
                : serviceName // ignore: cast_nullable_to_non_nullable
                      as String?,
            servicesSelected: null == servicesSelected
                ? _value.servicesSelected
                : servicesSelected // ignore: cast_nullable_to_non_nullable
                      as List<TicketService>,
            productsUsed: null == productsUsed
                ? _value.productsUsed
                : productsUsed // ignore: cast_nullable_to_non_nullable
                      as List<TicketProduct>,
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
abstract class _$$TicketImplCopyWith<$Res> implements $TicketCopyWith<$Res> {
  factory _$$TicketImplCopyWith(
    _$TicketImpl value,
    $Res Function(_$TicketImpl) then,
  ) = __$$TicketImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String tenantId,
    String ticketNumber,
    String createdBy,
    String? paidBy,
    String? approvedBy,
    TicketStatus status,
    double montant,
    Map<String, dynamic> snapshotPrice,
    List<String> photosAvant,
    List<String> photosApres,
    String? vehiclePlate,
    String? vehicleCategoryId,
    String? vehicleType,
    String? vehicleBrand,
    String? vehicleModel,
    String? clientId,
    String? clientName,
    String? clientPhone,
    String? paymentMethod,
    String? assignedWorkerId,
    String? assignedWorkerName,
    String? serviceId,
    String? serviceName,
    List<TicketService> servicesSelected,
    List<TicketProduct> productsUsed,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class __$$TicketImplCopyWithImpl<$Res>
    extends _$TicketCopyWithImpl<$Res, _$TicketImpl>
    implements _$$TicketImplCopyWith<$Res> {
  __$$TicketImplCopyWithImpl(
    _$TicketImpl _value,
    $Res Function(_$TicketImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Ticket
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tenantId = null,
    Object? ticketNumber = null,
    Object? createdBy = null,
    Object? paidBy = freezed,
    Object? approvedBy = freezed,
    Object? status = null,
    Object? montant = null,
    Object? snapshotPrice = null,
    Object? photosAvant = null,
    Object? photosApres = null,
    Object? vehiclePlate = freezed,
    Object? vehicleCategoryId = freezed,
    Object? vehicleType = freezed,
    Object? vehicleBrand = freezed,
    Object? vehicleModel = freezed,
    Object? clientId = freezed,
    Object? clientName = freezed,
    Object? clientPhone = freezed,
    Object? paymentMethod = freezed,
    Object? assignedWorkerId = freezed,
    Object? assignedWorkerName = freezed,
    Object? serviceId = freezed,
    Object? serviceName = freezed,
    Object? servicesSelected = null,
    Object? productsUsed = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$TicketImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        tenantId: null == tenantId
            ? _value.tenantId
            : tenantId // ignore: cast_nullable_to_non_nullable
                  as String,
        ticketNumber: null == ticketNumber
            ? _value.ticketNumber
            : ticketNumber // ignore: cast_nullable_to_non_nullable
                  as String,
        createdBy: null == createdBy
            ? _value.createdBy
            : createdBy // ignore: cast_nullable_to_non_nullable
                  as String,
        paidBy: freezed == paidBy
            ? _value.paidBy
            : paidBy // ignore: cast_nullable_to_non_nullable
                  as String?,
        approvedBy: freezed == approvedBy
            ? _value.approvedBy
            : approvedBy // ignore: cast_nullable_to_non_nullable
                  as String?,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as TicketStatus,
        montant: null == montant
            ? _value.montant
            : montant // ignore: cast_nullable_to_non_nullable
                  as double,
        snapshotPrice: null == snapshotPrice
            ? _value._snapshotPrice
            : snapshotPrice // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>,
        photosAvant: null == photosAvant
            ? _value._photosAvant
            : photosAvant // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        photosApres: null == photosApres
            ? _value._photosApres
            : photosApres // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        vehiclePlate: freezed == vehiclePlate
            ? _value.vehiclePlate
            : vehiclePlate // ignore: cast_nullable_to_non_nullable
                  as String?,
        vehicleCategoryId: freezed == vehicleCategoryId
            ? _value.vehicleCategoryId
            : vehicleCategoryId // ignore: cast_nullable_to_non_nullable
                  as String?,
        vehicleType: freezed == vehicleType
            ? _value.vehicleType
            : vehicleType // ignore: cast_nullable_to_non_nullable
                  as String?,
        vehicleBrand: freezed == vehicleBrand
            ? _value.vehicleBrand
            : vehicleBrand // ignore: cast_nullable_to_non_nullable
                  as String?,
        vehicleModel: freezed == vehicleModel
            ? _value.vehicleModel
            : vehicleModel // ignore: cast_nullable_to_non_nullable
                  as String?,
        clientId: freezed == clientId
            ? _value.clientId
            : clientId // ignore: cast_nullable_to_non_nullable
                  as String?,
        clientName: freezed == clientName
            ? _value.clientName
            : clientName // ignore: cast_nullable_to_non_nullable
                  as String?,
        clientPhone: freezed == clientPhone
            ? _value.clientPhone
            : clientPhone // ignore: cast_nullable_to_non_nullable
                  as String?,
        paymentMethod: freezed == paymentMethod
            ? _value.paymentMethod
            : paymentMethod // ignore: cast_nullable_to_non_nullable
                  as String?,
        assignedWorkerId: freezed == assignedWorkerId
            ? _value.assignedWorkerId
            : assignedWorkerId // ignore: cast_nullable_to_non_nullable
                  as String?,
        assignedWorkerName: freezed == assignedWorkerName
            ? _value.assignedWorkerName
            : assignedWorkerName // ignore: cast_nullable_to_non_nullable
                  as String?,
        serviceId: freezed == serviceId
            ? _value.serviceId
            : serviceId // ignore: cast_nullable_to_non_nullable
                  as String?,
        serviceName: freezed == serviceName
            ? _value.serviceName
            : serviceName // ignore: cast_nullable_to_non_nullable
                  as String?,
        servicesSelected: null == servicesSelected
            ? _value._servicesSelected
            : servicesSelected // ignore: cast_nullable_to_non_nullable
                  as List<TicketService>,
        productsUsed: null == productsUsed
            ? _value._productsUsed
            : productsUsed // ignore: cast_nullable_to_non_nullable
                  as List<TicketProduct>,
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
class _$TicketImpl extends _Ticket {
  const _$TicketImpl({
    required this.id,
    required this.tenantId,
    required this.ticketNumber,
    required this.createdBy,
    this.paidBy,
    this.approvedBy,
    required this.status,
    required this.montant,
    required final Map<String, dynamic> snapshotPrice,
    final List<String> photosAvant = const [],
    final List<String> photosApres = const [],
    this.vehiclePlate,
    this.vehicleCategoryId,
    this.vehicleType,
    this.vehicleBrand,
    this.vehicleModel,
    this.clientId,
    this.clientName,
    this.clientPhone,
    this.paymentMethod,
    this.assignedWorkerId,
    this.assignedWorkerName,
    this.serviceId,
    this.serviceName,
    final List<TicketService> servicesSelected = const [],
    final List<TicketProduct> productsUsed = const [],
    required this.createdAt,
    required this.updatedAt,
  }) : _snapshotPrice = snapshotPrice,
       _photosAvant = photosAvant,
       _photosApres = photosApres,
       _servicesSelected = servicesSelected,
       _productsUsed = productsUsed,
       super._();

  factory _$TicketImpl.fromJson(Map<String, dynamic> json) =>
      _$$TicketImplFromJson(json);

  @override
  final String id;
  // Firestore Document ID
  @override
  final String tenantId;
  // stationId
  @override
  final String ticketNumber;
  // ST-{station}-{date}-{heure}-{random}
  @override
  final String createdBy;
  // Creator (Worker or Cashier)
  @override
  final String? paidBy;
  // Paid cashier
  @override
  final String? approvedBy;
  // Approver
  @override
  final TicketStatus status;
  // en_attente, paye, rembourse
  @override
  final double montant;
  // Total ticket amount
  final Map<String, dynamic> _snapshotPrice;
  // Total ticket amount
  @override
  Map<String, dynamic> get snapshotPrice {
    if (_snapshotPrice is EqualUnmodifiableMapView) return _snapshotPrice;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_snapshotPrice);
  }

  // Anti-fraud snapshot of service prices
  final List<String> _photosAvant;
  // Anti-fraud snapshot of service prices
  @override
  @JsonKey()
  List<String> get photosAvant {
    if (_photosAvant is EqualUnmodifiableListView) return _photosAvant;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_photosAvant);
  }

  // Photos before wash
  final List<String> _photosApres;
  // Photos before wash
  @override
  @JsonKey()
  List<String> get photosApres {
    if (_photosApres is EqualUnmodifiableListView) return _photosApres;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_photosApres);
  }

  // Photos after wash
  @override
  final String? vehiclePlate;
  @override
  final String? vehicleCategoryId;
  // Added to map to Category ID for doses
  @override
  final String? vehicleType;
  // Category Name
  @override
  final String? vehicleBrand;
  @override
  final String? vehicleModel;
  @override
  final String? clientId;
  // B2B client account ID
  @override
  final String? clientName;
  @override
  final String? clientPhone;
  @override
  final String? paymentMethod;
  // Espèces, TPE, Compte Client
  @override
  final String? assignedWorkerId;
  @override
  final String? assignedWorkerName;
  @override
  final String? serviceId;
  @override
  final String? serviceName;
  final List<TicketService> _servicesSelected;
  @override
  @JsonKey()
  List<TicketService> get servicesSelected {
    if (_servicesSelected is EqualUnmodifiableListView)
      return _servicesSelected;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_servicesSelected);
  }

  final List<TicketProduct> _productsUsed;
  @override
  @JsonKey()
  List<TicketProduct> get productsUsed {
    if (_productsUsed is EqualUnmodifiableListView) return _productsUsed;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_productsUsed);
  }

  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'Ticket(id: $id, tenantId: $tenantId, ticketNumber: $ticketNumber, createdBy: $createdBy, paidBy: $paidBy, approvedBy: $approvedBy, status: $status, montant: $montant, snapshotPrice: $snapshotPrice, photosAvant: $photosAvant, photosApres: $photosApres, vehiclePlate: $vehiclePlate, vehicleCategoryId: $vehicleCategoryId, vehicleType: $vehicleType, vehicleBrand: $vehicleBrand, vehicleModel: $vehicleModel, clientId: $clientId, clientName: $clientName, clientPhone: $clientPhone, paymentMethod: $paymentMethod, assignedWorkerId: $assignedWorkerId, assignedWorkerName: $assignedWorkerName, serviceId: $serviceId, serviceName: $serviceName, servicesSelected: $servicesSelected, productsUsed: $productsUsed, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TicketImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.tenantId, tenantId) ||
                other.tenantId == tenantId) &&
            (identical(other.ticketNumber, ticketNumber) ||
                other.ticketNumber == ticketNumber) &&
            (identical(other.createdBy, createdBy) ||
                other.createdBy == createdBy) &&
            (identical(other.paidBy, paidBy) || other.paidBy == paidBy) &&
            (identical(other.approvedBy, approvedBy) ||
                other.approvedBy == approvedBy) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.montant, montant) || other.montant == montant) &&
            const DeepCollectionEquality().equals(
              other._snapshotPrice,
              _snapshotPrice,
            ) &&
            const DeepCollectionEquality().equals(
              other._photosAvant,
              _photosAvant,
            ) &&
            const DeepCollectionEquality().equals(
              other._photosApres,
              _photosApres,
            ) &&
            (identical(other.vehiclePlate, vehiclePlate) ||
                other.vehiclePlate == vehiclePlate) &&
            (identical(other.vehicleCategoryId, vehicleCategoryId) ||
                other.vehicleCategoryId == vehicleCategoryId) &&
            (identical(other.vehicleType, vehicleType) ||
                other.vehicleType == vehicleType) &&
            (identical(other.vehicleBrand, vehicleBrand) ||
                other.vehicleBrand == vehicleBrand) &&
            (identical(other.vehicleModel, vehicleModel) ||
                other.vehicleModel == vehicleModel) &&
            (identical(other.clientId, clientId) ||
                other.clientId == clientId) &&
            (identical(other.clientName, clientName) ||
                other.clientName == clientName) &&
            (identical(other.clientPhone, clientPhone) ||
                other.clientPhone == clientPhone) &&
            (identical(other.paymentMethod, paymentMethod) ||
                other.paymentMethod == paymentMethod) &&
            (identical(other.assignedWorkerId, assignedWorkerId) ||
                other.assignedWorkerId == assignedWorkerId) &&
            (identical(other.assignedWorkerName, assignedWorkerName) ||
                other.assignedWorkerName == assignedWorkerName) &&
            (identical(other.serviceId, serviceId) ||
                other.serviceId == serviceId) &&
            (identical(other.serviceName, serviceName) ||
                other.serviceName == serviceName) &&
            const DeepCollectionEquality().equals(
              other._servicesSelected,
              _servicesSelected,
            ) &&
            const DeepCollectionEquality().equals(
              other._productsUsed,
              _productsUsed,
            ) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    id,
    tenantId,
    ticketNumber,
    createdBy,
    paidBy,
    approvedBy,
    status,
    montant,
    const DeepCollectionEquality().hash(_snapshotPrice),
    const DeepCollectionEquality().hash(_photosAvant),
    const DeepCollectionEquality().hash(_photosApres),
    vehiclePlate,
    vehicleCategoryId,
    vehicleType,
    vehicleBrand,
    vehicleModel,
    clientId,
    clientName,
    clientPhone,
    paymentMethod,
    assignedWorkerId,
    assignedWorkerName,
    serviceId,
    serviceName,
    const DeepCollectionEquality().hash(_servicesSelected),
    const DeepCollectionEquality().hash(_productsUsed),
    createdAt,
    updatedAt,
  ]);

  /// Create a copy of Ticket
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TicketImplCopyWith<_$TicketImpl> get copyWith =>
      __$$TicketImplCopyWithImpl<_$TicketImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TicketImplToJson(this);
  }
}

abstract class _Ticket extends Ticket {
  const factory _Ticket({
    required final String id,
    required final String tenantId,
    required final String ticketNumber,
    required final String createdBy,
    final String? paidBy,
    final String? approvedBy,
    required final TicketStatus status,
    required final double montant,
    required final Map<String, dynamic> snapshotPrice,
    final List<String> photosAvant,
    final List<String> photosApres,
    final String? vehiclePlate,
    final String? vehicleCategoryId,
    final String? vehicleType,
    final String? vehicleBrand,
    final String? vehicleModel,
    final String? clientId,
    final String? clientName,
    final String? clientPhone,
    final String? paymentMethod,
    final String? assignedWorkerId,
    final String? assignedWorkerName,
    final String? serviceId,
    final String? serviceName,
    final List<TicketService> servicesSelected,
    final List<TicketProduct> productsUsed,
    required final DateTime createdAt,
    required final DateTime updatedAt,
  }) = _$TicketImpl;
  const _Ticket._() : super._();

  factory _Ticket.fromJson(Map<String, dynamic> json) = _$TicketImpl.fromJson;

  @override
  String get id; // Firestore Document ID
  @override
  String get tenantId; // stationId
  @override
  String get ticketNumber; // ST-{station}-{date}-{heure}-{random}
  @override
  String get createdBy; // Creator (Worker or Cashier)
  @override
  String? get paidBy; // Paid cashier
  @override
  String? get approvedBy; // Approver
  @override
  TicketStatus get status; // en_attente, paye, rembourse
  @override
  double get montant; // Total ticket amount
  @override
  Map<String, dynamic> get snapshotPrice; // Anti-fraud snapshot of service prices
  @override
  List<String> get photosAvant; // Photos before wash
  @override
  List<String> get photosApres; // Photos after wash
  @override
  String? get vehiclePlate;
  @override
  String? get vehicleCategoryId; // Added to map to Category ID for doses
  @override
  String? get vehicleType; // Category Name
  @override
  String? get vehicleBrand;
  @override
  String? get vehicleModel;
  @override
  String? get clientId; // B2B client account ID
  @override
  String? get clientName;
  @override
  String? get clientPhone;
  @override
  String? get paymentMethod; // Espèces, TPE, Compte Client
  @override
  String? get assignedWorkerId;
  @override
  String? get assignedWorkerName;
  @override
  String? get serviceId;
  @override
  String? get serviceName;
  @override
  List<TicketService> get servicesSelected;
  @override
  List<TicketProduct> get productsUsed;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of Ticket
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TicketImplCopyWith<_$TicketImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

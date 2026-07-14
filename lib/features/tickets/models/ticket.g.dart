// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ticket.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TicketProductImpl _$$TicketProductImplFromJson(Map<String, dynamic> json) =>
    _$TicketProductImpl(
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      quantity: (json['quantity'] as num).toInt(),
      unitPrice: (json['unitPrice'] as num).toDouble(),
    );

Map<String, dynamic> _$$TicketProductImplToJson(_$TicketProductImpl instance) =>
    <String, dynamic>{
      'productId': instance.productId,
      'productName': instance.productName,
      'quantity': instance.quantity,
      'unitPrice': instance.unitPrice,
    };

_$TicketServiceImpl _$$TicketServiceImplFromJson(Map<String, dynamic> json) =>
    _$TicketServiceImpl(
      serviceId: json['serviceId'] as String,
      serviceName: json['serviceName'] as String,
      price: (json['price'] as num).toDouble(),
    );

Map<String, dynamic> _$$TicketServiceImplToJson(_$TicketServiceImpl instance) =>
    <String, dynamic>{
      'serviceId': instance.serviceId,
      'serviceName': instance.serviceName,
      'price': instance.price,
    };

_$TicketImpl _$$TicketImplFromJson(Map<String, dynamic> json) => _$TicketImpl(
  id: json['id'] as String,
  tenantId: readTenantId(json, 'tenantId') as String,
  ticketNumber: json['ticketNumber'] as String,
  createdBy: json['createdBy'] as String,
  paidBy: json['paidBy'] as String?,
  approvedBy: json['approvedBy'] as String?,
  status: $enumDecode(_$TicketStatusEnumMap, json['status']),
  montant: (json['montant'] as num).toDouble(),
  snapshotPrice: json['snapshotPrice'] as Map<String, dynamic>,
  photosAvant:
      (json['photosAvant'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  photosApres:
      (json['photosApres'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  vehiclePlate: json['vehiclePlate'] as String?,
  vehicleCategoryId: json['vehicleCategoryId'] as String?,
  vehicleType: json['vehicleType'] as String?,
  vehicleBrand: json['vehicleBrand'] as String?,
  vehicleModel: json['vehicleModel'] as String?,
  clientId: json['clientId'] as String?,
  clientName: json['clientName'] as String?,
  clientPhone: json['clientPhone'] as String?,
  paymentMethod: json['paymentMethod'] as String?,
  assignedWorkerId: json['assignedWorkerId'] as String?,
  assignedWorkerName: json['assignedWorkerName'] as String?,
  serviceId: json['serviceId'] as String?,
  serviceName: json['serviceName'] as String?,
  servicesSelected:
      (json['servicesSelected'] as List<dynamic>?)
          ?.map((e) => TicketService.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  productsUsed:
      (json['productsUsed'] as List<dynamic>?)
          ?.map((e) => TicketProduct.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$$TicketImplToJson(_$TicketImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tenantId': instance.tenantId,
      'ticketNumber': instance.ticketNumber,
      'createdBy': instance.createdBy,
      'paidBy': instance.paidBy,
      'approvedBy': instance.approvedBy,
      'status': _$TicketStatusEnumMap[instance.status]!,
      'montant': instance.montant,
      'snapshotPrice': instance.snapshotPrice,
      'photosAvant': instance.photosAvant,
      'photosApres': instance.photosApres,
      'vehiclePlate': instance.vehiclePlate,
      'vehicleCategoryId': instance.vehicleCategoryId,
      'vehicleType': instance.vehicleType,
      'vehicleBrand': instance.vehicleBrand,
      'vehicleModel': instance.vehicleModel,
      'clientId': instance.clientId,
      'clientName': instance.clientName,
      'clientPhone': instance.clientPhone,
      'paymentMethod': instance.paymentMethod,
      'assignedWorkerId': instance.assignedWorkerId,
      'assignedWorkerName': instance.assignedWorkerName,
      'serviceId': instance.serviceId,
      'serviceName': instance.serviceName,
      'servicesSelected': instance.servicesSelected,
      'productsUsed': instance.productsUsed,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$TicketStatusEnumMap = {
  TicketStatus.enAttente: 'enAttente',
  TicketStatus.paye: 'paye',
  TicketStatus.rembourse: 'rembourse',
};

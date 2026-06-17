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

_$TicketImpl _$$TicketImplFromJson(Map<String, dynamic> json) => _$TicketImpl(
  id: json['id'] as String,
  tenantId: json['tenantId'] as String,
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
  vehicleType: json['vehicleType'] as String?,
  serviceId: json['serviceId'] as String?,
  serviceName: json['serviceName'] as String?,
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
      'vehicleType': instance.vehicleType,
      'serviceId': instance.serviceId,
      'serviceName': instance.serviceName,
      'productsUsed': instance.productsUsed,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$TicketStatusEnumMap = {
  TicketStatus.enAttente: 'enAttente',
  TicketStatus.paye: 'paye',
  TicketStatus.rembourse: 'rembourse',
};

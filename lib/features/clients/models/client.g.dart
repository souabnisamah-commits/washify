// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ClientImpl _$$ClientImplFromJson(Map<String, dynamic> json) => _$ClientImpl(
  id: json['id'] as String,
  tenantId: readTenantId(json, 'tenantId') as String,
  companyName: json['companyName'] as String,
  contactName: json['contactName'] as String,
  taxId: json['taxId'] as String,
  phone: json['phone'] as String,
  alertThreshold: (json['alertThreshold'] as num?)?.toDouble() ?? 0.0,
  currentBalance: (json['currentBalance'] as num?)?.toDouble() ?? 0.0,
  vehicles: json['vehicles'] == null
      ? const []
      : const VehicleListConverter().fromJson(json['vehicles'] as List),
  hasAppAccess: json['hasAppAccess'] as bool? ?? false,
  accessPasswordHash: json['accessPasswordHash'] as String? ?? '',
  accessStatus: json['accessStatus'] as String? ?? 'active',
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$$ClientImplToJson(_$ClientImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tenantId': instance.tenantId,
      'companyName': instance.companyName,
      'contactName': instance.contactName,
      'taxId': instance.taxId,
      'phone': instance.phone,
      'alertThreshold': instance.alertThreshold,
      'currentBalance': instance.currentBalance,
      'vehicles': const VehicleListConverter().toJson(instance.vehicles),
      'hasAppAccess': instance.hasAppAccess,
      'accessPasswordHash': instance.accessPasswordHash,
      'accessStatus': instance.accessStatus,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

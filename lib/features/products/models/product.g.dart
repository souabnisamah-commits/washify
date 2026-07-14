// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProductImpl _$$ProductImplFromJson(Map<String, dynamic> json) =>
    _$ProductImpl(
      id: json['id'] as String,
      tenantId: readTenantId(json, 'tenantId') as String,
      name: json['name'] as String,
      description: json['description'] as String,
      family:
          $enumDecodeNullable(
            _$ProductFamilyEnumMap,
            json['family'],
            unknownValue: ProductFamily.standard,
          ) ??
          ProductFamily.standard,
      unit: json['unit'] as String,
      unitPrice: (json['unitPrice'] as num).toDouble(),
      minStock: (json['minStock'] as num).toInt(),
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      purchasePrice: (json['purchasePrice'] as num?)?.toDouble() ?? 0.0,
      capacityMl: (json['capacityMl'] as num?)?.toDouble() ?? 0.0,
      barcode: json['barcode'] as String? ?? '',
    );

Map<String, dynamic> _$$ProductImplToJson(_$ProductImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tenantId': instance.tenantId,
      'name': instance.name,
      'description': instance.description,
      'family': _$ProductFamilyEnumMap[instance.family]!,
      'unit': instance.unit,
      'unitPrice': instance.unitPrice,
      'minStock': instance.minStock,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'purchasePrice': instance.purchasePrice,
      'capacityMl': instance.capacityMl,
      'barcode': instance.barcode,
    };

const _$ProductFamilyEnumMap = {
  ProductFamily.standard: 'standard',
  ProductFamily.extra: 'extra',
  ProductFamily.revente: 'revente',
};

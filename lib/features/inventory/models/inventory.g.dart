// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$InventoryItemImpl _$$InventoryItemImplFromJson(Map<String, dynamic> json) =>
    _$InventoryItemImpl(
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      expectedQuantity: (json['expectedQuantity'] as num).toInt(),
      actualQuantity: (json['actualQuantity'] as num).toInt(),
      difference: (json['difference'] as num).toInt(),
    );

Map<String, dynamic> _$$InventoryItemImplToJson(_$InventoryItemImpl instance) =>
    <String, dynamic>{
      'productId': instance.productId,
      'productName': instance.productName,
      'expectedQuantity': instance.expectedQuantity,
      'actualQuantity': instance.actualQuantity,
      'difference': instance.difference,
    };

_$InventoryImpl _$$InventoryImplFromJson(Map<String, dynamic> json) =>
    _$InventoryImpl(
      id: json['id'] as String,
      tenantId: json['tenantId'] as String,
      performedBy: json['performedBy'] as String,
      performedByName: json['performedByName'] as String,
      date: DateTime.parse(json['date'] as String),
      items: (json['items'] as List<dynamic>)
          .map((e) => InventoryItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      notes: json['notes'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$InventoryImplToJson(_$InventoryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tenantId': instance.tenantId,
      'performedBy': instance.performedBy,
      'performedByName': instance.performedByName,
      'date': instance.date.toIso8601String(),
      'items': instance.items,
      'notes': instance.notes,
      'createdAt': instance.createdAt.toIso8601String(),
    };

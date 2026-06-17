// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stock.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StockLevelImpl _$$StockLevelImplFromJson(Map<String, dynamic> json) =>
    _$StockLevelImpl(
      id: json['id'] as String,
      tenantId: json['tenantId'] as String,
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      currentQuantity: (json['currentQuantity'] as num).toInt(),
      minStock: (json['minStock'] as num).toInt(),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$StockLevelImplToJson(_$StockLevelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tenantId': instance.tenantId,
      'productId': instance.productId,
      'productName': instance.productName,
      'currentQuantity': instance.currentQuantity,
      'minStock': instance.minStock,
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

_$StockMovementImpl _$$StockMovementImplFromJson(Map<String, dynamic> json) =>
    _$StockMovementImpl(
      id: json['id'] as String,
      tenantId: json['tenantId'] as String,
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      type: json['type'] as String,
      quantity: (json['quantity'] as num).toInt(),
      previousQuantity: (json['previousQuantity'] as num).toInt(),
      newQuantity: (json['newQuantity'] as num).toInt(),
      reason: json['reason'] as String,
      performedBy: json['performedBy'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$StockMovementImplToJson(_$StockMovementImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tenantId': instance.tenantId,
      'productId': instance.productId,
      'productName': instance.productName,
      'type': instance.type,
      'quantity': instance.quantity,
      'previousQuantity': instance.previousQuantity,
      'newQuantity': instance.newQuantity,
      'reason': instance.reason,
      'performedBy': instance.performedBy,
      'createdAt': instance.createdAt.toIso8601String(),
    };

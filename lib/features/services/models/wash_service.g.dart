// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wash_service.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WashServiceImpl _$$WashServiceImplFromJson(Map<String, dynamic> json) =>
    _$WashServiceImpl(
      id: json['id'] as String,
      tenantId: json['tenantId'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      durationMinutes: (json['durationMinutes'] as num).toInt(),
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$WashServiceImplToJson(_$WashServiceImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tenantId': instance.tenantId,
      'name': instance.name,
      'description': instance.description,
      'price': instance.price,
      'durationMinutes': instance.durationMinutes,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client_vehicle.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ClientVehicleImpl _$$ClientVehicleImplFromJson(Map<String, dynamic> json) =>
    _$ClientVehicleImpl(
      plate: json['plate'] as String,
      brand: json['brand'] as String? ?? '',
      model: json['model'] as String? ?? '',
      categoryId: json['categoryId'] as String? ?? '',
      isBlocked: json['isBlocked'] as bool? ?? false,
      blockedReason: json['blockedReason'] as String? ?? '',
    );

Map<String, dynamic> _$$ClientVehicleImplToJson(_$ClientVehicleImpl instance) =>
    <String, dynamic>{
      'plate': instance.plate,
      'brand': instance.brand,
      'model': instance.model,
      'categoryId': instance.categoryId,
      'isBlocked': instance.isBlocked,
      'blockedReason': instance.blockedReason,
    };

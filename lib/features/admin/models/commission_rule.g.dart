// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'commission_rule.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CommissionRuleImpl _$$CommissionRuleImplFromJson(Map<String, dynamic> json) =>
    _$CommissionRuleImpl(
      id: json['id'] as String,
      stationId: json['stationId'] as String,
      serviceId: json['serviceId'] as String?,
      rate: (json['rate'] as num).toDouble(),
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$CommissionRuleImplToJson(
  _$CommissionRuleImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'stationId': instance.stationId,
  'serviceId': instance.serviceId,
  'rate': instance.rate,
  'isActive': instance.isActive,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};

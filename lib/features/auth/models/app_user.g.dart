// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AppUserImpl _$$AppUserImplFromJson(Map<String, dynamic> json) =>
    _$AppUserImpl(
      id: json['id'] as String,
      tenantId: json['tenantId'] as String,
      phone: json['phone'] as String,
      pinHash: json['pinHash'] as String,
      name: json['name'] as String,
      roles: (json['roles'] as List<dynamic>)
          .map((e) => $enumDecode(_$UserRoleEnumMap, e))
          .toList(),
      baseDailyWage: (json['baseDailyWage'] as num?)?.toDouble() ?? 0.0,
      extraHourRate: (json['extraHourRate'] as num?)?.toDouble() ?? 0.0,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$AppUserImplToJson(_$AppUserImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tenantId': instance.tenantId,
      'phone': instance.phone,
      'pinHash': instance.pinHash,
      'name': instance.name,
      'roles': instance.roles.map((e) => _$UserRoleEnumMap[e]!).toList(),
      'baseDailyWage': instance.baseDailyWage,
      'extraHourRate': instance.extraHourRate,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$UserRoleEnumMap = {
  UserRole.admin: 'admin',
  UserRole.patron: 'patron',
  UserRole.caissier: 'caissier',
  UserRole.ouvrier: 'ouvrier',
};

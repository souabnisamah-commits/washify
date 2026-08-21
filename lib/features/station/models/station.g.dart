// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'station.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StationImpl _$$StationImplFromJson(
  Map<String, dynamic> json,
) => _$StationImpl(
  id: json['id'] as String,
  tenantId: readTenantId(json, 'tenantId') as String,
  name: json['name'] as String,
  gerantName: json['gerantName'] as String,
  phone: json['phone'] as String,
  email: json['email'] as String,
  matriculeFiscale: json['matriculeFiscale'] as String,
  latitude: (json['latitude'] as num).toDouble(),
  longitude: (json['longitude'] as num).toDouble(),
  logoUrl: json['logoUrl'] as String,
  licence: $enumDecode(_$LicenceStatusEnumMap, json['licence']),
  subscriptionDate: json['subscriptionDate'] == null
      ? null
      : DateTime.parse(json['subscriptionDate'] as String),
  expiryDate: json['expiryDate'] == null
      ? null
      : DateTime.parse(json['expiryDate'] as String),
  gracePeriodDays: (json['gracePeriodDays'] as num?)?.toInt() ?? 7,
  address: json['address'] as String? ?? '',
  city: json['city'] as String? ?? '',
  isActive: json['isActive'] as bool? ?? true,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  carpetPricePerMeter: (json['carpetPricePerMeter'] as num?)?.toDouble() ?? 0.0,
  carpetLinkedProducts:
      (json['carpetLinkedProducts'] as List<dynamic>?)
          ?.map((e) => ServiceProductLink.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  ticketResetHour: (json['ticketResetHour'] as num?)?.toInt() ?? 21,
);

Map<String, dynamic> _$$StationImplToJson(_$StationImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tenantId': instance.tenantId,
      'name': instance.name,
      'gerantName': instance.gerantName,
      'phone': instance.phone,
      'email': instance.email,
      'matriculeFiscale': instance.matriculeFiscale,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'logoUrl': instance.logoUrl,
      'licence': _$LicenceStatusEnumMap[instance.licence]!,
      'subscriptionDate': instance.subscriptionDate?.toIso8601String(),
      'expiryDate': instance.expiryDate?.toIso8601String(),
      'gracePeriodDays': instance.gracePeriodDays,
      'address': instance.address,
      'city': instance.city,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'carpetPricePerMeter': instance.carpetPricePerMeter,
      'carpetLinkedProducts': instance.carpetLinkedProducts,
      'ticketResetHour': instance.ticketResetHour,
    };

const _$LicenceStatusEnumMap = {
  LicenceStatus.active: 'active',
  LicenceStatus.gracePeriod: 'gracePeriod',
  LicenceStatus.suspended: 'suspended',
};

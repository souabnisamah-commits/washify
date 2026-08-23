// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'employee.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$EmployeeImpl _$$EmployeeImplFromJson(Map<String, dynamic> json) =>
    _$EmployeeImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      tenantId: readTenantId(json, 'tenantId') as String,
      nom: json['nom'] as String,
      prenom: json['prenom'] as String,
      phone: json['phone'] as String,
      contrat: $enumDecode(_$ContractTypeEnumMap, json['contrat']),
      valeurJournaliere: (json['valeurJournaliere'] as num).toDouble(),
      salaireMensuel: (json['salaireMensuel'] as num).toDouble(),
      extraHourRate: (json['extraHourRate'] as num?)?.toDouble() ?? 0.0,
      commissionRate: (json['commissionRate'] as num).toDouble(),
      roles:
          (json['roles'] as List<dynamic>?)
              ?.map((e) => $enumDecode(_$UserRoleEnumMap, e))
              .toList() ??
          const [UserRole.ouvrier],
      isActive: json['isActive'] as bool? ?? true,
      dateEmbauche: DateTime.parse(json['dateEmbauche'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$EmployeeImplToJson(_$EmployeeImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'tenantId': instance.tenantId,
      'nom': instance.nom,
      'prenom': instance.prenom,
      'phone': instance.phone,
      'contrat': _$ContractTypeEnumMap[instance.contrat]!,
      'valeurJournaliere': instance.valeurJournaliere,
      'salaireMensuel': instance.salaireMensuel,
      'extraHourRate': instance.extraHourRate,
      'commissionRate': instance.commissionRate,
      'roles': instance.roles.map((e) => _$UserRoleEnumMap[e]!).toList(),
      'isActive': instance.isActive,
      'dateEmbauche': instance.dateEmbauche.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$ContractTypeEnumMap = {
  ContractType.journalier: 'journalier',
  ContractType.mensuel: 'mensuel',
};

const _$UserRoleEnumMap = {
  UserRole.admin: 'admin',
  UserRole.patron: 'patron',
  UserRole.caissier: 'caissier',
  UserRole.ouvrier: 'ouvrier',
  UserRole.clientB2B: 'clientB2B',
};

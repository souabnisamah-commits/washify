// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audit_log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AuditLogImpl _$$AuditLogImplFromJson(Map<String, dynamic> json) =>
    _$AuditLogImpl(
      id: json['id'] as String,
      tenantId: json['tenantId'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      action: json['action'] as String,
      module: json['module'] as String,
      description: json['description'] as String,
      previousData: json['previousData'] as Map<String, dynamic>?,
      newData: json['newData'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$AuditLogImplToJson(_$AuditLogImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tenantId': instance.tenantId,
      'userId': instance.userId,
      'userName': instance.userName,
      'action': instance.action,
      'module': instance.module,
      'description': instance.description,
      'previousData': instance.previousData,
      'newData': instance.newData,
      'createdAt': instance.createdAt.toIso8601String(),
    };

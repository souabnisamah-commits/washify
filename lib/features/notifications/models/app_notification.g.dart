// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_notification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AppNotificationImpl _$$AppNotificationImplFromJson(
  Map<String, dynamic> json,
) => _$AppNotificationImpl(
  id: json['id'] as String,
  tenantId: json['tenantId'] as String,
  userId: json['userId'] as String,
  title: json['title'] as String,
  body: json['body'] as String,
  type: $enumDecode(_$NotificationTypeEnumMap, json['type']),
  isRead: json['isRead'] as bool? ?? false,
  referenceId: json['referenceId'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$$AppNotificationImplToJson(
  _$AppNotificationImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'tenantId': instance.tenantId,
  'userId': instance.userId,
  'title': instance.title,
  'body': instance.body,
  'type': _$NotificationTypeEnumMap[instance.type]!,
  'isRead': instance.isRead,
  'referenceId': instance.referenceId,
  'createdAt': instance.createdAt.toIso8601String(),
};

const _$NotificationTypeEnumMap = {
  NotificationType.licenceExpire: 'licenceExpire',
  NotificationType.stockFaible: 'stockFaible',
  NotificationType.remboursement: 'remboursement',
  NotificationType.ecartCaisse: 'ecartCaisse',
  NotificationType.system: 'system',
};

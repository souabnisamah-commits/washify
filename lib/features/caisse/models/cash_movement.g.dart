// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cash_movement.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CashMovementImpl _$$CashMovementImplFromJson(Map<String, dynamic> json) =>
    _$CashMovementImpl(
      id: json['id'] as String,
      stationId: json['stationId'] as String,
      sessionId: json['sessionId'] as String,
      amount: (json['amount'] as num).toDouble(),
      type: json['type'] as String,
      reason: json['reason'] as String,
      paymentMethod: json['paymentMethod'] as String? ?? 'cash',
      employeeId: json['employeeId'] as String?,
      employeeName: json['employeeName'] as String?,
      performedBy: json['performedBy'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$CashMovementImplToJson(_$CashMovementImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'stationId': instance.stationId,
      'sessionId': instance.sessionId,
      'amount': instance.amount,
      'type': instance.type,
      'reason': instance.reason,
      'paymentMethod': instance.paymentMethod,
      'employeeId': instance.employeeId,
      'employeeName': instance.employeeName,
      'performedBy': instance.performedBy,
      'createdAt': instance.createdAt.toIso8601String(),
    };

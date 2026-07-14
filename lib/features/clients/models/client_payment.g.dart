// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client_payment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ClientPaymentImpl _$$ClientPaymentImplFromJson(Map<String, dynamic> json) =>
    _$ClientPaymentImpl(
      id: json['id'] as String,
      clientId: json['clientId'] as String,
      tenantId: readTenantId(json, 'tenantId') as String,
      amount: (json['amount'] as num).toDouble(),
      paymentMethod: json['paymentMethod'] as String,
      reference: json['reference'] as String?,
      createdBy: json['createdBy'] as String,
      paymentDate: DateTime.parse(json['paymentDate'] as String),
    );

Map<String, dynamic> _$$ClientPaymentImplToJson(_$ClientPaymentImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'clientId': instance.clientId,
      'tenantId': instance.tenantId,
      'amount': instance.amount,
      'paymentMethod': instance.paymentMethod,
      'reference': instance.reference,
      'createdBy': instance.createdBy,
      'paymentDate': instance.paymentDate.toIso8601String(),
    };

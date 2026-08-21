// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cash_session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CashSessionImpl _$$CashSessionImplFromJson(Map<String, dynamic> json) =>
    _$CashSessionImpl(
      id: json['id'] as String,
      stationId: json['stationId'] as String,
      openingDate: DateTime.parse(json['openingDate'] as String),
      closingDate: json['closingDate'] == null
          ? null
          : DateTime.parse(json['closingDate'] as String),
      openedBy: json['openedBy'] as String,
      closedBy: json['closedBy'] as String?,
      initialBalance: (json['initialBalance'] as num).toDouble(),
      finalBalance: (json['finalBalance'] as num?)?.toDouble(),
      totalCashIn: (json['totalCashIn'] as num?)?.toDouble() ?? 0.0,
      totalCashOut: (json['totalCashOut'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$CashSessionImplToJson(_$CashSessionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'stationId': instance.stationId,
      'openingDate': instance.openingDate.toIso8601String(),
      'closingDate': instance.closingDate?.toIso8601String(),
      'openedBy': instance.openedBy,
      'closedBy': instance.closedBy,
      'initialBalance': instance.initialBalance,
      'finalBalance': instance.finalBalance,
      'totalCashIn': instance.totalCashIn,
      'totalCashOut': instance.totalCashOut,
      'status': instance.status,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

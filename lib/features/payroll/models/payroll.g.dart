// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payroll.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PayrollTransactionImpl _$$PayrollTransactionImplFromJson(
  Map<String, dynamic> json,
) => _$PayrollTransactionImpl(
  id: json['id'] as String,
  payrollId: json['payrollId'] as String,
  employeeId: json['employeeId'] as String,
  tenantId: json['tenantId'] as String,
  type: $enumDecode(_$PayrollTransactionTypeEnumMap, json['type']),
  amount: (json['amount'] as num).toDouble(),
  description: json['description'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$$PayrollTransactionImplToJson(
  _$PayrollTransactionImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'payrollId': instance.payrollId,
  'employeeId': instance.employeeId,
  'tenantId': instance.tenantId,
  'type': _$PayrollTransactionTypeEnumMap[instance.type]!,
  'amount': instance.amount,
  'description': instance.description,
  'createdAt': instance.createdAt.toIso8601String(),
};

const _$PayrollTransactionTypeEnumMap = {
  PayrollTransactionType.salaire: 'salaire',
  PayrollTransactionType.prime: 'prime',
  PayrollTransactionType.avance: 'avance',
  PayrollTransactionType.cnss: 'cnss',
};

_$PayrollImpl _$$PayrollImplFromJson(Map<String, dynamic> json) =>
    _$PayrollImpl(
      id: json['id'] as String,
      employeeId: json['employeeId'] as String,
      employeeName: json['employeeName'] as String,
      tenantId: json['tenantId'] as String,
      baseSalary: (json['baseSalary'] as num).toDouble(),
      commissionTotal: (json['commissionTotal'] as num).toDouble(),
      bonuses: (json['bonuses'] as num).toDouble(),
      deductions: (json['deductions'] as num).toDouble(),
      netAmount: (json['netAmount'] as num).toDouble(),
      period: json['period'] as String,
      status: json['status'] as String,
      approvedBy: json['approvedBy'] as String?,
      paidAt: json['paidAt'] == null
          ? null
          : DateTime.parse(json['paidAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$PayrollImplToJson(_$PayrollImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'employeeId': instance.employeeId,
      'employeeName': instance.employeeName,
      'tenantId': instance.tenantId,
      'baseSalary': instance.baseSalary,
      'commissionTotal': instance.commissionTotal,
      'bonuses': instance.bonuses,
      'deductions': instance.deductions,
      'netAmount': instance.netAmount,
      'period': instance.period,
      'status': instance.status,
      'approvedBy': instance.approvedBy,
      'paidAt': instance.paidAt?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

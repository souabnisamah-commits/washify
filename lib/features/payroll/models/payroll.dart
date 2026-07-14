import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:washify/core/utils/json_utils.dart';

part 'payroll.freezed.dart';
part 'payroll.g.dart';

enum PayrollTransactionType {
  salaire('salaire'),
  prime('prime'),
  avance('avance'),
  cnss('cnss');

  const PayrollTransactionType(this.value);
  final String value;

  static PayrollTransactionType fromString(String value) {
    return PayrollTransactionType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => PayrollTransactionType.salaire,
    );
  }
}

@freezed
class PayrollTransaction with _$PayrollTransaction {
  const PayrollTransaction._();

  const factory PayrollTransaction({
    required String id,
    required String payrollId,
    required String employeeId,
    @JsonKey(readValue: readTenantId) required String tenantId,
    required PayrollTransactionType type, // salaire, prime, avance, cnss
    required double amount,
    required String description,
    required DateTime createdAt,
  }) = _PayrollTransaction;

  String get stationId => tenantId;

  factory PayrollTransaction.fromJson(Map<String, dynamic> json) => _$PayrollTransactionFromJson(json);
}

@freezed
class Payroll with _$Payroll {
  const Payroll._();

  const factory Payroll({
    required String id,
    required String employeeId,
    required String employeeName,
    @JsonKey(readValue: readTenantId) required String tenantId,
    required double baseSalary,
    required double commissionTotal,
    required double bonuses,
    required double deductions,
    required double netAmount,
    required String period, // e.g., "2026-06"
    required String status, // pending, approved, paid
    String? approvedBy,
    DateTime? paidAt,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Payroll;

  String get stationId => tenantId;
  String get stationName => '';

  factory Payroll.fromJson(Map<String, dynamic> json) => _$PayrollFromJson(json);
}

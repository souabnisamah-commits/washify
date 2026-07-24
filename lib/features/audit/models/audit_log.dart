import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:washify/core/utils/json_utils.dart';

part 'audit_log.freezed.dart';
part 'audit_log.g.dart';

@freezed
class AuditLog with _$AuditLog {
  const AuditLog._();

  const factory AuditLog({
    required String id,
    @JsonKey(readValue: readTenantId) required String tenantId,
    required String userId,
    required String userName,
    required String action, // ticket_paye, ticket_rembourse, stock_modifie, wallet_ajuste, licence_modifiee
    required String module, // tickets, stock, wallet, admin
    required String description,
    @Default('info') String severity, // info, warning, critical
    Map<String, dynamic>? deviceInfo,
    Map<String, dynamic>? previousData,
    Map<String, dynamic>? newData,
    required DateTime createdAt,
  }) = _AuditLog;

  String? get stationId => tenantId.isEmpty ? null : tenantId;

  factory AuditLog.fromJson(Map<String, dynamic> json) => _$AuditLogFromJson(json);
}

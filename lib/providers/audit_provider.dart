import 'package:washify/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:washify/features/audit/models/audit_log.dart';
import 'package:washify/repositories/audit_repository.dart';

final auditRepositoryProvider = Provider<AuditRepository>((ref) {
  final user = ref.watch(currentUserProvider);
  return AuditRepository(tenantId: user?.tenantId ?? '');
});

final auditLogsProvider = FutureProvider.family<
    List<AuditLog>,
    ({
      String? stationId,
      String? userId,
      String? module,
      int limit
    })>((ref, arg) async {
  final repo = ref.watch(auditRepositoryProvider);
  return repo.getAuditLogs(
    stationId: arg.stationId,
    userId: arg.userId,
    module: arg.module,
    limit: arg.limit,
  );
});

final auditLogsStreamProvider =
    StreamProvider.family<List<AuditLog>, ({String? stationId, int limit})>(
        (ref, arg) {
  final repo = ref.watch(auditRepositoryProvider);
  return repo.watchAuditLogs(stationId: arg.stationId, limit: arg.limit);
});

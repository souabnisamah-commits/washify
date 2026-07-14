import 'package:washify/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:washify/features/payroll/models/payroll.dart';
import 'package:washify/repositories/payroll_repository.dart';

final payrollRepositoryProvider = Provider<PayrollRepository>((ref) {
  final user = ref.watch(currentUserProvider);
  return PayrollRepository(tenantId: user?.tenantId ?? '');
});

final payrollByStationProvider =
    FutureProvider.family<List<Payroll>, ({String stationId, String? period})>(
        (ref, arg) async {
  final repo = ref.watch(payrollRepositoryProvider);
  return repo.getPayrollByStation(arg.stationId, period: arg.period);
});

final payrollByEmployeeProvider =
    FutureProvider.family<List<Payroll>, String>((ref, employeeId) async {
  final repo = ref.watch(payrollRepositoryProvider);
  return repo.getPayrollByEmployee(employeeId);
});

final payrollByIdProvider =
    FutureProvider.family<Payroll?, String>((ref, payrollId) async {
  final repo = ref.watch(payrollRepositoryProvider);
  return repo.getPayrollById(payrollId);
});

final payrollStreamProvider =
    StreamProvider.family<List<Payroll>, String>((ref, stationId) {
  final repo = ref.watch(payrollRepositoryProvider);
  return repo.watchPayrollByStation(stationId);
});

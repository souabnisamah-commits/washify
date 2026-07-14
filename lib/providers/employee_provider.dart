import 'package:washify/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:washify/features/employees/models/employee.dart';
import 'package:washify/repositories/employee_repository.dart';

final employeeRepositoryProvider = Provider<EmployeeRepository>((ref) {
  final user = ref.watch(currentUserProvider);
  return EmployeeRepository(tenantId: user?.tenantId ?? '');
});

final employeesProvider = FutureProvider<List<Employee>>((ref) async {
  final repo = ref.watch(employeeRepositoryProvider);
  return repo.getAllEmployees();
});

final employeesByStationProvider =
    FutureProvider.family<List<Employee>, String>((ref, stationId) async {
  final repo = ref.watch(employeeRepositoryProvider);
  return repo.getEmployeesByStation(stationId);
});

final employeeByIdProvider =
    FutureProvider.family<Employee?, String>((ref, employeeId) async {
  final repo = ref.watch(employeeRepositoryProvider);
  return repo.getEmployeeById(employeeId);
});

final employeesStreamProvider =
    StreamProvider.family<List<Employee>, String>((ref, stationId) {
  final repo = ref.watch(employeeRepositoryProvider);
  return repo.watchEmployeesByStation(stationId);
});

final employeeByUserIdProvider =
    FutureProvider.family<Employee?, String>((ref, userId) async {
  final repo = ref.watch(employeeRepositoryProvider);
  return repo.getEmployeeByUserId(userId);
});

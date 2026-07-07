import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:washify/features/hr/models/shift.dart';
import 'package:washify/features/hr/models/attendance.dart';
import 'package:washify/features/hr/repositories/hr_repository.dart';

final shiftsStreamProvider = StreamProvider.family<List<Shift>, String>((ref, stationId) {
  final repo = ref.watch(hrRepositoryProvider);
  return repo.watchShifts(stationId);
});

typedef AttendanceQuery = ({String stationId, DateTime date});

final attendancesStreamProvider = StreamProvider.family<List<Attendance>, AttendanceQuery>((ref, query) {
  final repo = ref.watch(hrRepositoryProvider);
  return repo.watchAttendancesByDate(query.stationId, query.date);
});



final employeeAttendancesProvider = StreamProvider.family<List<Attendance>, ({String stationId, String employeeId})>((ref, query) {
  final repo = ref.watch(hrRepositoryProvider);
  return repo.watchAttendancesByEmployee(query.stationId, query.employeeId);
});

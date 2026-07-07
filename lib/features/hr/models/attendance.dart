import 'package:freezed_annotation/freezed_annotation.dart';

part 'attendance.freezed.dart';
part 'attendance.g.dart';

enum AttendanceStatus {
  planned,
  present,
  absent,
}

@freezed
class Attendance with _$Attendance {
  const factory Attendance({
    required String id,
    required String stationId,
    required String employeeId,
    required DateTime date,
    required String shiftId,
    required AttendanceStatus status,
    @Default(0.0) double extraHours,
    @Default(0.0) double deduction,
    required double netDailyWage,
    required DateTime createdAt,
  }) = _Attendance;

  factory Attendance.fromJson(Map<String, dynamic> json) => _$AttendanceFromJson(json);
}

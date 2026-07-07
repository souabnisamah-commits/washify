import 'package:freezed_annotation/freezed_annotation.dart';

part 'shift.freezed.dart';
part 'shift.g.dart';

@freezed
class Shift with _$Shift {
  const factory Shift({
    required String id,
    required String stationId,
    required String name,
    required String startTime, // "HH:mm"
    required String endTime, // "HH:mm"
    required DateTime createdAt,
  }) = _Shift;

  factory Shift.fromJson(Map<String, dynamic> json) => _$ShiftFromJson(json);
}

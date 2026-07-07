// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AttendanceImpl _$$AttendanceImplFromJson(Map<String, dynamic> json) =>
    _$AttendanceImpl(
      id: json['id'] as String,
      stationId: json['stationId'] as String,
      employeeId: json['employeeId'] as String,
      date: DateTime.parse(json['date'] as String),
      shiftId: json['shiftId'] as String,
      status: $enumDecode(_$AttendanceStatusEnumMap, json['status']),
      extraHours: (json['extraHours'] as num?)?.toDouble() ?? 0.0,
      deduction: (json['deduction'] as num?)?.toDouble() ?? 0.0,
      netDailyWage: (json['netDailyWage'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$AttendanceImplToJson(_$AttendanceImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'stationId': instance.stationId,
      'employeeId': instance.employeeId,
      'date': instance.date.toIso8601String(),
      'shiftId': instance.shiftId,
      'status': _$AttendanceStatusEnumMap[instance.status]!,
      'extraHours': instance.extraHours,
      'deduction': instance.deduction,
      'netDailyWage': instance.netDailyWage,
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$AttendanceStatusEnumMap = {
  AttendanceStatus.planned: 'planned',
  AttendanceStatus.present: 'present',
  AttendanceStatus.absent: 'absent',
};

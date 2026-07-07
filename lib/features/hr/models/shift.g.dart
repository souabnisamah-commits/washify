// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shift.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ShiftImpl _$$ShiftImplFromJson(Map<String, dynamic> json) => _$ShiftImpl(
  id: json['id'] as String,
  stationId: json['stationId'] as String,
  name: json['name'] as String,
  startTime: json['startTime'] as String,
  endTime: json['endTime'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$$ShiftImplToJson(_$ShiftImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'stationId': instance.stationId,
      'name': instance.name,
      'startTime': instance.startTime,
      'endTime': instance.endTime,
      'createdAt': instance.createdAt.toIso8601String(),
    };

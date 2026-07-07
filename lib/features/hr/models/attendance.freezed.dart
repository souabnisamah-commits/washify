// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'attendance.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Attendance _$AttendanceFromJson(Map<String, dynamic> json) {
  return _Attendance.fromJson(json);
}

/// @nodoc
mixin _$Attendance {
  String get id => throw _privateConstructorUsedError;
  String get stationId => throw _privateConstructorUsedError;
  String get employeeId => throw _privateConstructorUsedError;
  DateTime get date => throw _privateConstructorUsedError;
  String get shiftId => throw _privateConstructorUsedError;
  AttendanceStatus get status => throw _privateConstructorUsedError;
  double get extraHours => throw _privateConstructorUsedError;
  double get deduction => throw _privateConstructorUsedError;
  double get netDailyWage => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this Attendance to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Attendance
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AttendanceCopyWith<Attendance> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AttendanceCopyWith<$Res> {
  factory $AttendanceCopyWith(
    Attendance value,
    $Res Function(Attendance) then,
  ) = _$AttendanceCopyWithImpl<$Res, Attendance>;
  @useResult
  $Res call({
    String id,
    String stationId,
    String employeeId,
    DateTime date,
    String shiftId,
    AttendanceStatus status,
    double extraHours,
    double deduction,
    double netDailyWage,
    DateTime createdAt,
  });
}

/// @nodoc
class _$AttendanceCopyWithImpl<$Res, $Val extends Attendance>
    implements $AttendanceCopyWith<$Res> {
  _$AttendanceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Attendance
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? stationId = null,
    Object? employeeId = null,
    Object? date = null,
    Object? shiftId = null,
    Object? status = null,
    Object? extraHours = null,
    Object? deduction = null,
    Object? netDailyWage = null,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            stationId: null == stationId
                ? _value.stationId
                : stationId // ignore: cast_nullable_to_non_nullable
                      as String,
            employeeId: null == employeeId
                ? _value.employeeId
                : employeeId // ignore: cast_nullable_to_non_nullable
                      as String,
            date: null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            shiftId: null == shiftId
                ? _value.shiftId
                : shiftId // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as AttendanceStatus,
            extraHours: null == extraHours
                ? _value.extraHours
                : extraHours // ignore: cast_nullable_to_non_nullable
                      as double,
            deduction: null == deduction
                ? _value.deduction
                : deduction // ignore: cast_nullable_to_non_nullable
                      as double,
            netDailyWage: null == netDailyWage
                ? _value.netDailyWage
                : netDailyWage // ignore: cast_nullable_to_non_nullable
                      as double,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AttendanceImplCopyWith<$Res>
    implements $AttendanceCopyWith<$Res> {
  factory _$$AttendanceImplCopyWith(
    _$AttendanceImpl value,
    $Res Function(_$AttendanceImpl) then,
  ) = __$$AttendanceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String stationId,
    String employeeId,
    DateTime date,
    String shiftId,
    AttendanceStatus status,
    double extraHours,
    double deduction,
    double netDailyWage,
    DateTime createdAt,
  });
}

/// @nodoc
class __$$AttendanceImplCopyWithImpl<$Res>
    extends _$AttendanceCopyWithImpl<$Res, _$AttendanceImpl>
    implements _$$AttendanceImplCopyWith<$Res> {
  __$$AttendanceImplCopyWithImpl(
    _$AttendanceImpl _value,
    $Res Function(_$AttendanceImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Attendance
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? stationId = null,
    Object? employeeId = null,
    Object? date = null,
    Object? shiftId = null,
    Object? status = null,
    Object? extraHours = null,
    Object? deduction = null,
    Object? netDailyWage = null,
    Object? createdAt = null,
  }) {
    return _then(
      _$AttendanceImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        stationId: null == stationId
            ? _value.stationId
            : stationId // ignore: cast_nullable_to_non_nullable
                  as String,
        employeeId: null == employeeId
            ? _value.employeeId
            : employeeId // ignore: cast_nullable_to_non_nullable
                  as String,
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        shiftId: null == shiftId
            ? _value.shiftId
            : shiftId // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as AttendanceStatus,
        extraHours: null == extraHours
            ? _value.extraHours
            : extraHours // ignore: cast_nullable_to_non_nullable
                  as double,
        deduction: null == deduction
            ? _value.deduction
            : deduction // ignore: cast_nullable_to_non_nullable
                  as double,
        netDailyWage: null == netDailyWage
            ? _value.netDailyWage
            : netDailyWage // ignore: cast_nullable_to_non_nullable
                  as double,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AttendanceImpl implements _Attendance {
  const _$AttendanceImpl({
    required this.id,
    required this.stationId,
    required this.employeeId,
    required this.date,
    required this.shiftId,
    required this.status,
    this.extraHours = 0.0,
    this.deduction = 0.0,
    required this.netDailyWage,
    required this.createdAt,
  });

  factory _$AttendanceImpl.fromJson(Map<String, dynamic> json) =>
      _$$AttendanceImplFromJson(json);

  @override
  final String id;
  @override
  final String stationId;
  @override
  final String employeeId;
  @override
  final DateTime date;
  @override
  final String shiftId;
  @override
  final AttendanceStatus status;
  @override
  @JsonKey()
  final double extraHours;
  @override
  @JsonKey()
  final double deduction;
  @override
  final double netDailyWage;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'Attendance(id: $id, stationId: $stationId, employeeId: $employeeId, date: $date, shiftId: $shiftId, status: $status, extraHours: $extraHours, deduction: $deduction, netDailyWage: $netDailyWage, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AttendanceImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.stationId, stationId) ||
                other.stationId == stationId) &&
            (identical(other.employeeId, employeeId) ||
                other.employeeId == employeeId) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.shiftId, shiftId) || other.shiftId == shiftId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.extraHours, extraHours) ||
                other.extraHours == extraHours) &&
            (identical(other.deduction, deduction) ||
                other.deduction == deduction) &&
            (identical(other.netDailyWage, netDailyWage) ||
                other.netDailyWage == netDailyWage) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    stationId,
    employeeId,
    date,
    shiftId,
    status,
    extraHours,
    deduction,
    netDailyWage,
    createdAt,
  );

  /// Create a copy of Attendance
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AttendanceImplCopyWith<_$AttendanceImpl> get copyWith =>
      __$$AttendanceImplCopyWithImpl<_$AttendanceImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AttendanceImplToJson(this);
  }
}

abstract class _Attendance implements Attendance {
  const factory _Attendance({
    required final String id,
    required final String stationId,
    required final String employeeId,
    required final DateTime date,
    required final String shiftId,
    required final AttendanceStatus status,
    final double extraHours,
    final double deduction,
    required final double netDailyWage,
    required final DateTime createdAt,
  }) = _$AttendanceImpl;

  factory _Attendance.fromJson(Map<String, dynamic> json) =
      _$AttendanceImpl.fromJson;

  @override
  String get id;
  @override
  String get stationId;
  @override
  String get employeeId;
  @override
  DateTime get date;
  @override
  String get shiftId;
  @override
  AttendanceStatus get status;
  @override
  double get extraHours;
  @override
  double get deduction;
  @override
  double get netDailyWage;
  @override
  DateTime get createdAt;

  /// Create a copy of Attendance
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AttendanceImplCopyWith<_$AttendanceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

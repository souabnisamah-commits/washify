import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:washify/features/hr/models/shift.dart';
import 'package:washify/features/hr/models/attendance.dart';

final hrRepositoryProvider = Provider((ref) => HRRepository());

class HRRepository {
  final FirebaseFirestore _firestore;

  HRRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference get _shiftsRef =>
      _firestore.collection('shifts');

  CollectionReference get _attendancesRef =>
      _firestore.collection('attendances');

  // --- Shifts ---

  Future<void> createShift(Shift shift) async {
    final docRef = _shiftsRef.doc();
    final newShift = shift.copyWith(id: docRef.id);
    await docRef.set(newShift.toJson());
  }

  Future<void> updateShift(Shift shift) async {
    await _shiftsRef.doc(shift.id).update(shift.toJson());
  }

  Future<void> deleteShift(String shiftId) async {
    await _shiftsRef.doc(shiftId).delete();
  }

  Stream<List<Shift>> watchShifts(String stationId) {
    return _shiftsRef
        .where('stationId', isEqualTo: stationId)
        .orderBy('startTime')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Shift.fromJson({...doc.data() as Map<String, dynamic>, 'id': doc.id}))
            .toList());
  }

  // --- Attendance ---

  Future<void> createAttendance(Attendance attendance) async {
    final docRef = _attendancesRef.doc();
    final newAtt = attendance.copyWith(id: docRef.id);
    await docRef.set(newAtt.toJson());
  }

  Future<void> updateAttendance(Attendance attendance) async {
    await _attendancesRef.doc(attendance.id).update(attendance.toJson());
  }

  Future<void> deleteAttendance(String attendanceId) async {
    await _attendancesRef.doc(attendanceId).delete();
  }

  Stream<List<Attendance>> watchAttendancesByDateAndShift(String stationId, DateTime date, String shiftId) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _attendancesRef
        .where('stationId', isEqualTo: stationId)
        .where('shiftId', isEqualTo: shiftId)
        .where('date', isGreaterThanOrEqualTo: startOfDay.toIso8601String())
        .where('date', isLessThan: endOfDay.toIso8601String())
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              if (data['date'] is Timestamp) {
                data['date'] = (data['date'] as Timestamp).toDate().toIso8601String();
              }
              if (data['createdAt'] is Timestamp) {
                data['createdAt'] = (data['createdAt'] as Timestamp).toDate().toIso8601String();
              }
              // Migration: if isPresent exists, convert to status
              if (data.containsKey('isPresent') && !data.containsKey('status')) {
                data['status'] = data['isPresent'] == true ? 'present' : 'absent';
              }
              return Attendance.fromJson({...data, 'id': doc.id});
            })
            .toList());
  }

  Stream<List<Attendance>> watchAttendancesByDate(String stationId, DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _attendancesRef
        .where('stationId', isEqualTo: stationId)
        .where('date', isGreaterThanOrEqualTo: startOfDay.toIso8601String())
        .where('date', isLessThan: endOfDay.toIso8601String())
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              if (data['date'] is Timestamp) {
                data['date'] = (data['date'] as Timestamp).toDate().toIso8601String();
              }
              if (data['createdAt'] is Timestamp) {
                data['createdAt'] = (data['createdAt'] as Timestamp).toDate().toIso8601String();
              }
              // Migration: if isPresent exists, convert to status
              if (data.containsKey('isPresent') && !data.containsKey('status')) {
                data['status'] = data['isPresent'] == true ? 'present' : 'absent';
              }
              return Attendance.fromJson({...data, 'id': doc.id});
            })
            .toList());
  }

  Stream<List<Attendance>> watchAttendancesByEmployee(String stationId, String employeeId) {
    return _attendancesRef
        .where('stationId', isEqualTo: stationId)
        .where('employeeId', isEqualTo: employeeId)
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            if (data['date'] is Timestamp) {
              data['date'] = (data['date'] as Timestamp).toDate().toIso8601String();
            }
            if (data['createdAt'] is Timestamp) {
              data['createdAt'] = (data['createdAt'] as Timestamp).toDate().toIso8601String();
            }
            if (data.containsKey('isPresent') && !data.containsKey('status')) {
              data['status'] = data['isPresent'] == true ? 'present' : 'absent';
            }
            return Attendance.fromJson({...data, 'id': doc.id});
          }).toList();
          list.sort((a, b) => a.date.compareTo(b.date));
          return list;
        });
  }
}

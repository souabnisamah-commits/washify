import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:washify/core/constants/app_constants.dart';
import 'package:washify/features/payroll/models/payroll.dart';

class PayrollRepository {
  final FirebaseFirestore _firestore;

  PayrollRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference get _payrollRef =>
      _firestore.collection(AppConstants.payrollCollection);

  Payroll _payrollFromDoc(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    return Payroll.fromJson({
      ...data,
      'id': doc.id,
      'employeeId': data['employeeId'] ?? '',
      'employeeName': data['employeeName'] ?? '',
      'tenantId': data['tenantId'] ?? data['stationId'] ?? '',
      'baseSalary': (data['baseSalary'] as num?)?.toDouble() ?? 0.0,
      'commissionTotal': (data['commissionTotal'] as num?)?.toDouble() ?? 0.0,
      'bonuses': (data['bonuses'] as num?)?.toDouble() ?? 0.0,
      'deductions': (data['deductions'] as num?)?.toDouble() ?? 0.0,
      'netAmount': (data['netAmount'] as num?)?.toDouble() ?? 0.0,
      'period': data['period'] ?? '',
      'status': data['status'] ?? 'pending',
      'approvedBy': data['approvedBy'],
      'paidAt': (data['paidAt'] as Timestamp?)?.toDate().toIso8601String(),
      'createdAt': (data['createdAt'] as Timestamp?)?.toDate().toIso8601String() ?? DateTime.now().toIso8601String(),
      'updatedAt': (data['updatedAt'] as Timestamp?)?.toDate().toIso8601String() ?? DateTime.now().toIso8601String(),
    });
  }

  Map<String, dynamic> _payrollToDoc(Payroll payroll) {
    final data = payroll.toJson();
    data.remove('id');
    data['paidAt'] = payroll.paidAt != null ? Timestamp.fromDate(payroll.paidAt!) : null;
    data['createdAt'] = Timestamp.fromDate(payroll.createdAt);
    data['updatedAt'] = Timestamp.fromDate(payroll.updatedAt);
    data['stationId'] = payroll.tenantId;
    data['stationName'] = '';
    return data;
  }

  Future<List<Payroll>> getPayrollByStation(String stationId,
      {String? period}) async {
    Query query = _payrollRef
        .where('stationId', isEqualTo: stationId)
        .orderBy('createdAt', descending: true);

    if (period != null) {
      query = query.where('period', isEqualTo: period);
    }

    final querySnapshot = await query.get();
    return querySnapshot.docs
        .map((doc) => _payrollFromDoc(doc))
        .toList();
  }

  Future<List<Payroll>> getPayrollByEmployee(String employeeId) async {
    final querySnapshot = await _payrollRef
        .where('employeeId', isEqualTo: employeeId)
        .orderBy('createdAt', descending: true)
        .get();
    return querySnapshot.docs
        .map((doc) => _payrollFromDoc(doc))
        .toList();
  }

  Future<Payroll?> getPayrollById(String payrollId) async {
    final doc = await _payrollRef.doc(payrollId).get();
    if (!doc.exists) return null;
    return _payrollFromDoc(doc);
  }

  Future<String> createPayroll(Payroll payroll) async {
    final docRef = await _payrollRef.add(_payrollToDoc(payroll));
    return docRef.id;
  }

  Future<void> updatePayroll(Payroll payroll) async {
    await _payrollRef.doc(payroll.id).update(_payrollToDoc(payroll));
  }

  Future<void> approvePayroll(String payrollId, String approvedBy) async {
    await _payrollRef.doc(payrollId).update({
      'status': AppConstants.payrollApproved,
      'approvedBy': approvedBy,
      'updatedAt': Timestamp.now(),
    });
  }

  Future<void> markAsPaid(String payrollId) async {
    await _payrollRef.doc(payrollId).update({
      'status': AppConstants.payrollPaid,
      'paidAt': Timestamp.now(),
      'updatedAt': Timestamp.now(),
    });
  }

  Stream<List<Payroll>> watchPayrollByStation(String stationId) {
    return _payrollRef
        .where('stationId', isEqualTo: stationId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => _payrollFromDoc(doc)).toList());
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:washify/core/constants/app_constants.dart';
import 'package:washify/features/audit/models/audit_log.dart';

class AuditRepository {
  final FirebaseFirestore _firestore;
  final String tenantId;

  AuditRepository({FirebaseFirestore? firestore, this.tenantId = ''})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference get _auditRef =>
      _firestore.collection(AppConstants.auditLogsCollection);

  AuditLog _auditFromDoc(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    return AuditLog.fromJson({
      ...data,
      'id': doc.id,
      'tenantId': data['tenantId'] ?? data['stationId'] ?? '',
      'userId': data['userId'] ?? '',
      'userName': data['userName'] ?? '',
      'action': data['action'] ?? '',
      'module': data['module'] ?? '',
      'description': data['description'] ?? '',
      'previousData': data['previousData'],
      'newData': data['newData'],
      'createdAt': (data['createdAt'] as Timestamp?)?.toDate().toIso8601String() ?? DateTime.now().toIso8601String(),
    });
  }

  Map<String, dynamic> _auditToDoc(AuditLog log) {
    final data = log.toJson();
    data.remove('id');
    data['createdAt'] = Timestamp.fromDate(log.createdAt);
    data['stationId'] = log.tenantId;
    return data;
  }

  Future<void> log({
    required String userId,
    required String userName,
    required String action,
    required String module,
    required String description,
    Map<String, dynamic>? previousData,
    Map<String, dynamic>? newData,
    String? stationId,
  }) async {
    final auditLog = AuditLog(
      id: '',
      userId: userId,
      userName: userName,
      action: action,
      module: module,
      description: description,
      previousData: previousData,
      newData: newData,
      tenantId: stationId ?? '',
      createdAt: DateTime.now(),
    );
    await _auditRef.add(_auditToDoc(auditLog));
  }

  Future<List<AuditLog>> getAuditLogs({
    String? stationId,
    String? userId,
    String? module,
    int limit = 100,
  }) async {
    Query query = _auditRef.orderBy('createdAt', descending: true).limit(limit);

    if (stationId != null) {
      query = query.where('stationId', isEqualTo: stationId);
    }
    if (userId != null) {
      query = query.where('userId', isEqualTo: userId);
    }
    if (module != null) {
      query = query.where('module', isEqualTo: module);
    }

    final querySnapshot = await query.get();
    return querySnapshot.docs
        .map((doc) => _auditFromDoc(doc))
        .toList();
  }

  Stream<List<AuditLog>> watchAuditLogs({String? stationId, int limit = 50}) {
    Query query = _auditRef.orderBy('createdAt', descending: true).limit(limit);

    if (stationId != null) {
      query = query.where('stationId', isEqualTo: stationId);
    }

    return query.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => _auditFromDoc(doc)).toList());
  }
}

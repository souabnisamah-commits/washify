import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:washify/core/constants/app_constants.dart';
import 'package:washify/features/services/models/vehicle_category.dart';

class VehicleCategoryRepository {
  final FirebaseFirestore _firestore;
  final String tenantId;

  VehicleCategoryRepository({FirebaseFirestore? firestore, this.tenantId = ''})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference get _ref =>
      _firestore.collection(AppConstants.vehicleCategoriesCollection);

  VehicleCategory _fromDoc(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    data['id'] = doc.id;

    if (data['createdAt'] is Timestamp) {
      data['createdAt'] = (data['createdAt'] as Timestamp).toDate().toIso8601String();
    }
    if (data['updatedAt'] is Timestamp) {
      data['updatedAt'] = (data['updatedAt'] as Timestamp).toDate().toIso8601String();
    }

    // Backward compat: stationId -> tenantId
    if (data['tenantId'] == null && data['stationId'] != null) {
      data['tenantId'] = data['stationId'];
    } else if (data['tenantId'] == null) {
      data['tenantId'] = '';
    }

    return VehicleCategory.fromJson(data);
  }

  Map<String, dynamic> _toDoc(VehicleCategory category) {
    final map = category.toJson();
    map.remove('id');
    map['stationId'] = category.tenantId;
    map['createdAt'] = Timestamp.fromDate(category.createdAt);
    map['updatedAt'] = Timestamp.fromDate(category.updatedAt);
    return map;
  }

  Future<List<VehicleCategory>> getByStation(String stationId) async {
    final snapshot = await _ref
        .where('stationId', isEqualTo: stationId)
        .where('isActive', isEqualTo: true)
        .orderBy('sortOrder')
        .get();
    return snapshot.docs.map((doc) => _fromDoc(doc)).toList();
  }

  Stream<List<VehicleCategory>> watchByStation(String stationId) {
    return _ref
        .where('stationId', isEqualTo: stationId)
        .where('isActive', isEqualTo: true)
        .orderBy('sortOrder')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => _fromDoc(doc)).toList());
  }

  Future<String> create(VehicleCategory category) async {
    final docRef = await _ref.add(_toDoc(category));
    return docRef.id;
  }

  Future<void> update(VehicleCategory category) async {
    await _ref.doc(category.id).update(_toDoc(category));
  }

  Future<void> delete(String id) async {
    await _ref.doc(id).update({
      'isActive': false,
      'updatedAt': Timestamp.now(),
    });
  }
}

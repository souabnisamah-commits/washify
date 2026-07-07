import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:washify/core/constants/app_constants.dart';
import 'package:washify/features/services/models/service_definition.dart';

class ServiceDefinitionRepository {
  final FirebaseFirestore _firestore;

  ServiceDefinitionRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference get _ref =>
      _firestore.collection(AppConstants.serviceDefinitionsCollection);

  ServiceDefinition _fromDoc(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    data['id'] = doc.id;

    if (data['createdAt'] is Timestamp) {
      data['createdAt'] = (data['createdAt'] as Timestamp).toDate().toIso8601String();
    }
    if (data['updatedAt'] is Timestamp) {
      data['updatedAt'] = (data['updatedAt'] as Timestamp).toDate().toIso8601String();
    }

    if (data['tenantId'] == null && data['stationId'] != null) {
      data['tenantId'] = data['stationId'];
    } else if (data['tenantId'] == null) {
      data['tenantId'] = '';
    }

    return ServiceDefinition.fromJson(data);
  }

  Map<String, dynamic> _toDoc(ServiceDefinition service) {
    final map = service.toJson();
    map.remove('id');
    map['stationId'] = service.tenantId;
    map['createdAt'] = Timestamp.fromDate(service.createdAt);
    map['updatedAt'] = Timestamp.fromDate(service.updatedAt);
    return map;
  }

  Future<List<ServiceDefinition>> getByStation(String stationId) async {
    final snapshot = await _ref
        .where('stationId', isEqualTo: stationId)
        .where('isActive', isEqualTo: true)
        .orderBy('sortOrder')
        .get();
    return snapshot.docs.map((doc) => _fromDoc(doc)).toList();
  }

  Future<List<ServiceDefinition>> getByStationAndType(
      String stationId, ServiceType type) async {
    final snapshot = await _ref
        .where('stationId', isEqualTo: stationId)
        .where('serviceType', isEqualTo: type.value)
        .where('isActive', isEqualTo: true)
        .orderBy('sortOrder')
        .get();
    return snapshot.docs.map((doc) => _fromDoc(doc)).toList();
  }

  Stream<List<ServiceDefinition>> watchByStation(String stationId) {
    return _ref
        .where('stationId', isEqualTo: stationId)
        .where('isActive', isEqualTo: true)
        .orderBy('sortOrder')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => _fromDoc(doc)).toList());
  }

  Stream<List<ServiceDefinition>> watchByStationAndType(
      String stationId, ServiceType type) {
    return _ref
        .where('stationId', isEqualTo: stationId)
        .where('serviceType', isEqualTo: type.value)
        .where('isActive', isEqualTo: true)
        .orderBy('sortOrder')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => _fromDoc(doc)).toList());
  }

  Future<String> create(ServiceDefinition service) async {
    final docRef = await _ref.add(_toDoc(service));
    return docRef.id;
  }

  Future<void> update(ServiceDefinition service) async {
    await _ref.doc(service.id).update(_toDoc(service));
  }

  Future<void> delete(String id) async {
    await _ref.doc(id).update({
      'isActive': false,
      'updatedAt': Timestamp.now(),
    });
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:washify/core/constants/app_constants.dart';
import 'package:washify/features/services/models/wash_service.dart';

class ServiceRepository {
  final FirebaseFirestore _firestore;

  ServiceRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference get _servicesRef =>
      _firestore.collection(AppConstants.servicesCollection);

  WashService _serviceFromDoc(DocumentSnapshot doc) {
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

    if (data['description'] == null) data['description'] = '';
    if (data['price'] == null) data['price'] = 0.0;
    if (data['durationMinutes'] == null) data['durationMinutes'] = 30;

    return WashService.fromJson(data);
  }

  Map<String, dynamic> _serviceToDoc(WashService service) {
    final map = service.toJson();
    map.remove('id');
    map['stationId'] = service.tenantId;
    map['createdAt'] = Timestamp.fromDate(service.createdAt);
    map['updatedAt'] = Timestamp.fromDate(service.updatedAt);
    return map;
  }

  Future<List<WashService>> getAllServices() async {
    final querySnapshot = await _servicesRef.orderBy('name').get();
    return querySnapshot.docs.map((doc) => _serviceFromDoc(doc)).toList();
  }

  Future<List<WashService>> getServicesByStation(String stationId) async {
    final querySnapshot = await _servicesRef
        .where('stationId', isEqualTo: stationId)
        .where('isActive', isEqualTo: true)
        .orderBy('name')
        .get();
    return querySnapshot.docs.map((doc) => _serviceFromDoc(doc)).toList();
  }

  Future<WashService?> getServiceById(String serviceId) async {
    final doc = await _servicesRef.doc(serviceId).get();
    if (!doc.exists) return null;
    return _serviceFromDoc(doc);
  }

  Future<String> createService(WashService service) async {
    final docRef = await _servicesRef.add(_serviceToDoc(service));
    return docRef.id;
  }

  Future<void> updateService(WashService service) async {
    await _servicesRef.doc(service.id).update(_serviceToDoc(service));
  }

  Future<void> deleteService(String serviceId) async {
    await _servicesRef.doc(serviceId).update({
      'isActive': false,
      'updatedAt': Timestamp.now(),
    });
  }

  Stream<List<WashService>> watchServicesByStation(String stationId) {
    return _servicesRef
        .where('stationId', isEqualTo: stationId)
        .where('isActive', isEqualTo: true)
        .orderBy('name')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => _serviceFromDoc(doc)).toList());
  }
}

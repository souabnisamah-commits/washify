import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:washify/core/constants/app_constants.dart';
import 'package:washify/features/station/models/station.dart';

class StationRepository {
  final FirebaseFirestore _firestore;
  final String tenantId;

  StationRepository({FirebaseFirestore? firestore, this.tenantId = ''})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference get _stationsRef =>
      _firestore.collection(AppConstants.stationsCollection);

  Station _stationFromDoc(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    data['id'] = doc.id;

    if (data['createdAt'] is Timestamp) {
      data['createdAt'] = (data['createdAt'] as Timestamp).toDate().toIso8601String();
    }
    if (data['updatedAt'] is Timestamp) {
      data['updatedAt'] = (data['updatedAt'] as Timestamp).toDate().toIso8601String();
    }
    if (data['subscriptionDate'] is Timestamp) {
      data['subscriptionDate'] = (data['subscriptionDate'] as Timestamp).toDate().toIso8601String();
    }
    if (data['expiryDate'] is Timestamp) {
      data['expiryDate'] = (data['expiryDate'] as Timestamp).toDate().toIso8601String();
    }

    // Fallbacks for legacy DB records
    if (data['tenantId'] == null && data['patronId'] != null) {
      data['tenantId'] = data['patronId'];
    } else if (data['tenantId'] == null) {
      data['tenantId'] = '';
    }

    if (data['gerantName'] == null) data['gerantName'] = '';
    if (data['email'] == null) data['email'] = '';
    if (data['matriculeFiscale'] == null) data['matriculeFiscale'] = '';
    if (data['latitude'] == null) data['latitude'] = 0.0;
    if (data['longitude'] == null) data['longitude'] = 0.0;
    if (data['logoUrl'] == null) data['logoUrl'] = '';
    if (data['licence'] == null) data['licence'] = 'suspended';

    return Station.fromJson(data);
  }

  Map<String, dynamic> _stationToDoc(Station station) {
    final map = station.toJson();
    map.remove('id');
    map['patronId'] = station.tenantId;
    map['createdAt'] = Timestamp.fromDate(station.createdAt);
    map['updatedAt'] = Timestamp.fromDate(station.updatedAt);
    if (station.subscriptionDate != null) {
      map['subscriptionDate'] = Timestamp.fromDate(station.subscriptionDate!);
    }
    if (station.expiryDate != null) {
      map['expiryDate'] = Timestamp.fromDate(station.expiryDate!);
    }
    return map;
  }

  Future<List<Station>> getAllStations() async {
    final querySnapshot = await _stationsRef
        .orderBy('name')
        .get();
    return querySnapshot.docs.map((doc) => _stationFromDoc(doc)).toList();
  }

  Future<List<Station>> getActiveStations() async {
    final querySnapshot = await _stationsRef
        .where('isActive', isEqualTo: true)
        .orderBy('name')
        .get();
    return querySnapshot.docs.map((doc) => _stationFromDoc(doc)).toList();
  }

  Future<Station?> getStationById(String stationId) async {
    final doc = await _stationsRef.doc(stationId).get();
    if (!doc.exists) return null;
    return _stationFromDoc(doc);
  }

  Future<List<Station>> getStationsByPatron(String patronId) async {
    final querySnapshot = await _stationsRef
        .where('patronId', isEqualTo: patronId)
        .orderBy('name')
        .get();
    return querySnapshot.docs.map((doc) => _stationFromDoc(doc)).toList();
  }

  Future<String> createStation(Station station) async {
    final docRef = await _stationsRef.add(_stationToDoc(station));
    return docRef.id;
  }

  Future<void> updateStation(Station station) async {
    await _stationsRef.doc(station.id).update(_stationToDoc(station));
  }

  Future<void> deleteStation(String stationId) async {
    await _stationsRef.doc(stationId).update({
      'isActive': false,
      'updatedAt': Timestamp.now(),
    });
  }

  Stream<List<Station>> watchStations() {
    return _stationsRef
        .where('isActive', isEqualTo: true)
        .orderBy('name')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => _stationFromDoc(doc)).toList());
  }
}

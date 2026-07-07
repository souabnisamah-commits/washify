import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:washify/core/constants/app_constants.dart';
import 'package:washify/features/services/models/offer.dart';

class OfferRepository {
  final FirebaseFirestore _firestore;

  OfferRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference get _ref =>
      _firestore.collection(AppConstants.offersCollection);

  Offer _fromDoc(DocumentSnapshot doc) {
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

    return Offer.fromJson(data);
  }

  Map<String, dynamic> _toDoc(Offer offer) {
    final map = offer.toJson();
    map.remove('id');
    map['stationId'] = offer.tenantId;
    map['createdAt'] = Timestamp.fromDate(offer.createdAt);
    map['updatedAt'] = Timestamp.fromDate(offer.updatedAt);
    return map;
  }

  Future<List<Offer>> getByStation(String stationId) async {
    final snapshot = await _ref
        .where('stationId', isEqualTo: stationId)
        .where('isActive', isEqualTo: true)
        .orderBy('name')
        .get();
    return snapshot.docs.map((doc) => _fromDoc(doc)).toList();
  }

  Stream<List<Offer>> watchByStation(String stationId) {
    return _ref
        .where('stationId', isEqualTo: stationId)
        .where('isActive', isEqualTo: true)
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => _fromDoc(doc)).toList());
  }

  Future<String> create(Offer offer) async {
    final docRef = await _ref.add(_toDoc(offer));
    return docRef.id;
  }

  Future<void> update(Offer offer) async {
    await _ref.doc(offer.id).update(_toDoc(offer));
  }

  Future<void> delete(String id) async {
    await _ref.doc(id).update({
      'isActive': false,
      'updatedAt': Timestamp.now(),
    });
  }
}

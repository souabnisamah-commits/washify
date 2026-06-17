import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:washify/core/constants/app_constants.dart';
import 'package:washify/features/inventory/models/inventory.dart';

class InventoryRepository {
  final FirebaseFirestore _firestore;

  InventoryRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference get _inventoriesRef =>
      _firestore.collection(AppConstants.inventoriesCollection);

  Inventory _inventoryFromDoc(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    data['id'] = doc.id;

    if (data['createdAt'] is Timestamp) {
      data['createdAt'] = (data['createdAt'] as Timestamp).toDate().toIso8601String();
    }
    if (data['date'] is Timestamp) {
      data['date'] = (data['date'] as Timestamp).toDate().toIso8601String();
    }

    if (data['tenantId'] == null && data['stationId'] != null) {
      data['tenantId'] = data['stationId'];
    } else if (data['tenantId'] == null) {
      data['tenantId'] = '';
    }

    if (data['notes'] == null) data['notes'] = '';

    return Inventory.fromJson(data);
  }

  Map<String, dynamic> _inventoryToDoc(Inventory inventory) {
    final map = inventory.toJson();
    map.remove('id');
    map['stationId'] = inventory.tenantId;
    map['date'] = Timestamp.fromDate(inventory.date);
    map['createdAt'] = Timestamp.fromDate(inventory.createdAt);
    return map;
  }

  Future<List<Inventory>> getInventoriesByStation(String stationId,
      {int limit = 20}) async {
    final querySnapshot = await _inventoriesRef
        .where('stationId', isEqualTo: stationId)
        .orderBy('date', descending: true)
        .limit(limit)
        .get();
    return querySnapshot.docs.map((doc) => _inventoryFromDoc(doc)).toList();
  }

  Future<Inventory?> getInventoryById(String inventoryId) async {
    final doc = await _inventoriesRef.doc(inventoryId).get();
    if (!doc.exists) return null;
    return _inventoryFromDoc(doc);
  }

  Future<String> createInventory(Inventory inventory) async {
    final docRef = await _inventoriesRef.add(_inventoryToDoc(inventory));
    return docRef.id;
  }

  Stream<List<Inventory>> watchInventoriesByStation(String stationId) {
    return _inventoriesRef
        .where('stationId', isEqualTo: stationId)
        .orderBy('date', descending: true)
        .limit(20)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => _inventoryFromDoc(doc)).toList());
  }
}

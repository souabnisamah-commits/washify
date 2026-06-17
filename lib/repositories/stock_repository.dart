import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:washify/core/constants/app_constants.dart';
import 'package:washify/features/stock/models/stock.dart';

class StockRepository {
  final FirebaseFirestore _firestore;

  StockRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference get _stockRef =>
      _firestore.collection(AppConstants.stockCollection);

  CollectionReference get _movementsRef =>
      _firestore.collection('stock_movements');

  StockLevel _levelFromDoc(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    data['id'] = doc.id;

    if (data['updatedAt'] is Timestamp) {
      data['updatedAt'] = (data['updatedAt'] as Timestamp).toDate().toIso8601String();
    }

    if (data['tenantId'] == null && data['stationId'] != null) {
      data['tenantId'] = data['stationId'];
    } else if (data['tenantId'] == null) {
      data['tenantId'] = '';
    }

    return StockLevel.fromJson(data);
  }

  Map<String, dynamic> _levelToDoc(StockLevel level) {
    final map = level.toJson();
    map.remove('id');
    map['stationId'] = level.tenantId;
    map['updatedAt'] = Timestamp.fromDate(level.updatedAt);
    return map;
  }

  StockMovement _movementFromDoc(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    data['id'] = doc.id;

    if (data['createdAt'] is Timestamp) {
      data['createdAt'] = (data['createdAt'] as Timestamp).toDate().toIso8601String();
    }

    if (data['tenantId'] == null && data['stationId'] != null) {
      data['tenantId'] = data['stationId'];
    } else if (data['tenantId'] == null) {
      data['tenantId'] = '';
    }

    return StockMovement.fromJson(data);
  }

  Map<String, dynamic> _movementToDoc(StockMovement movement) {
    final map = movement.toJson();
    map.remove('id');
    map['stationId'] = movement.tenantId;
    map['createdAt'] = Timestamp.fromDate(movement.createdAt);
    return map;
  }

  Future<List<StockLevel>> getStockByStation(String stationId) async {
    final querySnapshot = await _stockRef
        .where('stationId', isEqualTo: stationId)
        .orderBy('productName')
        .get();
    return querySnapshot.docs.map((doc) => _levelFromDoc(doc)).toList();
  }

  Future<StockLevel?> getStockLevel(String stationId, String productId) async {
    final querySnapshot = await _stockRef
        .where('stationId', isEqualTo: stationId)
        .where('productId', isEqualTo: productId)
        .limit(1)
        .get();
    if (querySnapshot.docs.isEmpty) return null;
    return _levelFromDoc(querySnapshot.docs.first);
  }

  Future<void> updateStockLevel(StockLevel stockLevel) async {
    final querySnapshot = await _stockRef
        .where('stationId', isEqualTo: stockLevel.stationId)
        .where('productId', isEqualTo: stockLevel.productId)
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) {
      await _stockRef.add(_levelToDoc(stockLevel));
    } else {
      await _stockRef.doc(querySnapshot.docs.first.id).update(_levelToDoc(stockLevel));
    }
  }

  Future<void> addStockMovement(StockMovement movement) async {
    await _movementsRef.add(_movementToDoc(movement));
  }

  Future<List<StockMovement>> getStockMovements(String stationId,
      {String? productId, int limit = 50}) async {
    Query query = _movementsRef
        .where('stationId', isEqualTo: stationId)
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (productId != null) {
      query = query.where('productId', isEqualTo: productId);
    }

    final querySnapshot = await query.get();
    return querySnapshot.docs.map((doc) => _movementFromDoc(doc)).toList();
  }

  Future<List<StockLevel>> getLowStockItems(String stationId) async {
    final allStock = await getStockByStation(stationId);
    return allStock.where((stock) => stock.isLowStock).toList();
  }

  Stream<List<StockLevel>> watchStockByStation(String stationId) {
    return _stockRef
        .where('stationId', isEqualTo: stationId)
        .orderBy('productName')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => _levelFromDoc(doc)).toList());
  }
}

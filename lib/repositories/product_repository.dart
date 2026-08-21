import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:washify/core/constants/app_constants.dart';
import 'package:washify/features/products/models/product.dart';

class ProductRepository {
  final FirebaseFirestore _firestore;
  final String tenantId;

  ProductRepository({FirebaseFirestore? firestore, this.tenantId = ''})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference get _productsRef =>
      _firestore.collection(AppConstants.productsCollection);

  Product _productFromDoc(DocumentSnapshot doc) {
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
    if (data['family'] == null) data['family'] = 'produit';
    if (data['unit'] == null) data['unit'] = 'unité';
    if (data['unitPrice'] == null) data['unitPrice'] = 0.0;
    if (data['minStock'] == null) data['minStock'] = 5;

    return Product.fromJson(data);
  }

  Map<String, dynamic> _productToDoc(Product product) {
    final map = product.toJson();
    map.remove('id');
    map['stationId'] = product.tenantId;
    map['createdAt'] = Timestamp.fromDate(product.createdAt);
    map['updatedAt'] = Timestamp.fromDate(product.updatedAt);
    return map;
  }

  Future<List<Product>> getAllProducts() async {
    final querySnapshot = await _productsRef.orderBy('name').get();
    return querySnapshot.docs.map((doc) => _productFromDoc(doc)).toList();
  }

  Future<List<Product>> getProductsByStation(String stationId) async {
    final querySnapshot = await _productsRef
        .where('stationId', isEqualTo: stationId)
        .where('isActive', isEqualTo: true)
        .orderBy('name')
        .get();
    return querySnapshot.docs.map((doc) => _productFromDoc(doc)).toList();
  }

  Future<Product?> getProductById(String productId) async {
    final doc = await _productsRef.doc(productId).get();
    if (!doc.exists) return null;
    return _productFromDoc(doc);
  }

  Future<Product?> getProductByBarcode(String stationId, String barcode) async {
    if (barcode.isEmpty) return null;
    final querySnapshot = await _productsRef
        .where('stationId', isEqualTo: stationId)
        .where('barcode', isEqualTo: barcode)
        .where('isActive', isEqualTo: true)
        .limit(1)
        .get();
    if (querySnapshot.docs.isEmpty) return null;
    return _productFromDoc(querySnapshot.docs.first);
  }

  Future<String> createProduct(Product product) async {
    final docRef = await _productsRef.add(_productToDoc(product));
    return docRef.id;
  }

  Future<void> updateProduct(Product product) async {
    await _productsRef.doc(product.id).update(_productToDoc(product));
  }

  Future<void> deleteProduct(String productId) async {
    await _productsRef.doc(productId).update({
      'isActive': false,
      'updatedAt': Timestamp.now(),
    });
  }

  Stream<List<Product>> watchProductsByStation(String stationId) {
    return _productsRef
        .where('stationId', isEqualTo: stationId)
        .where('isActive', isEqualTo: true)
        .orderBy('name')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => _productFromDoc(doc)).toList());
  }
}

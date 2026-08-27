import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:washify/features/tickets/models/vehicle_catalog.dart';

class VehicleCatalogRepository {
  final FirebaseFirestore _firestore;

  VehicleCatalogRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference get _catalogRef => _firestore.collection('vehicle_catalog');

  Stream<VehicleCatalog> watchVehicleCatalog(String stationId) {
    if (stationId.isEmpty) {
      return Stream.value(VehicleCatalog.empty(''));
    }

    return _catalogRef.doc(stationId).snapshots().map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) {
        return VehicleCatalog.empty(stationId);
      }
      return VehicleCatalog.fromJson(snapshot.data() as Map<String, dynamic>, snapshot.id);
    });
  }

  Future<VehicleCatalog> getVehicleCatalog(String stationId) async {
    if (stationId.isEmpty) return VehicleCatalog.empty('');
    final doc = await _catalogRef.doc(stationId).get();
    if (!doc.exists || doc.data() == null) {
      return VehicleCatalog.empty(stationId);
    }
    return VehicleCatalog.fromJson(doc.data() as Map<String, dynamic>, doc.id);
  }

  /// Automatically learns brand and model from a ticket creation/validation
  Future<void> learnBrandAndModel(String stationId, String rawBrand, String rawModel) async {
    final brand = rawBrand.trim();
    final model = rawModel.trim();
    if (stationId.isEmpty || brand.isEmpty) return;

    try {
      final docRef = _catalogRef.doc(stationId);
      final snapshot = await docRef.get();

      if (!snapshot.exists || snapshot.data() == null) {
        // Create new catalog
        final List<String> customBrands = [];
        if (!VehicleCatalog.defaultBrands.any((b) => b.toLowerCase() == brand.toLowerCase())) {
          customBrands.add(brand);
        }

        final Map<String, List<String>> brandModels = {};
        if (model.isNotEmpty) {
          brandModels[brand] = [model];
        }

        final newCatalog = VehicleCatalog(
          id: stationId,
          tenantId: stationId,
          customBrands: customBrands,
          brandModels: brandModels,
          updatedAt: DateTime.now(),
        );

        await docRef.set(newCatalog.toJson());
      } else {
        final catalog = VehicleCatalog.fromJson(snapshot.data() as Map<String, dynamic>, snapshot.id);
        final List<String> customBrands = List.from(catalog.customBrands);
        final Map<String, List<String>> brandModels = Map.from(catalog.brandModels);

        bool needsUpdate = false;

        // 1. Learn brand if not in default or custom brands
        final isDefault = VehicleCatalog.defaultBrands.any((b) => b.toLowerCase() == brand.toLowerCase());
        final isCustom = customBrands.any((b) => b.toLowerCase() == brand.toLowerCase());

        if (!isDefault && !isCustom) {
          customBrands.add(brand);
          needsUpdate = true;
        }

        // 2. Learn model under this brand
        if (model.isNotEmpty) {
          final existingBrandKey = brandModels.keys.firstWhere(
            (k) => k.toLowerCase() == brand.toLowerCase(),
            orElse: () => '',
          );

          if (existingBrandKey.isEmpty) {
            brandModels[brand] = [model];
            needsUpdate = true;
          } else {
            final modelsList = List<String>.from(brandModels[existingBrandKey]!);
            if (!modelsList.any((m) => m.toLowerCase() == model.toLowerCase())) {
              modelsList.add(model);
              brandModels[existingBrandKey] = modelsList;
              needsUpdate = true;
            }
          }
        }

        if (needsUpdate) {
          await docRef.set({
            'tenantId': stationId,
            'customBrands': customBrands,
            'brandModels': brandModels,
            'updatedAt': Timestamp.fromDate(DateTime.now()),
          }, SetOptions(merge: true));
        }
      }
    } catch (e) {
      // Non-blocking catch to preserve UI responsiveness
      print('Error learning vehicle brand/model: $e');
    }
  }

  /// Add a brand manually
  Future<void> addBrand(String stationId, String brandName) async {
    final brand = brandName.trim();
    if (stationId.isEmpty || brand.isEmpty) return;

    final catalog = await getVehicleCatalog(stationId);
    final customBrands = List<String>.from(catalog.customBrands);
    if (!customBrands.any((b) => b.toLowerCase() == brand.toLowerCase()) &&
        !VehicleCatalog.defaultBrands.any((b) => b.toLowerCase() == brand.toLowerCase())) {
      customBrands.add(brand);
      await _catalogRef.doc(stationId).set({
        'tenantId': stationId,
        'customBrands': customBrands,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      }, SetOptions(merge: true));
    }
  }

  /// Update a brand name
  Future<void> updateBrand(String stationId, String oldBrand, String newBrand) async {
    final oldB = oldBrand.trim();
    final newB = newBrand.trim();
    if (stationId.isEmpty || oldB.isEmpty || newB.isEmpty) return;

    final catalog = await getVehicleCatalog(stationId);
    final customBrands = List<String>.from(catalog.customBrands);
    final idx = customBrands.indexWhere((b) => b.toLowerCase() == oldB.toLowerCase());

    final brandModels = Map<String, List<String>>.from(catalog.brandModels);

    if (idx >= 0) {
      customBrands[idx] = newB;
    }

    if (brandModels.containsKey(oldB)) {
      final models = brandModels.remove(oldB)!;
      brandModels[newB] = models;
    }

    await _catalogRef.doc(stationId).set({
      'tenantId': stationId,
      'customBrands': customBrands,
      'brandModels': brandModels,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    }, SetOptions(merge: true));
  }

  /// Delete a brand
  Future<void> deleteBrand(String stationId, String brandName) async {
    final brand = brandName.trim();
    if (stationId.isEmpty || brand.isEmpty) return;

    final catalog = await getVehicleCatalog(stationId);
    final customBrands = List<String>.from(catalog.customBrands);
    customBrands.removeWhere((b) => b.toLowerCase() == brand.toLowerCase());

    final brandModels = Map<String, List<String>>.from(catalog.brandModels);
    brandModels.removeWhere((k, v) => k.toLowerCase() == brand.toLowerCase());

    await _catalogRef.doc(stationId).set({
      'tenantId': stationId,
      'customBrands': customBrands,
      'brandModels': brandModels,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    }, SetOptions(merge: true));
  }
}

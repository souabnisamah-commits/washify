import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:washify/core/constants/app_constants.dart';
import 'package:washify/features/stock/models/stock.dart';
import 'package:washify/features/tickets/models/ticket.dart';
import 'package:washify/features/services/models/service_definition.dart';

import 'package:washify/features/auth/models/app_user.dart';
import 'package:washify/repositories/audit_repository.dart';

class StockRepository {
  final FirebaseFirestore _firestore;
  final String tenantId;
  final AppUser? currentUser;
  final AuditRepository? auditRepo;

  StockRepository({FirebaseFirestore? firestore, this.tenantId = '', this.currentUser, this.auditRepo})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference get _stockRef => _firestore.collection(AppConstants.stockCollection);
  CollectionReference get _movementsRef => _firestore.collection('stock_movements');
  
  Query get _tenantStockRef => tenantId.isEmpty ? _stockRef : _stockRef.where('stationId', isEqualTo: tenantId);
  Query get _tenantMovementsRef => tenantId.isEmpty ? _movementsRef : _movementsRef.where('stationId', isEqualTo: tenantId);

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
    final querySnapshot = await _tenantStockRef
        .where('stationId', isEqualTo: stationId)
        .orderBy('productName')
        .get();
    return querySnapshot.docs.map((doc) => _levelFromDoc(doc)).toList();
  }

  Future<StockLevel?> getStockLevel(String stationId, String productId) async {
    final querySnapshot = await _tenantStockRef
        .where('stationId', isEqualTo: stationId)
        .where('productId', isEqualTo: productId)
        .limit(1)
        .get();
    if (querySnapshot.docs.isEmpty) return null;
    return _levelFromDoc(querySnapshot.docs.first);
  }

  Future<void> updateStockLevel(StockLevel stockLevel) async {
    final querySnapshot = await _tenantStockRef
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
    final docRef = _movementsRef.doc();
    final newMovement = movement.copyWith(id: docRef.id);
    await docRef.set(_movementToDoc(newMovement));
    
    if (currentUser != null) {
      auditRepo?.log(
        userId: currentUser!.id,
        userName: currentUser!.name,
        action: 'Mouvement Stock',
        module: 'stock',
        description: 'A effectué un mouvement de stock (${newMovement.type}) pour le produit ${newMovement.productName} (Qte: ${newMovement.quantity})',
        stationId: newMovement.tenantId,
        newData: {'movementId': newMovement.id, 'productId': newMovement.productId, 'quantity': newMovement.quantity, 'type': newMovement.type},
      );
    }
  }

  Future<List<StockMovement>> getStockMovements(String stationId,
      {String? productId, int limit = 50}) async {
    Query query = _tenantMovementsRef
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
    return _tenantStockRef
        .where('stationId', isEqualTo: stationId)
        .orderBy('productName')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => _levelFromDoc(doc)).toList());
  }

  Future<void> deductStockForTicket(Ticket ticket) async {
    final stationId = ticket.tenantId;
    final now = DateTime.now();

    if (ticket.operationType == 'moquette') {
      // Deduct linked products based on station configuration for moquettes
      final stationDoc = await _firestore
          .collection(AppConstants.stationsCollection)
          .doc(stationId)
          .get();

      if (stationDoc.exists) {
        final stationData = stationDoc.data()!;
        final linkedProductsRaw = stationData['carpetLinkedProducts'] as List?;
        if (linkedProductsRaw != null) {
          final double carpetMeters = ticket.carpetMeters ?? 0.0;
          for (final raw in linkedProductsRaw) {
            final link = ServiceProductLink.fromJson(raw as Map<String, dynamic>);
            
            final bool isAlreadyInProductsUsed = ticket.productsUsed.any((p) => p.productId == link.productId);
            if (isAlreadyInProductsUsed) {
              continue; 
            }

            final currentStock = await getStockLevel(stationId, link.productId);
            if (currentStock != null) {
              final double previousQty = currentStock.currentQuantity;
              final double quantityToDeduct = link.consumptionPerUse * carpetMeters;
              final double newQty = previousQty - quantityToDeduct;

              await updateStockLevel(currentStock.copyWith(
                currentQuantity: newQty,
                updatedAt: now,
              ));

              await addStockMovement(StockMovement(
                id: '',
                tenantId: stationId,
                productId: link.productId,
                productName: link.productName,
                type: AppConstants.stockMovementOut,
                quantity: quantityToDeduct,
                previousQuantity: previousQty,
                newQuantity: newQty,
                reason: 'Consommation Moquettes (${carpetMeters.toStringAsFixed(1)} m²) Ticket ${ticket.ticketNumber}',
                performedBy: ticket.createdBy,
                createdAt: now,
              ));
            }
          }
        }
      }
      
      // Deduct manual products (boutique / extra manually added) for moquette too
      for (final tp in ticket.productsUsed) {
        final currentStock = await getStockLevel(stationId, tp.productId);
        if (currentStock != null) {
          final double previousQty = currentStock.currentQuantity;
          
          double multiplier = 1.0;
          final productDoc = await _firestore
              .collection(AppConstants.productsCollection)
              .doc(tp.productId)
              .get();
          if (productDoc.exists) {
            final pData = productDoc.data()!;
            final doseMl = (pData['doseMl'] as num?)?.toDouble() ?? 0.0;
            if (doseMl > 0) {
              multiplier = doseMl;
            }
          }

          final double quantityToDeduct = tp.quantity * multiplier;
          final double newQty = previousQty - quantityToDeduct;

          await updateStockLevel(currentStock.copyWith(
            currentQuantity: newQty,
            updatedAt: now,
          ));

          await addStockMovement(StockMovement(
            id: '',
            tenantId: stationId,
            productId: tp.productId,
            productName: tp.productName,
            type: AppConstants.stockMovementOut,
            quantity: quantityToDeduct,
            previousQuantity: previousQty,
            newQuantity: newQty,
            reason: multiplier > 1.0 
                ? 'Consommation Extra (${tp.quantity} dose(s) de ${multiplier.toStringAsFixed(0)}ml) Ticket ${ticket.ticketNumber}'
                : 'Vente Directe / Boutique Ticket ${ticket.ticketNumber}',
            performedBy: ticket.createdBy,
            createdAt: now,
          ));
        }
      }
      return;
    }

    // 1. Deduct manual products (boutique / extra manually added)
    for (final tp in ticket.productsUsed) {
      final currentStock = await getStockLevel(stationId, tp.productId);
      if (currentStock != null) {
        final double previousQty = currentStock.currentQuantity;
        
        // Fetch product definition to check if it has a fluid doseMl
        double multiplier = 1.0;
        final productDoc = await _firestore
            .collection(AppConstants.productsCollection)
            .doc(tp.productId)
            .get();
        if (productDoc.exists) {
          final pData = productDoc.data()!;
          final doseMl = (pData['doseMl'] as num?)?.toDouble() ?? 0.0;
          if (doseMl > 0) {
            multiplier = doseMl;
          }
        }

        final double quantityToDeduct = tp.quantity * multiplier;
        final double newQty = previousQty - quantityToDeduct;

        await updateStockLevel(currentStock.copyWith(
          currentQuantity: newQty,
          updatedAt: now,
        ));

        await addStockMovement(StockMovement(
          id: '',
          tenantId: stationId,
          productId: tp.productId,
          productName: tp.productName,
          type: AppConstants.stockMovementOut,
          quantity: quantityToDeduct,
          previousQuantity: previousQty,
          newQuantity: newQty,
          reason: multiplier > 1.0 
              ? 'Consommation Extra (${tp.quantity} dose(s) de ${multiplier.toStringAsFixed(0)}ml) Ticket ${ticket.ticketNumber}'
              : 'Vente Directe / Boutique Ticket ${ticket.ticketNumber}',
          performedBy: ticket.createdBy,
          createdAt: now,
        ));
      }
    }

    // 2. Deduct linked products from all selected services
    for (final srv in ticket.allServices) {
      if (srv.serviceId.isNotEmpty) {
        final serviceDoc = await _firestore
            .collection(AppConstants.serviceDefinitionsCollection)
            .doc(srv.serviceId)
            .get();

        if (serviceDoc.exists) {
          final serviceData = serviceDoc.data()!;
          final linkedProductsRaw = serviceData['linkedProducts'] as List?;
          if (linkedProductsRaw != null) {
            for (final raw in linkedProductsRaw) {
              final link = ServiceProductLink.fromJson(raw as Map<String, dynamic>);
              
              // Check if this linked product is already accounted for in productsUsed (Boutique/Revente logic)
              final bool isAlreadyInProductsUsed = ticket.productsUsed.any((p) => p.productId == link.productId);
              if (isAlreadyInProductsUsed) {
                continue; // Skip deduction to avoid double counting, because productsUsed contains the total quantity.
              }

              final currentStock = await getStockLevel(stationId, link.productId);
              if (currentStock != null) {
                final double previousQty = currentStock.currentQuantity;
                final double quantityToDeduct = (ticket.vehicleCategoryId != null && link.consumptionByCategory.containsKey(ticket.vehicleCategoryId))
                    ? link.consumptionByCategory[ticket.vehicleCategoryId]!
                    : link.consumptionPerUse;
                final double newQty = previousQty - quantityToDeduct;

                await updateStockLevel(currentStock.copyWith(
                  currentQuantity: newQty,
                  updatedAt: now,
                ));

                await addStockMovement(StockMovement(
                  id: '',
                  tenantId: stationId,
                  productId: link.productId,
                  productName: link.productName,
                  type: AppConstants.stockMovementOut,
                  quantity: quantityToDeduct,
                  previousQuantity: previousQty,
                  newQuantity: newQty,
                  reason: 'Consommation Auto Service (${srv.serviceName}) Ticket ${ticket.ticketNumber}',
                  performedBy: ticket.createdBy,
                  createdAt: now,
                ));
              }
            }
          }
        }
      }
    }
  }

  Future<void> restoreStockForTicket(Ticket ticket) async {
    final stationId = ticket.tenantId;
    final now = DateTime.now();

    if (ticket.operationType == 'moquette') {
      // Restore linked products based on station configuration for moquettes
      final stationDoc = await _firestore
          .collection(AppConstants.stationsCollection)
          .doc(stationId)
          .get();

      if (stationDoc.exists) {
        final stationData = stationDoc.data()!;
        final linkedProductsRaw = stationData['carpetLinkedProducts'] as List?;
        if (linkedProductsRaw != null) {
          final double carpetMeters = ticket.carpetMeters ?? 0.0;
          for (final raw in linkedProductsRaw) {
            final link = ServiceProductLink.fromJson(raw as Map<String, dynamic>);
            
            final bool isAlreadyInProductsUsed = ticket.productsUsed.any((p) => p.productId == link.productId);
            if (isAlreadyInProductsUsed) {
              continue; 
            }

            final currentStock = await getStockLevel(stationId, link.productId);
            if (currentStock != null) {
              final double previousQty = currentStock.currentQuantity;
              final double quantityToRestore = link.consumptionPerUse * carpetMeters;
              final double newQty = previousQty + quantityToRestore;

              await updateStockLevel(currentStock.copyWith(
                currentQuantity: newQty,
                updatedAt: now,
              ));

              await addStockMovement(StockMovement(
                id: '',
                tenantId: stationId,
                productId: link.productId,
                productName: link.productName,
                type: AppConstants.stockMovementIn,
                quantity: quantityToRestore,
                previousQuantity: previousQty,
                newQuantity: newQty,
                reason: 'Restauration Moquettes (${carpetMeters.toStringAsFixed(1)} m²) Effacement/Modification Ticket ${ticket.ticketNumber}',
                performedBy: currentUser?.name ?? 'Patron',
                createdAt: now,
              ));
            }
          }
        }
      }
      
      // Restore manual products (boutique / extra manually added) for moquette too
      for (final tp in ticket.productsUsed) {
        final currentStock = await getStockLevel(stationId, tp.productId);
        if (currentStock != null) {
          final double previousQty = currentStock.currentQuantity;
          
          double multiplier = 1.0;
          final productDoc = await _firestore
              .collection(AppConstants.productsCollection)
              .doc(tp.productId)
              .get();
          if (productDoc.exists) {
            final pData = productDoc.data()!;
            final doseMl = (pData['doseMl'] as num?)?.toDouble() ?? 0.0;
            if (doseMl > 0) {
              multiplier = doseMl;
            }
          }

          final double quantityToRestore = tp.quantity * multiplier;
          final double newQty = previousQty + quantityToRestore;

          await updateStockLevel(currentStock.copyWith(
            currentQuantity: newQty,
            updatedAt: now,
          ));

          await addStockMovement(StockMovement(
            id: '',
            tenantId: stationId,
            productId: tp.productId,
            productName: tp.productName,
            type: AppConstants.stockMovementIn,
            quantity: quantityToRestore,
            previousQuantity: previousQty,
            newQuantity: newQty,
            reason: 'Restauration Extra (Effacement/Modification Ticket ${ticket.ticketNumber})',
            performedBy: currentUser?.name ?? 'Patron',
            createdAt: now,
          ));
        }
      }
      return;
    }

    // 1. Restore manual products (boutique / extra manually added)
    for (final tp in ticket.productsUsed) {
      final currentStock = await getStockLevel(stationId, tp.productId);
      if (currentStock != null) {
        final double previousQty = currentStock.currentQuantity;
        
        // Fetch product definition to check if it has a fluid doseMl
        double multiplier = 1.0;
        final productDoc = await _firestore
            .collection(AppConstants.productsCollection)
            .doc(tp.productId)
            .get();
        if (productDoc.exists) {
          final pData = productDoc.data()!;
          final doseMl = (pData['doseMl'] as num?)?.toDouble() ?? 0.0;
          if (doseMl > 0) {
            multiplier = doseMl;
          }
        }

        final double quantityToRestore = tp.quantity * multiplier;
        final double newQty = previousQty + quantityToRestore;

        await updateStockLevel(currentStock.copyWith(
          currentQuantity: newQty,
          updatedAt: now,
        ));

        await addStockMovement(StockMovement(
          id: '',
          tenantId: stationId,
          productId: tp.productId,
          productName: tp.productName,
          type: AppConstants.stockMovementIn,
          quantity: quantityToRestore,
          previousQuantity: previousQty,
          newQuantity: newQty,
          reason: 'Restauration Extra (Effacement/Modification Ticket ${ticket.ticketNumber})',
          performedBy: currentUser?.name ?? 'Patron',
          createdAt: now,
        ));
      }
    }

    // 2. Restore linked products from all selected services
    for (final srv in ticket.allServices) {
      if (srv.serviceId.isNotEmpty) {
        final serviceDoc = await _firestore
            .collection(AppConstants.serviceDefinitionsCollection)
            .doc(srv.serviceId)
            .get();

        if (serviceDoc.exists) {
          final serviceData = serviceDoc.data()!;
          final linkedProductsRaw = serviceData['linkedProducts'] as List?;
          if (linkedProductsRaw != null) {
            for (final raw in linkedProductsRaw) {
              final link = ServiceProductLink.fromJson(raw as Map<String, dynamic>);
              
              // Check if this linked product is already accounted for in productsUsed (Boutique/Revente logic)
              final bool isAlreadyInProductsUsed = ticket.productsUsed.any((p) => p.productId == link.productId);
              if (isAlreadyInProductsUsed) {
                continue; 
              }

              final currentStock = await getStockLevel(stationId, link.productId);
              if (currentStock != null) {
                final double previousQty = currentStock.currentQuantity;
                final double quantityToRestore = (ticket.vehicleCategoryId != null && link.consumptionByCategory.containsKey(ticket.vehicleCategoryId))
                    ? link.consumptionByCategory[ticket.vehicleCategoryId]!
                    : link.consumptionPerUse;
                final double newQty = previousQty + quantityToRestore;

                await updateStockLevel(currentStock.copyWith(
                  currentQuantity: newQty,
                  updatedAt: now,
                ));

                await addStockMovement(StockMovement(
                  id: '',
                  tenantId: stationId,
                  productId: link.productId,
                  productName: link.productName,
                  type: AppConstants.stockMovementIn,
                  quantity: quantityToRestore,
                  previousQuantity: previousQty,
                  newQuantity: newQty,
                  reason: 'Restauration Auto Service (${srv.serviceName}) Effacement/Modification Ticket ${ticket.ticketNumber}',
                  performedBy: currentUser?.name ?? 'Patron',
                  createdAt: now,
                ));
              }
            }
          }
        }
      }
    }
  }
}

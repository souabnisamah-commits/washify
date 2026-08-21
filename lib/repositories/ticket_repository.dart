import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:washify/core/constants/app_constants.dart';
import 'package:washify/features/tickets/models/ticket.dart';
import 'package:washify/repositories/stock_repository.dart';
import 'package:washify/repositories/client_repository.dart';

import 'package:washify/providers/auth_provider.dart';

import 'package:washify/repositories/audit_repository.dart';
import 'package:washify/providers/audit_provider.dart';

import 'package:washify/features/auth/models/app_user.dart';
import 'package:washify/core/constants/user_roles.dart';

final ticketRepositoryProvider = Provider<TicketRepository>((ref) {
  final user = ref.watch(currentUserProvider);
  final auditRepo = ref.watch(auditRepositoryProvider);
  return TicketRepository(
    tenantId: user?.tenantId ?? '', 
    currentUser: user,
    auditRepo: auditRepo,
  );
});

class TicketRepository {
  final FirebaseFirestore _firestore;
  final String tenantId;
  final AppUser? currentUser;
  final AuditRepository? auditRepo;

  TicketRepository({FirebaseFirestore? firestore, this.tenantId = '', this.currentUser, this.auditRepo})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference get _ticketsRef =>
      _firestore.collection(AppConstants.ticketsCollection);
      
  Query get _tenantTicketsRef => tenantId.isEmpty 
      ? _ticketsRef 
      : _ticketsRef.where('tenantId', isEqualTo: tenantId);

  Ticket _ticketFromDoc(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    data['id'] = doc.id;

    if (data['createdAt'] is Timestamp) {
      data['createdAt'] = (data['createdAt'] as Timestamp).toDate().toIso8601String();
    }
    if (data['updatedAt'] is Timestamp) {
      data['updatedAt'] = (data['updatedAt'] as Timestamp).toDate().toIso8601String();
    }

    // Map stationId to tenantId
    if (data['tenantId'] == null && data['stationId'] != null) {
      data['tenantId'] = data['stationId'];
    } else if (data['tenantId'] == null) {
      data['tenantId'] = '';
    }

    // Map status string to TicketStatus enum value
    if (data['status'] != null) {
      final val = data['status'] as String;
      if (val == 'pending' || val == 'in_progress') {
        data['status'] = 'en_attente';
      } else if (val == 'completed') {
        data['status'] = 'paye';
      } else if (val == 'cancelled') {
        data['status'] = 'rembourse';
      }
    } else {
      data['status'] = 'en_attente';
    }

    // Map worker/creator fields
    if (data['createdBy'] == null) {
      data['createdBy'] = data['workerName'] ?? data['workerId'] ?? 'System';
    }

    if (data['montant'] == null) {
      data['montant'] = (data['totalAmount'] as num?)?.toDouble() ?? 0.0;
    }

    if (data['snapshotPrice'] == null) {
      data['snapshotPrice'] = <String, dynamic>{
        'price': (data['servicePrice'] as num?)?.toDouble() ?? 0.0,
      };
    }

    return Ticket.fromJson(data);
  }

  Map<String, dynamic> _ticketToDoc(Ticket ticket) {
    final map = ticket.toJson();
    map.remove('id');
    map['stationId'] = ticket.tenantId;
    if (ticket.assignedWorkerId != null) {
      map['workerId'] = ticket.assignedWorkerId;
      map['workerName'] = ticket.assignedWorkerName;
    }
    map['totalAmount'] = ticket.montant;
    map['servicePrice'] = ticket.snapshotPrice['price'] ?? 0.0;
    map['servicesSelected'] = ticket.servicesSelected.map((s) => s.toJson()).toList();
    map['productsUsed'] = ticket.productsUsed.map((p) => p.toJson()).toList();
    map['createdAt'] = Timestamp.fromDate(ticket.createdAt);
    map['updatedAt'] = Timestamp.fromDate(ticket.updatedAt);
    return map;
  }

  Future<List<Ticket>> getTicketsByStation(String stationId,
      {String? status, int limit = 50}) async {
    Query query = _tenantTicketsRef
        .where('stationId', isEqualTo: stationId)
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (status != null) {
      String mappedStatus = status;
      if (status == 'pending' || status == 'in_progress') {
        mappedStatus = 'en_attente';
      } else if (status == 'completed') {
        mappedStatus = 'paye';
      } else if (status == 'cancelled') {
        mappedStatus = 'rembourse';
      }
      query = query.where('status', isEqualTo: mappedStatus);
    }

    final querySnapshot = await query.get();
    return querySnapshot.docs.map((doc) => _ticketFromDoc(doc)).toList();
  }

  Future<List<Ticket>> getTicketsByWorker(String workerId,
      {String? status, int limit = 50}) async {
    Query query = _tenantTicketsRef
        .where('workerId', isEqualTo: workerId)
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (status != null) {
      String mappedStatus = status;
      if (status == 'pending' || status == 'in_progress') {
        mappedStatus = 'en_attente';
      } else if (status == 'completed') {
        mappedStatus = 'paye';
      } else if (status == 'cancelled') {
        mappedStatus = 'rembourse';
      }
      query = query.where('status', isEqualTo: mappedStatus);
    }

    final querySnapshot = await query.get();
    return querySnapshot.docs.map((doc) => _ticketFromDoc(doc)).toList();
  }

  Future<List<Ticket>> getTodayTickets(String stationId) async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final querySnapshot = await _tenantTicketsRef
        .where('stationId', isEqualTo: stationId)
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('createdAt', isLessThan: Timestamp.fromDate(endOfDay))
        .orderBy('createdAt', descending: true)
        .get();

    return querySnapshot.docs.map((doc) => _ticketFromDoc(doc)).toList();
  }

  Future<Ticket?> getTicketById(String ticketId) async {
    final doc = await _ticketsRef.doc(ticketId).get();
    if (!doc.exists) return null;
    return _ticketFromDoc(doc);
  }

  Future<int> getLastValidatedCount(String stationId, String dateStr) async {
    final counterRef = _firestore.collection('ticket_counters').doc('${stationId}_$dateStr');
    final snapshot = await counterRef.get();
    if (!snapshot.exists) return 0;
    final data = snapshot.data();
    final count = data?['lastValidated'] as int? ?? 0;
    if (count > 0) {
      try {
        final existingTicketsQuery = await _ticketsRef
            .where('tenantId', isEqualTo: stationId)
            .where('ticketNumber', isGreaterThanOrEqualTo: 'N°:001-$dateStr')
            .where('ticketNumber', isLessThanOrEqualTo: 'N°:999-$dateStr-99:99')
            .limit(1)
            .get();
        if (existingTicketsQuery.docs.isEmpty) {
          return 0;
        }
      } catch (e) {
        // Fallback gracefully if index is missing or building
      }
    }
    return count;
  }

  Future<int> _getNextValidatedCount(String stationId, String dateStr) async {
    final counterRef = _firestore.collection('ticket_counters').doc('${stationId}_$dateStr');
    
    bool shouldReset = false;
    final counterSnap = await counterRef.get();
    if (counterSnap.exists) {
      final count = counterSnap.data()?['lastValidated'] as int? ?? 0;
      if (count > 0) {
        try {
          final existingTicketsQuery = await _ticketsRef
              .where('tenantId', isEqualTo: stationId)
              .where('ticketNumber', isGreaterThanOrEqualTo: 'N°:001-$dateStr')
              .where('ticketNumber', isLessThanOrEqualTo: 'N°:999-$dateStr-99:99')
              .limit(1)
              .get();
          if (existingTicketsQuery.docs.isEmpty) {
            shouldReset = true;
          }
        } catch (e) {
          // Fallback gracefully if index is missing or building
        }
      }
    }

    return _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(counterRef);
      
      int currentCount = 0;
      if (snapshot.exists && !shouldReset) {
        final data = snapshot.data();
        currentCount = data?['lastValidated'] as int? ?? 0;
      }
      
      final nextCount = currentCount + 1;
      transaction.set(counterRef, {
        'lastValidated': nextCount,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      return nextCount;
    });
  }

  Future<void> resetTodayCounter(String stationId) async {
    final resetHour = await _getStationResetHour(stationId);
    final dateStr = _getOperationalDateStr(DateTime.now(), resetHour);
    final counterRef = _firestore.collection('ticket_counters').doc('${stationId}_$dateStr');
    await counterRef.set({
      'lastValidated': 0,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<int> _getStationResetHour(String stationId) async {
    try {
      final doc = await _firestore.collection(AppConstants.stationsCollection).doc(stationId).get();
      if (doc.exists) {
        final data = doc.data();
        return (data?['ticketResetHour'] as num?)?.toInt() ?? 21;
      }
    } catch (_) {}
    return 21;
  }

  String _getOperationalDateStr(DateTime timestamp, int resetHour) {
    final operationalDate = timestamp.hour >= resetHour
        ? timestamp.add(const Duration(days: 1))
        : timestamp;
    return "${operationalDate.day.toString().padLeft(2, '0')}${operationalDate.month.toString().padLeft(2, '0')}${operationalDate.year.toString().substring(2)}";
  }

  Future<String> _getNextTicketNumber(String stationId, DateTime timestamp) async {
    final resetHour = await _getStationResetHour(stationId);
    final dateStr = _getOperationalDateStr(timestamp, resetHour);
    final timeStr = "${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}";
    final count = await _getNextValidatedCount(stationId, dateStr);
    return "N°:${count.toString().padLeft(3, '0')}-$dateStr-$timeStr";
  }

  Future<String> getProvisionalTicketNumber(String stationId) async {
    final now = DateTime.now();
    final resetHour = await _getStationResetHour(stationId);
    final dateStr = _getOperationalDateStr(now, resetHour);
    final timeStr = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
    final count = await getLastValidatedCount(stationId, dateStr);
    final nextNum = count + 1;
    return "N°:${nextNum.toString().padLeft(3, '0')}-$dateStr-$timeStr";
  }

  Future<String> createTicket(Ticket ticket) async {
    final docRef = _ticketsRef.doc();
    
    final finalTicketNumber = await _getNextTicketNumber(ticket.tenantId, ticket.createdAt);
    Ticket newTicket = ticket.copyWith(
      id: docRef.id,
      ticketNumber: finalTicketNumber,
    );
    
    await docRef.set(_ticketToDoc(newTicket));

    if (currentUser != null) {
      auditRepo?.log(
        userId: currentUser!.id,
        userName: currentUser!.name,
        action: 'Création Ticket',
        module: 'ticket',
        description: 'A créé le ticket ${newTicket.ticketNumber} (Client: ${newTicket.clientName})',
        stationId: newTicket.tenantId,
        newData: {'ticketId': newTicket.id, 'ticketNumber': newTicket.ticketNumber, 'total': newTicket.totalAmount},
      );
    }
    
    if (newTicket.status == TicketStatus.paye) {
      final stockRepo = StockRepository(firestore: _firestore, tenantId: tenantId, currentUser: currentUser, auditRepo: auditRepo);
      await stockRepo.deductStockForTicket(newTicket);
    }

    return docRef.id;
  }

  Future<void> deleteTicket(String ticketId, {String? reason}) async {
    final doc = await _ticketsRef.doc(ticketId).get();
    if (doc.exists) {
      final ticket = _ticketFromDoc(doc);
      if (ticket.status == TicketStatus.paye) {
        final stockRepo = StockRepository(firestore: _firestore, tenantId: tenantId, currentUser: currentUser, auditRepo: auditRepo);
        await stockRepo.restoreStockForTicket(ticket);
      }

      await _ticketsRef.doc(ticketId).update({
        'status': 'efface',
        'cancellationReason': reason ?? 'Supprimé / Annulé',
        'updatedAt': Timestamp.now(),
      });

      if (currentUser != null) {
        auditRepo?.log(
          userId: currentUser!.id,
          userName: currentUser!.name,
          action: 'Suppression Ticket',
          module: 'ticket',
          description: 'A effacé le ticket ${ticket.ticketNumber} (Motif: ${reason ?? 'N/A'})',
          stationId: ticket.tenantId,
        );
      }
    }
  }

  Future<void> updateTicket(Ticket ticket) async {
    // Fetch old ticket to see its status
    final oldDoc = await _ticketsRef.doc(ticket.id).get();
    String? oldStatus;
    Ticket? oldTicket;
    if (oldDoc.exists) {
      oldTicket = _ticketFromDoc(oldDoc);
      oldStatus = oldTicket.status.value;
    }

    if (currentUser != null &&
        currentUser!.roles.length == 1 &&
        currentUser!.roles.contains(UserRole.ouvrier)) {
      if (ticket.assignedWorkerId != currentUser!.id) {
        throw Exception("Opération refusée : Vous n'êtes pas assigné à ce ticket.");
      }
    }

    Ticket updatedTicket = ticket;
    if (oldStatus != 'paye' && ticket.status == TicketStatus.paye) {
      final finalTicketNumber = await _getNextTicketNumber(ticket.tenantId, ticket.createdAt);
      updatedTicket = ticket.copyWith(ticketNumber: finalTicketNumber);
    }

    await _ticketsRef.doc(ticket.id).update(_ticketToDoc(updatedTicket));

    if (currentUser != null) {
      final bool isValidation = oldStatus != 'paye' && ticket.status == TicketStatus.paye;
      
      String actorDescription = 'A mis à jour le ticket #${updatedTicket.ticketNumber}';
      if (isValidation) {
        if (ticket.assignedWorkerId != null && ticket.assignedWorkerId != currentUser!.id) {
           actorDescription = 'A validé le ticket #${updatedTicket.ticketNumber} de ${ticket.assignedWorkerName ?? 'l\'ouvrier'}';
        } else {
           actorDescription = 'A validé le ticket #${updatedTicket.ticketNumber}';
        }
      }

      auditRepo?.log(
        userId: currentUser!.id,
        userName: currentUser!.name,
        action: isValidation ? 'Validation Ticket' : 'Modification Ticket',
        module: 'ticket',
        description: actorDescription,
        stationId: updatedTicket.tenantId,
        newData: {'ticketId': updatedTicket.id, 'status': updatedTicket.status.value},
      );

      // Log pour l'ouvrier si quelqu'un d'autre (le caissier) valide son ticket
      if (isValidation && ticket.assignedWorkerId != null && ticket.assignedWorkerId != currentUser!.id) {
        auditRepo?.log(
          userId: ticket.assignedWorkerId!,
          userName: ticket.assignedWorkerName ?? 'Ouvrier',
          action: 'Ticket Validé par Caissier',
          module: 'ticket',
          description: 'Votre ticket #${updatedTicket.ticketNumber} a été validé par ${currentUser!.name}',
          stationId: updatedTicket.tenantId,
          newData: {'ticketId': updatedTicket.id, 'status': updatedTicket.status.value, 'validatedBy': currentUser!.id},
        );
      }
    }

    // 1. If the old version was paid, we restore its stock and subtract its client balance
    final bool oldWasPaye = oldDoc.exists && oldStatus == 'paye';
    if (oldWasPaye && oldTicket != null) {
      final stockRepo = StockRepository(firestore: _firestore, tenantId: tenantId, currentUser: currentUser, auditRepo: auditRepo);
      await stockRepo.restoreStockForTicket(oldTicket);

      if (oldTicket.paymentMethod == 'compte_client' && oldTicket.clientId != null) {
        final clientRepo = ClientRepository(firestore: _firestore, tenantId: tenantId);
        await clientRepo.updateClientBalance(oldTicket.clientId!, -oldTicket.totalAmount);
      }
    }

    // 2. If the new version is paid, we deduct stock and add client balance
    if (updatedTicket.status == TicketStatus.paye) {
      final stockRepo = StockRepository(firestore: _firestore, tenantId: tenantId, currentUser: currentUser, auditRepo: auditRepo);
      await stockRepo.deductStockForTicket(updatedTicket);

      if (updatedTicket.paymentMethod == 'compte_client' && updatedTicket.clientId != null) {
        final clientRepo = ClientRepository(firestore: _firestore, tenantId: tenantId);
        await clientRepo.updateClientBalance(updatedTicket.clientId!, updatedTicket.totalAmount);
        if (updatedTicket.vehiclePlate != null && updatedTicket.vehiclePlate!.isNotEmpty) {
          await clientRepo.addVehicleToClient(updatedTicket.clientId!, updatedTicket.vehiclePlate!);
        }
      }
    }
  }

  Future<void> softDeleteTicket(String ticketId, String reason) async {
    final doc = await _ticketsRef.doc(ticketId).get();
    if (!doc.exists) return;
    
    final oldTicket = _ticketFromDoc(doc);
    final wasPaye = oldTicket.status == TicketStatus.paye;
    
    final updatedTicket = oldTicket.copyWith(
      status: TicketStatus.efface,
      deletedBy: currentUser?.name ?? 'Patron',
      deletedAt: DateTime.now(),
      deleteReason: reason,
      updatedAt: DateTime.now(),
    );
    
    await _ticketsRef.doc(ticketId).update(_ticketToDoc(updatedTicket));
    
    if (currentUser != null) {
      auditRepo?.log(
        userId: currentUser!.id,
        userName: currentUser!.name,
        action: 'Suppression Ticket',
        module: 'ticket',
        description: 'A supprimé le ticket #${oldTicket.ticketNumber} pour la raison : $reason',
        stationId: oldTicket.tenantId,
        newData: {'ticketId': ticketId, 'status': 'efface', 'reason': reason},
      );
    }
    
    if (wasPaye) {
      // Restore stock
      final stockRepo = StockRepository(firestore: _firestore, tenantId: tenantId, currentUser: currentUser, auditRepo: auditRepo);
      await stockRepo.restoreStockForTicket(oldTicket);
      
      // Reverse B2B balance
      if (oldTicket.paymentMethod == 'compte_client' && oldTicket.clientId != null) {
        final clientRepo = ClientRepository(firestore: _firestore, tenantId: tenantId);
        await clientRepo.updateClientBalance(oldTicket.clientId!, -oldTicket.totalAmount);
      }
    }
  }

  Future<void> updateTicketStatus(String ticketId, String status) async {
    String mappedStatus = status;
    if (status == 'pending' || status == 'in_progress' || status == AppConstants.ticketStatusPending || status == AppConstants.ticketStatusInProgress) {
      mappedStatus = 'en_attente';
    } else if (status == 'completed' || status == AppConstants.ticketStatusCompleted) {
      mappedStatus = 'paye';
    } else if (status == 'cancelled' || status == AppConstants.ticketStatusCancelled) {
      mappedStatus = 'rembourse';
    }

    final docRef = _ticketsRef.doc(ticketId);
    
    await _firestore.runTransaction((transaction) async {
      final docSnapshot = await transaction.get(docRef);
      if (!docSnapshot.exists) return;
      
      final data = docSnapshot.data() as Map<String, dynamic>;
      final oldStatus = data['status'] as String?;
      
      final Map<String, dynamic> updates = {
        'status': mappedStatus,
        'updatedAt': Timestamp.now(),
      };
      
      if (oldStatus != 'paye' && mappedStatus == 'paye') {
        final stationId = data['stationId'] ?? data['tenantId'] ?? tenantId;
        final createdAt = (data['createdAt'] as Timestamp).toDate();
        
        final dateStr = "${createdAt.day.toString().padLeft(2, '0')}${createdAt.month.toString().padLeft(2, '0')}${createdAt.year.toString().substring(2)}";
        final timeStr = "${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}";
        final counterRef = _firestore.collection('ticket_counters').doc('${stationId}_$dateStr');
        
        final counterSnapshot = await transaction.get(counterRef);
        int currentCount = 0;
        if (counterSnapshot.exists) {
          currentCount = counterSnapshot.data()?['lastValidated'] as int? ?? 0;
        }
        final nextCount = currentCount + 1;
        transaction.set(counterRef, {
          'lastValidated': nextCount,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        
        updates['ticketNumber'] = "N°:${nextCount.toString().padLeft(3, '0')}-$dateStr-$timeStr";
      }
      
      transaction.update(docRef, updates);
    });

    if (mappedStatus == 'paye') {
      final ticket = await getTicketById(ticketId);
      if (ticket != null) {
        final stockRepo = StockRepository(firestore: _firestore, tenantId: tenantId, currentUser: currentUser, auditRepo: auditRepo);
        await stockRepo.deductStockForTicket(ticket);

        if (ticket.paymentMethod == 'compte_client' && ticket.clientId != null) {
          final clientRepo = ClientRepository(firestore: _firestore, tenantId: tenantId);
          await clientRepo.updateClientBalance(ticket.clientId!, ticket.totalAmount);
          if (ticket.vehiclePlate != null && ticket.vehiclePlate!.isNotEmpty) {
            await clientRepo.addVehicleToClient(ticket.clientId!, ticket.vehiclePlate!);
          }
        }
      }
    }
  }

  Future<void> assignWorker(
      String ticketId, String workerId, String workerName) async {
    await _ticketsRef.doc(ticketId).update({
      'workerId': workerId,
      'workerName': workerName,
      'createdBy': workerName,
      'updatedAt': Timestamp.now(),
    });
  }

  Stream<List<Ticket>> watchTodayTickets(String stationId) {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _tenantTicketsRef
        .where('stationId', isEqualTo: stationId)
        .where('createdAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('createdAt', isLessThan: Timestamp.fromDate(endOfDay))
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => _ticketFromDoc(doc)).toList());
  }

  Stream<List<Ticket>> watchStationTickets(String stationId) {
    return _tenantTicketsRef
        .where('tenantId', isEqualTo: stationId)
        .orderBy('createdAt', descending: true)
        .limit(100) // limit for UI performance
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => _ticketFromDoc(doc)).toList());
  }

  // WATCH UNPAID TICKETS FOR A CLIENT
  Stream<List<Ticket>> watchClientTickets(String stationId, String clientId) {
    return _tenantTicketsRef
        .where('stationId', isEqualTo: stationId)
        .where('clientId', isEqualTo: clientId)
        // .where('status', isEqualTo: TicketStatus.enAttente.toString()) // if we only want unpaid. Wait, maybe we want all client tickets?
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => _ticketFromDoc(doc)).toList());
  }

  Future<List<Ticket>> getClientTickets(String stationId, String clientId) async {
    final querySnapshot = await _tenantTicketsRef
        .where('stationId', isEqualTo: stationId)
        .where('clientId', isEqualTo: clientId)
        .orderBy('createdAt', descending: true)
        .get();
    return querySnapshot.docs.map((doc) => _ticketFromDoc(doc)).toList();
  }

  Stream<List<Ticket>> watchWorkerTickets(String workerId) {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    return _tenantTicketsRef
        .where('workerId', isEqualTo: workerId)
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => _ticketFromDoc(doc)).toList());
  }

  Future<Map<String, double>> getRevenueStats(
      String stationId, DateTime startDate, DateTime endDate) async {
    final querySnapshot = await _tenantTicketsRef
        .where('stationId', isEqualTo: stationId)
        .where('status', isEqualTo: 'paye')
        .where('updatedAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('updatedAt', isLessThan: Timestamp.fromDate(endDate))
        .get();

    double totalRevenue = 0;
    double totalCommissions = 0;
    int totalTickets = 0;

    for (final doc in querySnapshot.docs) {
      final ticket = _ticketFromDoc(doc);
      totalRevenue += ticket.totalAmount;
      totalCommissions += ticket.commissionAmount;
      totalTickets++;
    }

    return {
      'totalRevenue': totalRevenue,
      'totalCommissions': totalCommissions,
      'totalTickets': totalTickets.toDouble(),
      'averageTicket': totalTickets > 0 ? totalRevenue / totalTickets : 0,
    };
  }

  Future<List<Ticket>> getTicketsByDateRange(
      String stationId, DateTime startDate, DateTime endDate) async {
    final querySnapshot = await _tenantTicketsRef
        .where('stationId', isEqualTo: stationId)
        .where('status', isEqualTo: 'paye')
        .where('updatedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('updatedAt', isLessThan: Timestamp.fromDate(endDate))
        .get();

    final tickets = querySnapshot.docs.map((doc) => _ticketFromDoc(doc)).toList();
    tickets.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return tickets;
  }
}

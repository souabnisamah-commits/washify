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

  Future<String> createTicket(Ticket ticket) async {
    final docRef = _ticketsRef.doc();
    final newTicket = ticket.copyWith(id: docRef.id);
    await docRef.set(_ticketToDoc(newTicket));

    if (currentUser != null) {
      auditRepo?.log(
        userId: currentUser!.id,
        userName: currentUser!.name,
        action: 'Création Ticket',
        module: 'ticket',
        description: 'A créé le ticket #${newTicket.ticketNumber} (Client: ${newTicket.clientName})',
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

  Future<void> deleteTicket(String ticketId) async {
    final doc = await _ticketsRef.doc(ticketId).get();
    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>?;
      final status = data?['status'];
      if (status == 'en_attente' || status == 'enAttente' || status == 'pending' || status == 'in_progress') {
        await _ticketsRef.doc(ticketId).delete();
      } else {
        throw Exception("Impossible de supprimer un ticket déjà payé ou remboursé.");
      }
    }
  }

  Future<void> updateTicket(Ticket ticket) async {
    // Fetch old ticket to see its status
    final oldDoc = await _ticketsRef.doc(ticket.id).get();
    String? oldStatus;
    if (oldDoc.exists) {
      final data = oldDoc.data() as Map<String, dynamic>?;
      oldStatus = data?['status'] as String?;
    }

    if (currentUser != null &&
        currentUser!.roles.length == 1 &&
        currentUser!.roles.contains(UserRole.ouvrier)) {
      if (ticket.assignedWorkerId != currentUser!.id) {
        throw Exception("Opération refusée : Vous n'êtes pas assigné à ce ticket.");
      }
    }

    await _ticketsRef.doc(ticket.id).update(_ticketToDoc(ticket));

    if (currentUser != null) {
      final bool isValidation = oldStatus != 'paye' && ticket.status == TicketStatus.paye;
      
      String actorDescription = 'A mis à jour le ticket #${ticket.ticketNumber}';
      if (isValidation) {
        if (ticket.assignedWorkerId != null && ticket.assignedWorkerId != currentUser!.id) {
           actorDescription = 'A validé le ticket #${ticket.ticketNumber} de ${ticket.assignedWorkerName ?? 'l\'ouvrier'}';
        } else {
           actorDescription = 'A validé le ticket #${ticket.ticketNumber}';
        }
      }

      auditRepo?.log(
        userId: currentUser!.id,
        userName: currentUser!.name,
        action: isValidation ? 'Validation Ticket' : 'Modification Ticket',
        module: 'ticket',
        description: actorDescription,
        stationId: ticket.tenantId,
        newData: {'ticketId': ticket.id, 'status': ticket.status.value},
      );

      // Log pour l'ouvrier si quelqu'un d'autre (le caissier) valide son ticket
      if (isValidation && ticket.assignedWorkerId != null && ticket.assignedWorkerId != currentUser!.id) {
        auditRepo?.log(
          userId: ticket.assignedWorkerId!,
          userName: ticket.assignedWorkerName ?? 'Ouvrier',
          action: 'Ticket Validé par Caissier',
          module: 'ticket',
          description: 'Votre ticket #${ticket.ticketNumber} a été validé par ${currentUser!.name}',
          stationId: ticket.tenantId,
          newData: {'ticketId': ticket.id, 'status': ticket.status.value, 'validatedBy': currentUser!.id},
        );
      }
    }

    // If it transitioned to paye, we deduct stock and update client balance
    if (oldStatus != 'paye' && ticket.status == TicketStatus.paye) {
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

  Future<void> updateTicketStatus(String ticketId, String status) async {
    String mappedStatus = status;
    if (status == 'pending' || status == 'in_progress' || status == AppConstants.ticketStatusPending || status == AppConstants.ticketStatusInProgress) {
      mappedStatus = 'en_attente';
    } else if (status == 'completed' || status == AppConstants.ticketStatusCompleted) {
      mappedStatus = 'paye';
    } else if (status == 'cancelled' || status == AppConstants.ticketStatusCancelled) {
      mappedStatus = 'rembourse';
    }
    await _ticketsRef.doc(ticketId).update({
      'status': mappedStatus,
      'updatedAt': Timestamp.now(),
    });

    if (currentUser != null) {
      auditRepo?.log(
        userId: currentUser!.id,
        userName: currentUser!.name,
        action: 'Modification Statut Ticket',
        module: 'ticket',
        description: 'A changé le statut du ticket en $mappedStatus',
        stationId: currentUser!.tenantId,
        newData: {'ticketId': ticketId, 'status': mappedStatus},
      );
    }

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

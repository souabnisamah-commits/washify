import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:washify/features/clients/models/client.dart';
import 'package:washify/features/clients/models/client_payment.dart';

import 'package:washify/providers/auth_provider.dart';

final clientRepositoryProvider = Provider<ClientRepository>((ref) {
  final user = ref.watch(currentUserProvider);
  return ClientRepository(tenantId: user?.tenantId ?? '');
});

final clientsStreamProvider = StreamProvider.family<List<Client>, String>((ref, stationId) {
  final repository = ref.watch(clientRepositoryProvider);
  return repository.watchClients(stationId);
});

final clientPaymentsStreamProvider = StreamProvider.family<List<ClientPayment>, String>((ref, clientId) {
  final repository = ref.watch(clientRepositoryProvider);
  return repository.watchClientPayments(clientId);
});

class ClientRepository {
  final FirebaseFirestore _firestore;
  final String tenantId;

  ClientRepository({FirebaseFirestore? firestore, this.tenantId = ''})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference get _clientsRef => _firestore.collection('clients');
  CollectionReference get _paymentsRef => _firestore.collection('client_payments');
  
  Query get _tenantClientsRef => tenantId.isEmpty ? _clientsRef : _clientsRef.where('tenantId', isEqualTo: tenantId);
  Query get _tenantPaymentsRef => tenantId.isEmpty ? _paymentsRef : _paymentsRef.where('tenantId', isEqualTo: tenantId);

  Map<String, dynamic> _clientToDoc(Client client) {
    final map = client.toJson();
    map.remove('id');
    map['vehicles'] = client.vehicles.map((v) => v.toJson()).toList();
    map['createdAt'] = Timestamp.fromDate(client.createdAt);
    map['updatedAt'] = Timestamp.fromDate(client.updatedAt);
    return map;
  }

  Client _clientFromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    data['id'] = doc.id;
    if (data['createdAt'] is Timestamp) {
      data['createdAt'] = (data['createdAt'] as Timestamp).toDate().toIso8601String();
    }
    if (data['updatedAt'] is Timestamp) {
      data['updatedAt'] = (data['updatedAt'] as Timestamp).toDate().toIso8601String();
    }
    return Client.fromJson(data);
  }

  Map<String, dynamic> _paymentToDoc(ClientPayment payment) {
    final map = payment.toJson();
    map.remove('id');
    map['paymentDate'] = Timestamp.fromDate(payment.paymentDate);
    return map;
  }

  ClientPayment _paymentFromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    data['id'] = doc.id;
    if (data['paymentDate'] is Timestamp) {
      data['paymentDate'] = (data['paymentDate'] as Timestamp).toDate().toIso8601String();
    }
    return ClientPayment.fromJson(data);
  }

  // CREATE
  Future<String> createClient(Client client) async {
    final docRef = await _clientsRef.add(_clientToDoc(client));
    return docRef.id;
  }

  // UPDATE
  Future<void> updateClient(Client client) async {
    await _clientsRef.doc(client.id).update(_clientToDoc(client));
  }

  // UPDATE BALANCE ONLY
  Future<void> updateClientBalance(String clientId, double amountToAdd) async {
    await _clientsRef.doc(clientId).update({
      'currentBalance': FieldValue.increment(amountToAdd),
      'updatedAt': Timestamp.now(),
    });
  }

  // ADD NEW VEHICLE TO CLIENT
  Future<void> addVehicleToClient(String clientId, String vehiclePlate) async {
    await _clientsRef.doc(clientId).update({
      'vehicles': FieldValue.arrayUnion([vehiclePlate.toUpperCase()]),
      'updatedAt': Timestamp.now(),
    });
  }

  // DELETE
  Future<void> deleteClient(String clientId) async {
    await _clientsRef.doc(clientId).delete();
  }

  // CHECK IF DELETE IS POSSIBLE
  Future<bool> canDeleteClient(String clientId) async {
    final paymentsSnap = await _tenantPaymentsRef.where('clientId', isEqualTo: clientId).limit(1).get();
    if (paymentsSnap.docs.isNotEmpty) return false;

    final ticketsSnap = await _firestore.collection('tickets').where('clientId', isEqualTo: clientId).limit(1).get();
    if (ticketsSnap.docs.isNotEmpty) return false;

    return true;
  }

  // WATCH CLIENTS
  Stream<List<Client>> watchClients(String stationId) {
    return _tenantClientsRef
        .where('tenantId', isEqualTo: stationId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => _clientFromDoc(doc)).toList());
  }

  // ADD PAYMENT
  Future<void> addPayment(ClientPayment payment) async {
    final batch = _firestore.batch();

    // 1. Add payment record
    final paymentDoc = _paymentsRef.doc();
    batch.set(paymentDoc, _paymentToDoc(payment));

    // 2. Reduce client balance
    final clientDoc = _clientsRef.doc(payment.clientId);
    batch.update(clientDoc, {
      'currentBalance': FieldValue.increment(-payment.amount),
      'updatedAt': Timestamp.now(),
    });

    await batch.commit();
  }

  // DELETE PAYMENT
  Future<void> deletePayment(ClientPayment payment) async {
    final batch = _firestore.batch();

    // 1. Remove payment record
    final paymentDoc = _paymentsRef.doc(payment.id);
    batch.delete(paymentDoc);

    // 2. Refund client balance (increase current balance)
    final clientDoc = _clientsRef.doc(payment.clientId);
    batch.update(clientDoc, {
      'currentBalance': FieldValue.increment(payment.amount),
      'updatedAt': Timestamp.now(),
    });

    await batch.commit();
  }


  // WATCH PAYMENTS FOR A CLIENT
  Stream<List<ClientPayment>> watchClientPayments(String clientId) {
    return _tenantPaymentsRef
        .where('clientId', isEqualTo: clientId)
        .orderBy('paymentDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => _paymentFromDoc(doc)).toList());
  }

  Future<List<ClientPayment>> getClientPayments(String clientId) async {
    final querySnapshot = await _tenantPaymentsRef
        .where('clientId', isEqualTo: clientId)
        .orderBy('paymentDate', descending: true)
        .get();
    return querySnapshot.docs.map((doc) => _paymentFromDoc(doc)).toList();
  }
}

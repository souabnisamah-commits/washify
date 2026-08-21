import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:washify/core/constants/app_constants.dart';
import 'package:washify/features/caisse/models/cash_session.dart';
import 'package:washify/features/caisse/models/cash_movement.dart';
import 'package:washify/features/wallet/models/wallet.dart';
import 'package:washify/repositories/wallet_repository.dart';

class CaisseRepository {
  final FirebaseFirestore _firestore;
  final String tenantId;
  final WalletRepository _walletRepo;

  CaisseRepository({
    FirebaseFirestore? firestore,
    this.tenantId = '',
    required WalletRepository walletRepo,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _walletRepo = walletRepo;

  CollectionReference get _sessionsRef => _firestore.collection(AppConstants.cashSessionsCollection);
  CollectionReference get _movementsRef => _firestore.collection(AppConstants.cashMovementsCollection);

  Query get _tenantSessionsRef => tenantId.isEmpty ? _sessionsRef : _sessionsRef.where('stationId', isEqualTo: tenantId);
  Query get _tenantMovementsRef => tenantId.isEmpty ? _movementsRef : _movementsRef.where('stationId', isEqualTo: tenantId);

  CashSession _sessionFromDoc(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    return CashSession.fromJson({
      ...data,
      'id': doc.id,
      'openingDate': (data['openingDate'] as Timestamp).toDate().toIso8601String(),
      'closingDate': (data['closingDate'] as Timestamp?)?.toDate().toIso8601String(),
      'createdAt': (data['createdAt'] as Timestamp).toDate().toIso8601String(),
      'updatedAt': (data['updatedAt'] as Timestamp).toDate().toIso8601String(),
      'initialBalance': (data['initialBalance'] as num).toDouble(),
      'finalBalance': (data['finalBalance'] as num?)?.toDouble(),
      'totalCashIn': (data['totalCashIn'] as num?)?.toDouble() ?? 0.0,
      'totalCashOut': (data['totalCashOut'] as num?)?.toDouble() ?? 0.0,
    });
  }

  Map<String, dynamic> _sessionToDoc(CashSession session) {
    final map = session.toJson();
    map.remove('id');
    map['openingDate'] = Timestamp.fromDate(session.openingDate);
    if (session.closingDate != null) {
      map['closingDate'] = Timestamp.fromDate(session.closingDate!);
    }
    map['createdAt'] = Timestamp.fromDate(session.createdAt);
    map['updatedAt'] = Timestamp.fromDate(session.updatedAt);
    return map;
  }

  CashMovement _movementFromDoc(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    return CashMovement.fromJson({
      ...data,
      'id': doc.id,
      'createdAt': (data['createdAt'] as Timestamp).toDate().toIso8601String(),
      'amount': (data['amount'] as num).toDouble(),
    });
  }

  Map<String, dynamic> _movementToDoc(CashMovement movement) {
    final map = movement.toJson();
    map.remove('id');
    map['createdAt'] = Timestamp.fromDate(movement.createdAt);
    return map;
  }

  Stream<CashSession?> watchActiveSession() {
    return _tenantSessionsRef
        .where('status', isEqualTo: 'open')
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      return _sessionFromDoc(snapshot.docs.first);
    });
  }

  Future<CashSession?> getActiveSession() async {
    final snapshot = await _tenantSessionsRef
        .where('status', isEqualTo: 'open')
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return null;
    return _sessionFromDoc(snapshot.docs.first);
  }

  Stream<List<CashSession>> watchSessions() {
    return _tenantSessionsRef
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs.map((doc) => _sessionFromDoc(doc)).toList();
      list.sort((a, b) => b.openingDate.compareTo(a.openingDate));
      return list;
    });
  }

  Stream<List<CashMovement>> watchMovements(String sessionId) {
    return _tenantMovementsRef
        .where('sessionId', isEqualTo: sessionId)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs.map((doc) => _movementFromDoc(doc)).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  Future<void> openSession(double initialBalance, String openedBy) async {
    final active = await getActiveSession();
    if (active != null) {
      throw Exception("Une session de caisse est déjà ouverte.");
    }

    final newSession = CashSession(
      id: '',
      stationId: tenantId,
      openingDate: DateTime.now(),
      openedBy: openedBy,
      initialBalance: initialBalance,
      status: 'open',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _sessionsRef.add(_sessionToDoc(newSession));
  }

  Future<void> closeSession(String sessionId, double finalBalance, String closedBy) async {
    final docRef = _sessionsRef.doc(sessionId);
    final doc = await docRef.get();
    if (!doc.exists) throw Exception("Session introuvable.");

    final session = _sessionFromDoc(doc);
    if (session.status == 'closed') throw Exception("Session déjà clôturée.");

    final updatedSession = session.copyWith(
      status: 'closed',
      closingDate: DateTime.now(),
      closedBy: closedBy,
      finalBalance: finalBalance,
      updatedAt: DateTime.now(),
    );

    await docRef.update(_sessionToDoc(updatedSession));
  }

  Future<void> addMovement(CashMovement movement) async {
    final activeSession = await getActiveSession();
    if (activeSession == null) {
      throw Exception("Aucune session de caisse ouverte. Veuillez d'abord ouvrir la caisse.");
    }

    final movementWithSession = movement.copyWith(
      sessionId: activeSession.id,
      stationId: tenantId,
      createdAt: DateTime.now(),
    );

    if (movement.reason.contains('Acompte') && movement.employeeId != null) {
      final walletTx = WalletTransaction(
        id: '',
        walletId: '',
        userId: movement.employeeId!,
        tenantId: tenantId,
        type: WalletTransactionType.retrait,
        amount: movement.amount,
        balanceBefore: 0.0,
        balanceAfter: 0.0,
        description: "Acompte caisse : ${movement.reason}",
        createdAt: DateTime.now(),
      );
      await _walletRepo.addTransaction(walletTx);
    }

    await _movementsRef.add(_movementToDoc(movementWithSession));

    final sessionRef = _sessionsRef.doc(activeSession.id);
    await _firestore.runTransaction((transaction) async {
      final sessionDoc = await transaction.get(sessionRef);
      if (!sessionDoc.exists) return;
      
      final currentSession = _sessionFromDoc(sessionDoc);
      double cashIn = currentSession.totalCashIn;
      double cashOut = currentSession.totalCashOut;
      
      if (movement.type == 'in') {
        cashIn += movement.amount;
      } else {
        cashOut += movement.amount;
      }
      
      transaction.update(sessionRef, {
        'totalCashIn': cashIn,
        'totalCashOut': cashOut,
        'updatedAt': Timestamp.now(),
      });
    });
  }
}

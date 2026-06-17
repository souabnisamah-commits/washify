import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:washify/core/constants/app_constants.dart';
import 'package:washify/features/wallet/models/wallet.dart';

class WalletRepository {
  final FirebaseFirestore _firestore;

  WalletRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference get _walletsRef =>
      _firestore.collection(AppConstants.walletsCollection);

  CollectionReference get _transactionsRef =>
      _firestore.collection(AppConstants.walletTransactionsCollection);

  Wallet _walletFromDoc(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    final balance = (data['balance'] as num?)?.toDouble() ?? 0.0;
    final walletBalanceCache = (data['walletBalanceCache'] as num?)?.toDouble() ?? balance;

    return Wallet.fromJson({
      ...data,
      'id': doc.id,
      'tenantId': data['tenantId'] ?? data['stationId'] ?? '',
      'walletBalanceCache': walletBalanceCache,
      'totalEarned': (data['totalEarned'] as num?)?.toDouble() ?? 0.0,
      'totalWithdrawn': (data['totalWithdrawn'] as num?)?.toDouble() ?? 0.0,
      'updatedAt': (data['updatedAt'] as Timestamp?)?.toDate().toIso8601String() ?? DateTime.now().toIso8601String(),
    });
  }

  Map<String, dynamic> _walletToDoc(Wallet wallet) {
    final data = wallet.toJson();
    data.remove('id');
    data['updatedAt'] = Timestamp.fromDate(wallet.updatedAt);
    data['balance'] = wallet.walletBalanceCache;
    data['stationId'] = wallet.tenantId;
    return data;
  }

  WalletTransaction _transactionFromDoc(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    final typeStr = data['type'] as String? ?? 'deposit';
    WalletTransactionType type;
    if (typeStr == 'deposit') {
      type = WalletTransactionType.bonus;
    } else if (typeStr == 'commission') {
      type = WalletTransactionType.gainTicket;
    } else if (typeStr == 'withdrawal' || typeStr == 'payroll') {
      type = WalletTransactionType.retrait;
    } else {
      type = WalletTransactionType.fromString(typeStr);
    }

    return WalletTransaction.fromJson({
      ...data,
      'id': doc.id,
      'walletId': data['walletId'] ?? '',
      'userId': data['userId'] ?? '',
      'tenantId': data['tenantId'] ?? data['stationId'] ?? '',
      'type': type.value,
      'amount': (data['amount'] as num?)?.toDouble() ?? 0.0,
      'balanceBefore': (data['balanceBefore'] as num?)?.toDouble() ?? 0.0,
      'balanceAfter': (data['balanceAfter'] as num?)?.toDouble() ?? 0.0,
      'description': data['description'] ?? '',
      'createdAt': (data['createdAt'] as Timestamp?)?.toDate().toIso8601String() ?? DateTime.now().toIso8601String(),
    });
  }

  Map<String, dynamic> _transactionToDoc(WalletTransaction transaction) {
    final data = transaction.toJson();
    data.remove('id');
    data['createdAt'] = Timestamp.fromDate(transaction.createdAt);

    String typeStr;
    switch (transaction.type) {
      case WalletTransactionType.bonus:
        typeStr = 'deposit';
        break;
      case WalletTransactionType.gainTicket:
        typeStr = 'commission';
        break;
      case WalletTransactionType.retrait:
        typeStr = 'withdrawal';
        break;
      default:
        typeStr = 'ajustement';
        break;
    }
    data['type'] = typeStr;
    data['stationId'] = transaction.tenantId;

    return data;
  }

  Future<Wallet?> getWalletByUser(String userId) async {
    final querySnapshot = await _walletsRef
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();
    if (querySnapshot.docs.isEmpty) return null;
    return _walletFromDoc(querySnapshot.docs.first);
  }

  Future<Wallet> getOrCreateWallet(String userId, String userName) async {
    final existing = await getWalletByUser(userId);
    if (existing != null) return existing;

    final wallet = Wallet(
      id: '',
      userId: userId,
      userName: userName,
      tenantId: '',
      walletBalanceCache: 0,
      totalEarned: 0,
      totalWithdrawn: 0,
      updatedAt: DateTime.now(),
    );

    final docRef = await _walletsRef.add(_walletToDoc(wallet));
    return wallet.copyWith(id: docRef.id);
  }

  Future<void> addTransaction(WalletTransaction transaction) async {
    final batch = _firestore.batch();

    final transRef = _transactionsRef.doc();
    batch.set(transRef, _transactionToDoc(transaction));

    final walletQuery = await _walletsRef
        .where('userId', isEqualTo: transaction.userId)
        .limit(1)
        .get();

    if (walletQuery.docs.isNotEmpty) {
      final walletDoc = walletQuery.docs.first;
      final wallet = _walletFromDoc(walletDoc);

      final isCredit = transaction.type == WalletTransactionType.bonus ||
          transaction.type == WalletTransactionType.gainTicket;

      final newBalance = isCredit
          ? wallet.balance + transaction.amount
          : wallet.balance - transaction.amount;

      final updates = <String, dynamic>{
        'balance': newBalance,
        'walletBalanceCache': newBalance,
        'updatedAt': Timestamp.now(),
      };

      if (isCredit) {
        updates['totalEarned'] = wallet.totalEarned + transaction.amount;
      } else {
        updates['totalWithdrawn'] = wallet.totalWithdrawn + transaction.amount;
      }

      batch.update(walletDoc.reference, updates);
    }

    await batch.commit();
  }

  Future<List<WalletTransaction>> getTransactions(String userId,
      {int limit = 50}) async {
    final querySnapshot = await _transactionsRef
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();
    return querySnapshot.docs
        .map((doc) => _transactionFromDoc(doc))
        .toList();
  }

  Stream<Wallet?> watchWallet(String userId) {
    return _walletsRef
        .where('userId', isEqualTo: userId)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      return _walletFromDoc(snapshot.docs.first);
    });
  }
}

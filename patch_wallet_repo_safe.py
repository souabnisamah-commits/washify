import os

wallet_repo_path = 'lib/repositories/wallet_repository.dart'
with open(wallet_repo_path, 'r', encoding='utf-8') as f:
    code = f.read()

# Make _transactionFromDoc bulletproof
target_transaction_from_doc = """  WalletTransaction _transactionFromDoc(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    final typeStr = data['type'] as String? ?? 'deposit';
    WalletTransactionType type;
    if (typeStr == 'deposit') {
      type = WalletTransactionType.bonus;
    } else if (typeStr == 'commission') {
      type = WalletTransactionType.gainTicket;
    } else if (typeStr == 'salaire') {
      type = WalletTransactionType.salaireJour;
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
      'type': type.name,
      'amount': (data['amount'] as num?)?.toDouble() ?? 0.0,
      'balanceBefore': (data['balanceBefore'] as num?)?.toDouble() ?? 0.0,
      'balanceAfter': (data['balanceAfter'] as num?)?.toDouble() ?? 0.0,
      'description': data['description'] ?? '',
      'createdAt': (data['createdAt'] as Timestamp?)?.toDate().toIso8601String() ?? DateTime.now().toIso8601String(),
    });
  }"""

safe_transaction_from_doc = """  WalletTransaction _transactionFromDoc(DocumentSnapshot doc) {
    try {
      final data = (doc.data() as Map<String, dynamic>?) ?? {};
      final typeStr = data['type']?.toString() ?? 'deposit';
      WalletTransactionType type;
      if (typeStr == 'deposit') {
        type = WalletTransactionType.bonus;
      } else if (typeStr == 'commission') {
        type = WalletTransactionType.gainTicket;
      } else if (typeStr == 'salaire') {
        type = WalletTransactionType.salaireJour;
      } else if (typeStr == 'withdrawal' || typeStr == 'payroll') {
        type = WalletTransactionType.retrait;
      } else {
        type = WalletTransactionType.fromString(typeStr);
      }
      
      String createdAtStr;
      if (data['createdAt'] is Timestamp) {
        createdAtStr = (data['createdAt'] as Timestamp).toDate().toIso8601String();
      } else if (data['createdAt'] is String) {
        createdAtStr = data['createdAt'] as String;
      } else {
        createdAtStr = DateTime.now().toIso8601String();
      }

      double parseNum(dynamic val) {
        if (val == null) return 0.0;
        if (val is num) return val.toDouble();
        if (val is String) return double.tryParse(val) ?? 0.0;
        return 0.0;
      }

      return WalletTransaction.fromJson({
        'id': doc.id,
        'walletId': data['walletId']?.toString() ?? '',
        'userId': data['userId']?.toString() ?? '',
        'tenantId': data['tenantId']?.toString() ?? data['stationId']?.toString() ?? '',
        'type': type.name,
        'amount': parseNum(data['amount']),
        'balanceBefore': parseNum(data['balanceBefore']),
        'balanceAfter': parseNum(data['balanceAfter']),
        'description': data['description']?.toString() ?? '',
        'createdAt': createdAtStr,
      });
    } catch (e) {
      return WalletTransaction(
        id: doc.id,
        walletId: '',
        userId: '',
        tenantId: '',
        type: WalletTransactionType.ajustement,
        amount: 0.0,
        balanceBefore: 0.0,
        balanceAfter: 0.0,
        description: 'Erreur de lecture',
        createdAt: DateTime.now(),
      );
    }
  }"""

if target_transaction_from_doc in code:
    code = code.replace(target_transaction_from_doc, safe_transaction_from_doc)

# Make _walletFromDoc bulletproof
target_wallet_from_doc = """  Wallet _walletFromDoc(DocumentSnapshot doc) {
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
  }"""

safe_wallet_from_doc = """  Wallet _walletFromDoc(DocumentSnapshot doc) {
    try {
      final data = (doc.data() as Map<String, dynamic>?) ?? {};
      
      double parseNum(dynamic val) {
        if (val == null) return 0.0;
        if (val is num) return val.toDouble();
        if (val is String) return double.tryParse(val) ?? 0.0;
        return 0.0;
      }

      final balance = parseNum(data['balance']);
      final walletBalanceCache = data['walletBalanceCache'] != null ? parseNum(data['walletBalanceCache']) : balance;

      String updatedAtStr;
      if (data['updatedAt'] is Timestamp) {
        updatedAtStr = (data['updatedAt'] as Timestamp).toDate().toIso8601String();
      } else if (data['updatedAt'] is String) {
        updatedAtStr = data['updatedAt'] as String;
      } else {
        updatedAtStr = DateTime.now().toIso8601String();
      }

      return Wallet.fromJson({
        'id': doc.id,
        'userId': data['userId']?.toString() ?? '',
        'userName': data['userName']?.toString() ?? 'Employé',
        'tenantId': data['tenantId']?.toString() ?? data['stationId']?.toString() ?? '',
        'walletBalanceCache': walletBalanceCache,
        'totalEarned': parseNum(data['totalEarned']),
        'totalWithdrawn': parseNum(data['totalWithdrawn']),
        'updatedAt': updatedAtStr,
      });
    } catch (e) {
      return Wallet(
        id: doc.id,
        userId: '',
        userName: 'Erreur',
        tenantId: '',
        walletBalanceCache: 0.0,
        totalEarned: 0.0,
        totalWithdrawn: 0.0,
        updatedAt: DateTime.now(),
      );
    }
  }"""

if target_wallet_from_doc in code:
    code = code.replace(target_wallet_from_doc, safe_wallet_from_doc)

with open(wallet_repo_path, 'w', encoding='utf-8') as f:
    f.write(code)

print("wallet_repository.dart patched")

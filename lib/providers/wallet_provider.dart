import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:washify/features/wallet/models/wallet.dart';
import 'package:washify/repositories/wallet_repository.dart';

final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  return WalletRepository();
});

final walletByUserProvider =
    FutureProvider.family<Wallet?, String>((ref, userId) async {
  final repo = ref.watch(walletRepositoryProvider);
  return repo.getWalletByUser(userId);
});

final walletTransactionsProvider =
    FutureProvider.family<List<WalletTransaction>, String>((ref, userId) async {
  final repo = ref.watch(walletRepositoryProvider);
  return repo.getTransactions(userId);
});

final walletStreamProvider =
    StreamProvider.family<Wallet?, String>((ref, userId) {
  final repo = ref.watch(walletRepositoryProvider);
  return repo.watchWallet(userId);
});

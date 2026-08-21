import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:washify/providers/auth_provider.dart';
import 'package:washify/providers/wallet_provider.dart';
import 'package:washify/repositories/caisse_repository.dart';
import 'package:washify/features/caisse/models/cash_session.dart';
import 'package:washify/features/caisse/models/cash_movement.dart';

final caisseRepositoryProvider = Provider<CaisseRepository>((ref) {
  final user = ref.watch(currentUserProvider);
  final walletRepo = ref.watch(walletRepositoryProvider);
  return CaisseRepository(
    tenantId: user?.tenantId ?? '',
    walletRepo: walletRepo,
  );
});

final activeSessionProvider = StreamProvider<CashSession?>((ref) {
  final repo = ref.watch(caisseRepositoryProvider);
  return repo.watchActiveSession();
});

final sessionsHistoryProvider = StreamProvider<List<CashSession>>((ref) {
  final repo = ref.watch(caisseRepositoryProvider);
  return repo.watchSessions();
});

final sessionMovementsProvider = StreamProvider.family<List<CashMovement>, String>((ref, sessionId) {
  final repo = ref.watch(caisseRepositoryProvider);
  return repo.watchMovements(sessionId);
});

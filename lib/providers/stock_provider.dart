import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:washify/providers/auth_provider.dart';
import 'package:washify/features/stock/models/stock.dart';
import 'package:washify/repositories/stock_repository.dart';

final stockRepositoryProvider = Provider<StockRepository>((ref) {
  final user = ref.watch(currentUserProvider);
  return StockRepository(tenantId: user?.tenantId ?? '');
});

final stockByStationProvider =
    FutureProvider.family<List<StockLevel>, String>((ref, stationId) async {
  final repo = ref.watch(stockRepositoryProvider);
  return repo.getStockByStation(stationId);
});

final stockLevelProvider =
    FutureProvider.family<StockLevel?, ({String stationId, String productId})>(
        (ref, arg) async {
  final repo = ref.watch(stockRepositoryProvider);
  return repo.getStockLevel(arg.stationId, arg.productId);
});

final stockMovementsProvider =
    FutureProvider.family<List<StockMovement>, ({String stationId, String? productId})>(
        (ref, arg) async {
  final repo = ref.watch(stockRepositoryProvider);
  return repo.getStockMovements(arg.stationId, productId: arg.productId);
});

final lowStockItemsProvider =
    FutureProvider.family<List<StockLevel>, String>((ref, stationId) async {
  final repo = ref.watch(stockRepositoryProvider);
  return repo.getLowStockItems(stationId);
});

final stockStreamProvider =
    StreamProvider.family<List<StockLevel>, String>((ref, stationId) {
  final repo = ref.watch(stockRepositoryProvider);
  return repo.watchStockByStation(stationId);
});

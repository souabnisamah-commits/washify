import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:washify/features/inventory/models/inventory.dart';
import 'package:washify/repositories/inventory_repository.dart';

final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  return InventoryRepository();
});

final inventoriesProvider =
    FutureProvider.family<List<Inventory>, String>((ref, stationId) async {
  final repo = ref.watch(inventoryRepositoryProvider);
  return repo.getInventoriesByStation(stationId);
});

final inventoryByIdProvider =
    FutureProvider.family<Inventory?, String>((ref, inventoryId) async {
  final repo = ref.watch(inventoryRepositoryProvider);
  return repo.getInventoryById(inventoryId);
});

final inventoriesStreamProvider =
    StreamProvider.family<List<Inventory>, String>((ref, stationId) {
  final repo = ref.watch(inventoryRepositoryProvider);
  return repo.watchInventoriesByStation(stationId);
});

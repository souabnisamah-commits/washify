import 'package:washify/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:washify/features/services/models/vehicle_category.dart';
import 'package:washify/repositories/vehicle_category_repository.dart';

final vehicleCategoryRepositoryProvider = Provider<VehicleCategoryRepository>((ref) {
  final user = ref.watch(currentUserProvider);
  return VehicleCategoryRepository(tenantId: user?.tenantId ?? '');
});

final vehicleCategoriesByStationProvider =
    FutureProvider.family<List<VehicleCategory>, String>((ref, stationId) async {
  final repo = ref.watch(vehicleCategoryRepositoryProvider);
  return repo.getByStation(stationId);
});

final vehicleCategoriesStreamProvider =
    StreamProvider.family<List<VehicleCategory>, String>((ref, stationId) {
  final repo = ref.watch(vehicleCategoryRepositoryProvider);
  return repo.watchByStation(stationId);
});

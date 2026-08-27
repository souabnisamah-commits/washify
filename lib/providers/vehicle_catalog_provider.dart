import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:washify/repositories/vehicle_catalog_repository.dart';
import 'package:washify/features/tickets/models/vehicle_catalog.dart';
import 'package:washify/providers/auth_provider.dart';

final vehicleCatalogRepositoryProvider = Provider<VehicleCatalogRepository>((ref) {
  return VehicleCatalogRepository();
});

final vehicleCatalogStreamProvider = StreamProvider.family<VehicleCatalog, String>((ref, stationId) {
  if (stationId.isEmpty) return Stream.value(VehicleCatalog.empty(''));
  final repository = ref.watch(vehicleCatalogRepositoryProvider);
  return repository.watchVehicleCatalog(stationId);
});

final currentVehicleCatalogStreamProvider = StreamProvider<VehicleCatalog>((ref) {
  final user = ref.watch(currentUserProvider);
  final stationId = user?.tenantId ?? '';
  if (stationId.isEmpty) return Stream.value(VehicleCatalog.empty(''));
  final repository = ref.watch(vehicleCatalogRepositoryProvider);
  return repository.watchVehicleCatalog(stationId);
});

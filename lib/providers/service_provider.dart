import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:washify/features/services/models/wash_service.dart';
import 'package:washify/repositories/service_repository.dart';

final serviceRepositoryProvider = Provider<ServiceRepository>((ref) {
  return ServiceRepository();
});

final servicesProvider = FutureProvider<List<WashService>>((ref) async {
  final repo = ref.watch(serviceRepositoryProvider);
  return repo.getAllServices();
});

final servicesByStationProvider =
    FutureProvider.family<List<WashService>, String>((ref, stationId) async {
  final repo = ref.watch(serviceRepositoryProvider);
  return repo.getServicesByStation(stationId);
});

final serviceByIdProvider =
    FutureProvider.family<WashService?, String>((ref, serviceId) async {
  final repo = ref.watch(serviceRepositoryProvider);
  return repo.getServiceById(serviceId);
});

final servicesStreamProvider =
    StreamProvider.family<List<WashService>, String>((ref, stationId) {
  final repo = ref.watch(serviceRepositoryProvider);
  return repo.watchServicesByStation(stationId);
});

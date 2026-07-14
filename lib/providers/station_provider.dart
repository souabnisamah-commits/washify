import 'package:washify/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:washify/features/station/models/station.dart';
import 'package:washify/repositories/station_repository.dart';

final stationRepositoryProvider = Provider<StationRepository>((ref) {
  final user = ref.watch(currentUserProvider);
  return StationRepository(tenantId: user?.tenantId ?? '');
});

final stationsProvider = FutureProvider<List<Station>>((ref) async {
  final repo = ref.watch(stationRepositoryProvider);
  return repo.getActiveStations();
});

final allStationsProvider = FutureProvider<List<Station>>((ref) async {
  final repo = ref.watch(stationRepositoryProvider);
  return repo.getAllStations();
});

final stationByIdProvider =
    FutureProvider.family<Station?, String>((ref, stationId) async {
  final repo = ref.watch(stationRepositoryProvider);
  return repo.getStationById(stationId);
});

final stationsByPatronProvider =
    FutureProvider.family<List<Station>, String>((ref, patronId) async {
  final repo = ref.watch(stationRepositoryProvider);
  return repo.getStationsByPatron(patronId);
});

final stationsStreamProvider = StreamProvider<List<Station>>((ref) {
  final repo = ref.watch(stationRepositoryProvider);
  return repo.watchStations();
});

final selectedStationProvider = StateProvider<Station?>((ref) => null);

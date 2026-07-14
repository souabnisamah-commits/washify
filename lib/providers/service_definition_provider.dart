import 'package:washify/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:washify/features/services/models/service_definition.dart';
import 'package:washify/repositories/service_definition_repository.dart';

final serviceDefinitionRepositoryProvider = Provider<ServiceDefinitionRepository>((ref) {
  final user = ref.watch(currentUserProvider);
  return ServiceDefinitionRepository(tenantId: user?.tenantId ?? '');
});

final serviceDefinitionsByStationProvider =
    FutureProvider.family<List<ServiceDefinition>, String>((ref, stationId) async {
  final repo = ref.watch(serviceDefinitionRepositoryProvider);
  return repo.getByStation(stationId);
});

final serviceDefinitionsStreamProvider =
    StreamProvider.family<List<ServiceDefinition>, String>((ref, stationId) {
  final repo = ref.watch(serviceDefinitionRepositoryProvider);
  return repo.watchByStation(stationId);
});

/// Provider filtered by service type (lavage, supplement, special)
final serviceDefsByTypeProvider = FutureProvider.family<List<ServiceDefinition>, ({String stationId, ServiceType type})>((ref, params) async {
  final repo = ref.watch(serviceDefinitionRepositoryProvider);
  return repo.getByStationAndType(params.stationId, params.type);
});

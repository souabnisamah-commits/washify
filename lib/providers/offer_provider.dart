import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:washify/features/services/models/offer.dart';
import 'package:washify/repositories/offer_repository.dart';

final offerRepositoryProvider = Provider<OfferRepository>((ref) {
  return OfferRepository();
});

final offersByStationProvider =
    FutureProvider.family<List<Offer>, String>((ref, stationId) async {
  final repo = ref.watch(offerRepositoryProvider);
  return repo.getByStation(stationId);
});

final offersStreamProvider =
    StreamProvider.family<List<Offer>, String>((ref, stationId) {
  final repo = ref.watch(offerRepositoryProvider);
  return repo.watchByStation(stationId);
});

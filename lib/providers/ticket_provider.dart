import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:washify/features/tickets/models/ticket.dart';
import 'package:washify/repositories/ticket_repository.dart';

final ticketRepositoryProvider = Provider<TicketRepository>((ref) {
  return TicketRepository();
});

final ticketsByStationProvider =
    FutureProvider.family<List<Ticket>, ({String stationId, String? status})>(
        (ref, arg) async {
  final repo = ref.watch(ticketRepositoryProvider);
  return repo.getTicketsByStation(arg.stationId, status: arg.status);
});

final ticketsByWorkerProvider =
    FutureProvider.family<List<Ticket>, ({String workerId, String? status})>(
        (ref, arg) async {
  final repo = ref.watch(ticketRepositoryProvider);
  return repo.getTicketsByWorker(arg.workerId, status: arg.status);
});

final todayTicketsProvider =
    FutureProvider.family<List<Ticket>, String>((ref, stationId) async {
  final repo = ref.watch(ticketRepositoryProvider);
  return repo.getTodayTickets(stationId);
});

final ticketByIdProvider =
    FutureProvider.family<Ticket?, String>((ref, ticketId) async {
  final repo = ref.watch(ticketRepositoryProvider);
  return repo.getTicketById(ticketId);
});

final todayTicketsStreamProvider =
    StreamProvider.family<List<Ticket>, String>((ref, stationId) {
  final repo = ref.watch(ticketRepositoryProvider);
  return repo.watchTodayTickets(stationId);
});

final workerTicketsStreamProvider =
    StreamProvider.family<List<Ticket>, String>((ref, workerId) {
  final repo = ref.watch(ticketRepositoryProvider);
  return repo.watchWorkerTickets(workerId);
});

final revenueStatsProvider = FutureProvider.family<
    Map<String, double>,
    ({
      String stationId,
      DateTime startDate,
      DateTime endDate
    })>((ref, arg) async {
  final repo = ref.watch(ticketRepositoryProvider);
  return repo.getRevenueStats(arg.stationId, arg.startDate, arg.endDate);
});

final ticketsByDateRangeProvider = FutureProvider.family<
    List<Ticket>,
    ({
      String stationId,
      DateTime startDate,
      DateTime endDate
    })>((ref, arg) async {
  final repo = ref.watch(ticketRepositoryProvider);
  return repo.getTicketsByDateRange(arg.stationId, arg.startDate, arg.endDate);
});

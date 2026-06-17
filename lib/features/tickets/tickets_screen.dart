import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:washify/core/theme/app_theme.dart';
import 'package:washify/providers/auth_provider.dart';
import 'package:washify/providers/ticket_provider.dart';
import 'package:washify/providers/station_provider.dart';
import 'package:intl/intl.dart';
import 'package:washify/features/tickets/models/ticket.dart';

class TicketsScreen extends ConsumerWidget {
  const TicketsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final selectedStation = ref.watch(selectedStationProvider);

    final stationId = user?.role.value == 'patron'
        ? selectedStation?.id
        : user?.stationId;

    if (stationId == null) {
      return const Scaffold(
        body: Center(child: Text('Sélectionnez d\'abord une station.')),
      );
    }

    final ticketsAsync = ref.watch(ticketsByStationProvider((
      stationId: stationId,
      status: null,
    )));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique Tickets'),
      ),
      body: ticketsAsync.when(
        data: (tickets) {
          if (tickets.isEmpty) {
            return const Center(
              child: Text('Aucun ticket trouvé.', style: TextStyle(color: AppTheme.textHint)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tickets.length,
            itemBuilder: (context, index) {
              final ticket = tickets[index];
              final dateStr = DateFormat('dd/MM HH:mm').format(ticket.createdAt);

              Color statusColor = AppTheme.textHint;
              switch (ticket.status) {
                case TicketStatus.paye:
                  statusColor = AppTheme.successGreen;
                  break;
                case TicketStatus.enAttente:
                  statusColor = AppTheme.warningOrange;
                  break;
                case TicketStatus.rembourse:
                  statusColor = AppTheme.errorRed;
                  break;
              }

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: Icon(Icons.receipt_long, color: statusColor),
                  title: Text(ticket.vehiclePlate ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${ticket.serviceName} (${ticket.vehicleType})\nLaveur: ${ticket.workerName ?? "non assigné"} - $dateStr'),
                  trailing: Text(
                    '${ticket.totalAmount.toStringAsFixed(2)} DT',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Erreur: $e')),
      ),
    );
  }
}

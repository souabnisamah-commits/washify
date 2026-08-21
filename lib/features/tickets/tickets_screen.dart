import 'package:flutter/material.dart';
import 'package:washify/core/localization/app_localizations.dart';

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
      return Scaffold(
        body: Center(child: Text('Sélectionnez d\'abord une station.')),
      );
    }

    final ticketsAsync = ref.watch(ticketsByStationProvider((
      stationId: stationId,
      status: null,
    )));

    return Scaffold(
      appBar: AppBar(
        title: Text('Historique Tickets'.tr),
      ),
      body: ticketsAsync.when(
        data: (tickets) {
          if (tickets.isEmpty) {
            return Center(
              child: Text('Aucun ticket trouvé.', style: TextStyle(color: AppTheme.textHint)),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
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
                case TicketStatus.annule:
                  statusColor = AppTheme.textHint;
                  break;
                case TicketStatus.efface:
                  statusColor = AppTheme.errorRed;
                  break;
              }

              final isDeleted = ticket.status == TicketStatus.efface;

              return Card(
                margin: EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: Icon(Icons.receipt_long, color: statusColor),
                  title: Text(
                    "${ticket.ticketNumber} - ${ticket.vehiclePlate ?? ''}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      decoration: isDeleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${ticket.serviceName} (${ticket.vehicleType ?? "Véhicule"})\nLaveur: ${ticket.assignedWorkerName ?? "non assigné"} - $dateStr',
                        style: TextStyle(decoration: isDeleted ? TextDecoration.lineThrough : null),
                      ),
                      if (isDeleted)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            "Effacé par: ${ticket.deletedBy} (Motif: ${ticket.deleteReason})",
                            style: TextStyle(color: AppTheme.errorRed, fontSize: 11, fontStyle: FontStyle.italic),
                          ),
                        ),
                    ],
                  ),
                  trailing: Text(
                    '${ticket.totalAmount.toStringAsFixed(2)} DT',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isDeleted ? AppTheme.errorRed : Colors.white,
                      decoration: isDeleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
        loading: () => Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Erreur: $e'.tr)),
      ),
    );
  }
}

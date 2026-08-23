import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:washify/core/localization/app_localizations.dart';
import 'package:washify/core/theme/app_theme.dart';
import 'package:washify/features/clients/models/client.dart';
import 'package:washify/features/clients/models/client_payment.dart';
import 'package:washify/features/clients/utils/b2b_pdf_generator.dart';
import 'package:washify/features/tickets/models/ticket.dart';
import 'package:washify/providers/auth_provider.dart';
import 'package:washify/providers/station_provider.dart';
import 'package:washify/repositories/client_repository.dart';
import 'package:washify/repositories/ticket_repository.dart';
import 'package:printing/printing.dart';

// Stream of Client profile for real-time balance & threshold updates
final currentB2BClientProvider = StreamProvider<Client?>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null || user.clientId == null || user.clientId!.isEmpty) {
    return const Stream.empty();
  }
  return ref.watch(clientRepositoryProvider).watchClientById(user.clientId!);
});

final b2bClientTicketsProvider = StreamProvider.family<List<Ticket>, String>((ref, clientId) {
  final user = ref.watch(currentUserProvider);
  if (user == null || user.stationId == null) return const Stream.empty();
  return ref.watch(ticketRepositoryProvider).watchClientTickets(user.stationId!, clientId);
});

class B2BClientDashboardScreen extends ConsumerStatefulWidget {
  const B2BClientDashboardScreen({super.key});

  @override
  ConsumerState<B2BClientDashboardScreen> createState() => _B2BClientDashboardScreenState();
}

class _B2BClientDashboardScreenState extends ConsumerState<B2BClientDashboardScreen> {
  final currencyFormat = NumberFormat.currency(locale: 'fr_FR', symbol: 'DT');

  void _logout() {
    ref.read(currentUserProvider.notifier).logout();
  }

  Future<void> _exportPdf(Client client, List<Ticket> tickets) async {
    final user = ref.read(currentUserProvider);
    if (user?.stationId == null) return;
    final station = await ref.read(stationRepositoryProvider).getStationById(user!.stationId!);
    if (station == null) return;
    final pdfBytes = await B2BPdfGenerator.generateUnpaidBalanceReport(
      station: station,
      client: client,
      unpaidTickets: tickets.where((t) => t.status != TicketStatus.annule && t.status != TicketStatus.efface).toList(),
    );
    await Printing.layoutPdf(
      onLayout: (format) async => pdfBytes,
      name: 'Releve_Solde_B2B_${client.companyName.replaceAll(' ', '_')}.pdf',
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final clientAsync = ref.watch(currentB2BClientProvider);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppTheme.accentCyan.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.business_outlined, color: AppTheme.accentCyan, size: 20),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user?.name ?? 'Espace Client B2B'.tr,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    'Portail Entreprise'.tr,
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
          backgroundColor: AppTheme.primaryBlue,
          elevation: 2,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              tooltip: 'Déconnexion'.tr,
              onPressed: _logout,
            ),
          ],
          bottom: TabBar(
            indicatorColor: AppTheme.accentCyan,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(icon: const Icon(Icons.receipt_long, size: 18), text: 'Détail Solde'.tr),
              Tab(icon: const Icon(Icons.history, size: 18), text: 'Paiements'.tr),
              Tab(icon: const Icon(Icons.directions_car, size: 18), text: 'Flotte Véhicules'.tr),
            ],
          ),
        ),
        body: clientAsync.when(
          data: (client) {
            if (client == null || !client.hasAppAccess || client.accessStatus == 'blocked') {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.block, size: 54, color: AppTheme.errorRed),
                      const SizedBox(height: 16),
                      Text(
                        'Accès suspendu ou désactivé par le lavoir.'.tr,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Veuillez contacter le patron de la station pour régulariser l\'accès à votre compte.'.tr,
                        style: const TextStyle(color: AppTheme.textHint, fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _logout,
                        child: Text('Déconnexion'.tr),
                      ),
                    ],
                  ),
                ),
              );
            }

            final isOverThreshold = client.alertThreshold > 0 && client.currentBalance >= client.alertThreshold;

            return Column(
              children: [
                // Warning Banner if Threshold Exceeded
                if (isOverThreshold)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    color: AppTheme.errorRed,
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 26),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Alerte : Seuil de crédit dépassé !'.tr,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              Text(
                                'Votre solde (${currencyFormat.format(client.currentBalance)}) a dépassé le seuil autorisé (${currencyFormat.format(client.alertThreshold)}). Veuillez effectuer un règlement auprès du lavoir.'.tr,
                                style: const TextStyle(color: Colors.white, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                // Strategic Summary Cards
                Container(
                  color: Theme.of(context).colorScheme.surface,
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildMetricCard(
                          context,
                          'Solde À Payer'.tr,
                          currencyFormat.format(client.currentBalance),
                          Icons.account_balance_wallet_outlined,
                          client.currentBalance > 0 ? AppTheme.errorRed : AppTheme.successGreen,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMetricCard(
                          context,
                          'Seuil Autorisé'.tr,
                          currencyFormat.format(client.alertThreshold),
                          Icons.security_outlined,
                          AppTheme.accentCyan,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMetricCard(
                          context,
                          'Véhicules'.tr,
                          '${client.vehicles.length}',
                          Icons.directions_car_outlined,
                          Colors.purple,
                        ),
                      ),
                    ],
                  ),
                ),

                // Main Tab Views
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildTicketsTab(context, client),
                      _buildPaymentsTab(context, client),
                      _buildVehiclesTab(context, client),
                    ],
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => Center(child: Text('Erreur: $e'.tr)),
        ),
      ),
    );
  }

  Widget _buildMetricCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 10, color: AppTheme.textHint, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildTicketsTab(BuildContext context, Client client) {
    final ticketsAsync = ref.watch(b2bClientTicketsProvider(client.id));
    return ticketsAsync.when(
      data: (tickets) {
        if (tickets.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.receipt_long_outlined, size: 48, color: AppTheme.textHint),
                const SizedBox(height: 12),
                Text('Aucun ticket enregistré pour le moment.'.tr, style: const TextStyle(color: AppTheme.textHint)),
              ],
            ),
          );
        }

        return Column(
          children: [
            // Export Button Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${tickets.length} ticket(s) trouvé(s)',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textHint),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _exportPdf(client, tickets),
                    icon: const Icon(Icons.picture_as_pdf, size: 16),
                    label: Text('Télécharger Relevé B2B'.tr, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
            ),

            // Tickets ListView
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                itemCount: tickets.length,
                itemBuilder: (context, index) {
                  final t = tickets[index];
                  final isCancelled = t.status == TicketStatus.annule || t.status == TicketStatus.efface;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    elevation: 1.5,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: CircleAvatar(
                        backgroundColor: isCancelled
                            ? AppTheme.errorRed.withValues(alpha: 0.15)
                            : AppTheme.primaryBlue.withValues(alpha: 0.15),
                        child: Icon(
                          t.operationType == 'moquette' ? Icons.layers : Icons.directions_car,
                          color: isCancelled ? AppTheme.errorRed : AppTheme.accentCyan,
                        ),
                      ),
                      title: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.accentCyan.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'N° ${t.ticketNumber}',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.accentCyan),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              (t.vehiclePlate != null && t.vehiclePlate!.isNotEmpty) ? t.vehiclePlate! : 'Moquette'.tr,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                decoration: isCancelled ? TextDecoration.lineThrough : null,
                              ),
                            ),
                          ),
                        ],
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t.serviceName ?? '',
                              style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
                            ),
                            Text(
                              DateFormat('dd/MM/yyyy HH:mm').format(t.createdAt),
                              style: const TextStyle(fontSize: 11, color: AppTheme.textHint),
                            ),
                          ],
                        ),
                      ),
                      trailing: Text(
                        currencyFormat.format(t.totalAmount),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isCancelled ? AppTheme.textHint : AppTheme.errorRed,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Erreur: $e'.tr)),
    );
  }

  Widget _buildPaymentsTab(BuildContext context, Client client) {
    final paymentsAsync = ref.watch(clientPaymentsStreamProvider(client.id));
    return paymentsAsync.when(
      data: (payments) {
        if (payments.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.history_outlined, size: 48, color: AppTheme.textHint),
                const SizedBox(height: 12),
                Text('Aucun versement enregistré pour l\'instant.'.tr, style: const TextStyle(color: AppTheme.textHint)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: payments.length,
          itemBuilder: (context, index) {
            final p = payments[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              elevation: 1.5,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0x204CAF50),
                  child: Icon(Icons.check_circle_outline, color: AppTheme.successGreen),
                ),
                title: Text('Paiement : ${p.paymentMethod}'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
                  '${DateFormat('dd/MM/yyyy HH:mm').format(p.paymentDate)}\n${p.reference != null ? 'Réf: ${p.reference}' : ''}',
                  style: const TextStyle(fontSize: 12, color: AppTheme.textHint),
                ),
                isThreeLine: p.reference != null,
                trailing: Text(
                  currencyFormat.format(p.amount),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.successGreen),
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Erreur: $e'.tr)),
    );
  }

  Widget _buildVehiclesTab(BuildContext context, Client client) {
    if (client.vehicles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.directions_car_outlined, size: 48, color: AppTheme.textHint),
            const SizedBox(height: 12),
            Text('Aucun véhicule enregistré dans la flotte.'.tr, style: const TextStyle(color: AppTheme.textHint)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: client.vehicles.length,
      itemBuilder: (context, index) {
        final v = client.vehicles[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          elevation: 1.5,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Color(0x2000BCD4),
              child: Icon(Icons.directions_car, color: AppTheme.accentCyan),
            ),
            title: Text(v.plate, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            subtitle: Text('Véhicule autorisé de la flotte B2B'.tr, style: const TextStyle(fontSize: 12, color: AppTheme.textHint)),
            trailing: const Icon(Icons.verified, color: AppTheme.successGreen, size: 20),
          ),
        );
      },
    );
  }
}

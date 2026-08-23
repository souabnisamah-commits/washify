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
  String _ticketFilter = 'all'; // 'all', 'unpaid', 'paid'

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

        // Calculate FIFO Unpaid tickets making up the current balance
        final Set<String> unpaidTicketIds = {};
        final validTickets = tickets.where((t) => t.status != TicketStatus.annule && t.status != TicketStatus.efface).toList();
        
        double remBalance = client.currentBalance;
        for (final t in validTickets) {
          if (remBalance <= 0.01) break;
          unpaidTicketIds.add(t.id);
          remBalance -= t.montant;
        }

        final unpaidCount = tickets.where((t) => unpaidTicketIds.contains(t.id)).length;
        final paidCount = tickets.where((t) => !unpaidTicketIds.contains(t.id) && t.status != TicketStatus.annule && t.status != TicketStatus.efface).length;

        final filtered = tickets.where((t) {
          final isUnpaid = unpaidTicketIds.contains(t.id);
          final isCancelled = t.status == TicketStatus.annule || t.status == TicketStatus.efface;
          final isPaid = !isUnpaid && !isCancelled;

          if (_ticketFilter == 'unpaid' && !isUnpaid) return false;
          if (_ticketFilter == 'paid' && !isPaid) return false;
          return true;
        }).toList();

        return Column(
          children: [
            // Export Button & Filter Chips Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${filtered.length} ticket(s)',
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

            // Filter Chips Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    FilterChip(
                      label: Text('Tous (${tickets.length})'.tr),
                      selected: _ticketFilter == 'all',
                      onSelected: (_) => setState(() => _ticketFilter = 'all'),
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      avatar: const Icon(Icons.warning_amber_rounded, size: 14, color: AppTheme.warningOrange),
                      label: Text('Solde En Cours ($unpaidCount)'.tr),
                      selected: _ticketFilter == 'unpaid',
                      selectedColor: AppTheme.warningOrange.withValues(alpha: 0.25),
                      onSelected: (_) => setState(() => _ticketFilter = 'unpaid'),
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      avatar: const Icon(Icons.check_circle_outline, size: 14, color: AppTheme.successGreen),
                      label: Text('Archivés / Réglés ($paidCount)'.tr),
                      selected: _ticketFilter == 'paid',
                      selectedColor: AppTheme.successGreen.withValues(alpha: 0.25),
                      onSelected: (_) => setState(() => _ticketFilter = 'paid'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 6),

            // Tickets ListView
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Text('Aucun ticket ne correspond au filtre.'.tr, style: const TextStyle(color: AppTheme.textHint)),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final t = filtered[index];
                        final isUnpaid = unpaidTicketIds.contains(t.id);
                        final isCancelled = t.status == TicketStatus.annule || t.status == TicketStatus.efface;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: isUnpaid ? 3 : 1.5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: isUnpaid
                                ? BorderSide(color: AppTheme.warningOrange.withValues(alpha: 0.6), width: 1.5)
                                : BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.2)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(14.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Top Row: Ticket Number Badge & Status Pill
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: AppTheme.accentCyan.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        'Ticket ${t.ticketNumber}',
                                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.accentCyan),
                                      ),
                                    ),

                                    // Status Pill
                                    if (isCancelled)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: AppTheme.textHint.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          'Annulé'.tr,
                                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textHint),
                                        ),
                                      )
                                    else if (isUnpaid)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: AppTheme.warningOrange.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(color: AppTheme.warningOrange.withValues(alpha: 0.4)),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(Icons.warning_amber_rounded, size: 12, color: AppTheme.warningOrange),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Solde non réglé'.tr,
                                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.warningOrange),
                                            ),
                                          ],
                                        ),
                                      )
                                    else
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: AppTheme.successGreen.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(Icons.check_circle_outline, size: 12, color: AppTheme.successGreen),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Réglé / Archivé'.tr,
                                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.successGreen),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 10),

                                // Vehicle Plate & Service Name
                                Row(
                                  children: [
                                    Icon(
                                      t.operationType == 'moquette' ? Icons.layers : Icons.directions_car,
                                      color: isCancelled ? AppTheme.textHint : AppTheme.accentCyan,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        (t.vehiclePlate != null && t.vehiclePlate!.isNotEmpty) ? t.vehiclePlate! : 'Moquette'.tr,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          decoration: isCancelled ? TextDecoration.lineThrough : null,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (t.serviceName != null && t.serviceName!.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    t.serviceName!,
                                    style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurfaceVariant),
                                  ),
                                ],
                                const Divider(height: 16),

                                // Footer Row: Date/Time & Price
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.access_time, size: 14, color: AppTheme.textHint),
                                        const SizedBox(width: 4),
                                        Text(
                                          DateFormat('dd/MM/yyyy HH:mm').format(t.createdAt),
                                          style: const TextStyle(fontSize: 12, color: AppTheme.textHint),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      currencyFormat.format(t.totalAmount),
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                        color: isCancelled
                                            ? AppTheme.textHint
                                            : (isUnpaid ? AppTheme.errorRed : AppTheme.successGreen),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
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

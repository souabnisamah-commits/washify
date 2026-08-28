import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:washify/core/localization/app_localizations.dart';
import 'package:washify/core/theme/app_theme.dart';
import 'package:washify/features/clients/models/client.dart';
import 'package:washify/features/clients/models/client_payment.dart';
import 'package:washify/features/clients/models/client_vehicle.dart';
import 'package:washify/features/clients/utils/b2b_pdf_generator.dart';
import 'package:washify/features/services/models/vehicle_category.dart';
import 'package:washify/features/tickets/components/vehicle_info_input.dart';
import 'package:washify/features/tickets/models/ticket.dart';
import 'package:washify/providers/auth_provider.dart';
import 'package:washify/providers/station_provider.dart';
import 'package:washify/providers/vehicle_category_provider.dart';
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

  int _getTicketCountForVehicle(String vehiclePlate, List<Ticket> tickets) {
    final cleanPlate = vehiclePlate.replaceAll(' ', '').toUpperCase();
    if (cleanPlate.isEmpty) return 0;
    return tickets.where((t) {
      if (t.status == TicketStatus.annule || t.status == TicketStatus.efface) return false;
      final tPlate = (t.vehiclePlate ?? '').replaceAll(' ', '').toUpperCase();
      return tPlate == cleanPlate;
    }).length;
  }

  void _showAddVehicleDialog(BuildContext context, Client client) {
    String newPlate = '';
    String newBrand = '';
    String newModel = '';
    String newCategoryId = '';

    final user = ref.read(currentUserProvider);
    if (user == null) return;

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.add_circle_outline, color: AppTheme.accentCyan),
              const SizedBox(width: 8),
              Text('Ajouter un Véhicule'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: SingleChildScrollView(
            child: VehicleInfoInput(
              onChanged: (plate, brand, model) {
                newPlate = plate.trim().toUpperCase();
                newBrand = brand.trim();
                newModel = model.trim();
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Annuler'.tr),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentCyan, foregroundColor: Colors.white),
              onPressed: () async {
                if (newPlate.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Veuillez saisir une immatriculation valide.'.tr)),
                  );
                  return;
                }
                if (client.vehicles.any((v) => v.plate.replaceAll(' ', '').toUpperCase() == newPlate.replaceAll(' ', '').toUpperCase())) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Ce véhicule existe déjà dans votre flotte.'.tr)),
                  );
                  return;
                }

                final updatedVehicles = List<ClientVehicle>.from(client.vehicles);
                updatedVehicles.add(ClientVehicle(
                  plate: newPlate,
                  brand: newBrand,
                  model: newModel,
                  categoryId: newCategoryId,
                ));

                final updatedClient = client.copyWith(
                  vehicles: updatedVehicles,
                  updatedAt: DateTime.now(),
                );

                await ref.read(clientRepositoryProvider).updateClient(updatedClient);

                if (context.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Véhicule $newPlate ajouté à votre flotte.'.tr),
                      backgroundColor: AppTheme.successGreen,
                    ),
                  );
                }
              },
              child: Text('Ajouter au parc'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _showEditVehicleDialog(BuildContext context, Client client, ClientVehicle vehicle, int index, int ticketCount) {
    if (ticketCount > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Impossible de modifier le véhicule ${vehicle.plate} car il possède $ticketCount ticket(s) rattaché(s).'.tr),
          backgroundColor: AppTheme.warningOrange,
          duration: const Duration(seconds: 4),
        ),
      );
      return;
    }

    String newPlate = vehicle.plate;
    String newBrand = vehicle.brand;
    String newModel = vehicle.model;
    String newCategoryId = vehicle.categoryId;

    final user = ref.read(currentUserProvider);
    if (user == null) return;

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.edit_note, color: AppTheme.accentCyan),
              const SizedBox(width: 8),
              Text('Modifier le Véhicule'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: SingleChildScrollView(
            child: VehicleInfoInput(
              initialPlate: newPlate,
              initialBrand: newBrand,
              initialModel: newModel,
              onChanged: (plate, brand, model) {
                newPlate = plate.trim().toUpperCase();
                newBrand = brand.trim();
                newModel = model.trim();
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Annuler'.tr),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentCyan, foregroundColor: Colors.white),
              onPressed: () async {
                if (newPlate.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Veuillez saisir une immatriculation valide.'.tr)),
                  );
                  return;
                }

                final updatedVehicles = List<ClientVehicle>.from(client.vehicles);

                if (newPlate != vehicle.plate &&
                    updatedVehicles.any((v) => v.plate.replaceAll(' ', '').toUpperCase() == newPlate.replaceAll(' ', '').toUpperCase())) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Un autre véhicule possède déjà cette immatriculation.'.tr)),
                  );
                  return;
                }

                updatedVehicles[index] = ClientVehicle(
                  plate: newPlate,
                  brand: newBrand,
                  model: newModel,
                  categoryId: newCategoryId,
                );

                final updatedClient = client.copyWith(
                  vehicles: updatedVehicles,
                  updatedAt: DateTime.now(),
                );

                await ref.read(clientRepositoryProvider).updateClient(updatedClient);

                if (context.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Véhicule mis à jour.'.tr),
                      backgroundColor: AppTheme.successGreen,
                    ),
                  );
                }
              },
              child: Text('Enregistrer'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteVehicleDialog(BuildContext context, Client client, ClientVehicle vehicle, int index, int ticketCount) async {
    if (ticketCount > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Impossible de supprimer le véhicule ${vehicle.plate} car il possède $ticketCount ticket(s) rattaché(s).'.tr),
          backgroundColor: AppTheme.warningOrange,
          duration: const Duration(seconds: 4),
        ),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: AppTheme.errorRed),
            const SizedBox(width: 8),
            Text('Supprimer du parc ?'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text('Voulez-vous vraiment retirer le véhicule ${vehicle.plate} de votre flotte B2B ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Annuler'.tr)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorRed, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Supprimer'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final updatedVehicles = List<ClientVehicle>.from(client.vehicles);
    updatedVehicles.removeAt(index);

    final updatedClient = client.copyWith(
      vehicles: updatedVehicles,
      updatedAt: DateTime.now(),
    );

    await ref.read(clientRepositoryProvider).updateClient(updatedClient);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Véhicule ${vehicle.plate} retiré de la flotte.'.tr)),
      );
    }
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
              tooltip: 'Se déconnecter'.tr,
              onPressed: _logout,
            ),
          ],
          bottom: TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: AppTheme.accentCyan,
            tabs: [
              Tab(
                icon: const Icon(Icons.receipt_long_outlined, size: 20),
                text: 'Tickets & Conso'.tr,
              ),
              Tab(
                icon: const Icon(Icons.history_outlined, size: 20),
                text: 'Historique Paiements'.tr,
              ),
              Tab(
                icon: const Icon(Icons.directions_car_outlined, size: 20),
                text: 'Flotte Véhicules'.tr,
              ),
            ],
          ),
        ),
        body: clientAsync.when(
          data: (client) {
            if (client == null) {
              return Center(child: Text('Compte B2B introuvable.'.tr));
            }
            return TabBarView(
              children: [
                _buildTicketsTab(context, client),
                _buildPaymentsTab(context, client),
                _buildVehiclesTab(context, client),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => Center(child: Text('Erreur: $e'.tr)),
        ),
      ),
    );
  }

  Widget _buildTicketsTab(BuildContext context, Client client) {
    final ticketsAsync = ref.watch(b2bClientTicketsProvider(client.id));

    return ticketsAsync.when(
      data: (tickets) {
        // Filter out cancelled/deleted tickets for financial calculations
        final validTickets = tickets.where((t) => t.status != TicketStatus.annule && t.status != TicketStatus.efface).toList();

        final unpaidTickets = validTickets.where((t) => t.status == TicketStatus.enAttente || t.paymentMethod == 'compte_client').toList();
        final paidTickets = validTickets.where((t) => t.status == TicketStatus.paye && t.paymentMethod != 'compte_client').toList();

        final List<Ticket> filteredTickets;
        if (_ticketFilter == 'unpaid') {
          filteredTickets = unpaidTickets;
        } else if (_ticketFilter == 'paid') {
          filteredTickets = paidTickets;
        } else {
          filteredTickets = validTickets;
        }

        final isOverThreshold = client.alertThreshold > 0 && client.currentBalance >= client.alertThreshold;

        return Column(
          children: [
            // Solde & Alert Threshold Banner
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isOverThreshold
                      ? [const Color(0xFFD32F2F), const Color(0xFFC62828)]
                      : [AppTheme.primaryBlue, const Color(0xFF1976D2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: (isOverThreshold ? Colors.red : AppTheme.primaryBlue).withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Solde encours (À Régler)'.tr,
                            style: const TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            currencyFormat.format(client.currentBalance),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      if (client.alertThreshold > 0)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Plafond autorisé'.tr,
                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: isOverThreshold
                                    ? Colors.white
                                    : Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                currencyFormat.format(client.alertThreshold),
                                style: TextStyle(
                                  color: isOverThreshold ? AppTheme.errorRed : Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  if (isOverThreshold) ...[
                    const Divider(color: Colors.white30, height: 20),
                    Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Attention : Vous avez atteint votre plafond d\'encours autorisé.'.tr,
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // Export PDF & Filter Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Filter Chips
                  Row(
                    children: [
                      FilterChip(
                        label: Text('Tous (${validTickets.length})'.tr),
                        selected: _ticketFilter == 'all',
                        onSelected: (val) => setState(() => _ticketFilter = 'all'),
                        selectedColor: AppTheme.accentCyan.withValues(alpha: 0.2),
                        checkmarkColor: AppTheme.accentCyan,
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: Text('À régler'.tr),
                        selected: _ticketFilter == 'unpaid',
                        onSelected: (val) => setState(() => _ticketFilter = 'unpaid'),
                        selectedColor: AppTheme.errorRed.withValues(alpha: 0.2),
                        checkmarkColor: AppTheme.errorRed,
                      ),
                    ],
                  ),
                  // PDF Export Button
                  ElevatedButton.icon(
                    onPressed: () => _exportPdf(client, validTickets),
                    icon: const Icon(Icons.picture_as_pdf, size: 18),
                    label: Text('Relevé PDF'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentCyan,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Tickets List
            Expanded(
              child: filteredTickets.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.receipt_long_outlined, size: 48, color: AppTheme.textHint),
                          const SizedBox(height: 12),
                          Text('Aucun ticket trouvé.'.tr, style: const TextStyle(color: AppTheme.textHint)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: filteredTickets.length,
                      itemBuilder: (context, index) {
                        final t = filteredTickets[index];
                        final isUnpaid = t.status == TicketStatus.enAttente || t.paymentMethod == 'compte_client';
                        final isCancelled = t.status == TicketStatus.annule || t.status == TicketStatus.efface;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          elevation: 1.5,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Ticket Number & Plate
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            '#${t.ticketNumber}',
                                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          t.vehiclePlate ?? '',
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                        ),
                                      ],
                                    ),

                                    // Status Badge
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: isCancelled
                                            ? Colors.grey.withValues(alpha: 0.2)
                                            : (isUnpaid ? AppTheme.errorRed.withValues(alpha: 0.15) : AppTheme.successGreen.withValues(alpha: 0.15)),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        isCancelled
                                            ? 'Annulé'.tr
                                            : (isUnpaid ? 'Compte B2B'.tr : 'Réglé'.tr),
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: isCancelled
                                              ? AppTheme.textHint
                                              : (isUnpaid ? AppTheme.errorRed : AppTheme.successGreen),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),

                                // Vehicle Details (Brand, Model, Category)
                                if (t.vehicleBrand != null && t.vehicleBrand!.isNotEmpty) ...[
                                  Text(
                                    '${t.vehicleBrand} ${t.vehicleModel ?? ''} (${t.vehicleType})'.trim(),
                                    style: const TextStyle(fontSize: 13, color: AppTheme.textHint),
                                  ),
                                ],

                                // Service Name
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
    final user = ref.watch(currentUserProvider);
    final ticketsAsync = ref.watch(b2bClientTicketsProvider(client.id));
    final tickets = ticketsAsync.value ?? [];

    return Column(
      children: [
        // Header Banner with Fleet count & Add button
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.accentCyan.withValues(alpha: 0.3)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.directions_car, color: AppTheme.accentCyan, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    '${client.vehicles.length} véhicule(s) dans la flotte'.tr,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ],
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentCyan,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () => _showAddVehicleDialog(context, client),
                icon: const Icon(Icons.add, size: 18),
                label: Text('Ajouter Véhicule'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),

        if (client.vehicles.isEmpty)
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.directions_car_outlined, size: 48, color: AppTheme.textHint),
                  const SizedBox(height: 12),
                  Text('Aucun véhicule enregistré dans votre flotte B2B.'.tr, style: const TextStyle(color: AppTheme.textHint)),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentCyan, foregroundColor: Colors.white),
                    onPressed: () => _showAddVehicleDialog(context, client),
                    icon: const Icon(Icons.add),
                    label: Text('Ajouter votre premier véhicule'.tr),
                  ),
                ],
              ),
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: client.vehicles.length,
              itemBuilder: (context, index) {
                final v = client.vehicles[index];
                final ticketCount = _getTicketCountForVehicle(v.plate, tickets);
                final isLocked = ticketCount > 0;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 1.5,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: isLocked
                              ? AppTheme.warningOrange.withValues(alpha: 0.15)
                              : AppTheme.accentCyan.withValues(alpha: 0.15),
                          child: Icon(
                            Icons.directions_car_filled,
                            color: isLocked ? AppTheme.warningOrange : AppTheme.accentCyan,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    v.plate,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  const SizedBox(width: 8),
                                  // Status Badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: isLocked
                                          ? AppTheme.warningOrange.withValues(alpha: 0.15)
                                          : AppTheme.successGreen.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          isLocked ? Icons.lock : Icons.check_circle,
                                          size: 12,
                                          color: isLocked ? AppTheme.warningOrange : AppTheme.successGreen,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          isLocked
                                              ? 'Attaché à $ticketCount ticket(s)'.tr
                                              : 'Libre (Modifiable)'.tr,
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: isLocked ? AppTheme.warningOrange : AppTheme.successGreen,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                (v.brand.isNotEmpty || v.model.isNotEmpty)
                                    ? '${v.brand} ${v.model}'.trim()
                                    : 'Marque/Modèle non spécifié'.tr,
                                style: const TextStyle(fontSize: 13, color: AppTheme.textHint),
                              ),
                              const SizedBox(height: 2),
                              if (v.categoryId.isNotEmpty && user?.tenantId != null)
                                Consumer(
                                  builder: (context, ref, child) {
                                    final catAsync = ref.watch(vehicleCategoriesStreamProvider(user!.tenantId));
                                    final catList = catAsync.value ?? [];
                                    final cat = catList.where((c) => c.id == v.categoryId).firstOrNull;
                                    final catName = cat?.name ?? '';
                                    if (catName.isEmpty) return const SizedBox();
                                    return Text(
                                      'Catégorie : $catName'.tr,
                                      style: const TextStyle(fontSize: 11, color: AppTheme.primaryBlue, fontWeight: FontWeight.bold),
                                    );
                                  },
                                )
                              else
                                Text(
                                  'ℹ️ Catégorie attribuée lors du premier lavage'.tr,
                                  style: const TextStyle(fontSize: 10, color: AppTheme.textHint, fontStyle: FontStyle.italic),
                                ),
                            ],
                          ),
                        ),

                        // Action Buttons: Edit ✏️ and Delete 🗑️
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.edit_outlined,
                                color: isLocked ? Colors.grey.shade400 : AppTheme.primaryBlue,
                              ),
                              tooltip: isLocked
                                  ? 'Modification verrouillée (véhicule déjà attaché à des tickets)'
                                  : 'Modifier ce véhicule',
                              onPressed: () => _showEditVehicleDialog(context, client, v, index, ticketCount),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.delete_outline,
                                color: isLocked ? Colors.grey.shade400 : AppTheme.errorRed,
                              ),
                              tooltip: isLocked
                                  ? 'Suppression verrouillée (véhicule déjà attaché à des tickets)'
                                  : 'Supprimer ce véhicule',
                              onPressed: () => _showDeleteVehicleDialog(context, client, v, index, ticketCount),
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
  }
}

import 'package:flutter/material.dart';
import 'package:washify/core/localization/app_localizations.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:washify/core/theme/app_theme.dart';
import 'package:washify/core/constants/user_roles.dart';
import 'package:washify/features/clients/models/client.dart';
import 'package:washify/features/clients/models/client_payment.dart';
import 'package:washify/features/clients/models/client_vehicle.dart';

import 'package:washify/features/tickets/components/vehicle_info_input.dart';
import 'package:washify/features/tickets/models/ticket.dart';
import 'package:washify/providers/auth_provider.dart';
import 'package:washify/providers/station_provider.dart';
import 'package:washify/providers/vehicle_category_provider.dart';
import 'package:washify/repositories/client_repository.dart';
import 'package:washify/repositories/ticket_repository.dart';
import 'package:printing/printing.dart';
import 'package:washify/features/clients/utils/b2b_pdf_generator.dart';

// Riverpod Provider for Client Tickets
final clientTicketsProvider = StreamProvider.family<List<Ticket>, String>((ref, clientId) {
  final user = ref.watch(currentUserProvider);
  if (user == null || user.stationId == null) return Stream.empty();
  return ref.watch(ticketRepositoryProvider).watchClientTickets(user.stationId!, clientId);
});

class ClientDetailsScreen extends ConsumerStatefulWidget {
  final Client client;
  const ClientDetailsScreen({super.key, required this.client});

  @override
  ConsumerState<ClientDetailsScreen> createState() => _ClientDetailsScreenState();
}

class _ClientDetailsScreenState extends ConsumerState<ClientDetailsScreen> {
  final currencyFormat = NumberFormat.currency(locale: 'fr_FR', symbol: 'DT');
  late Client _currentClient;

  @override
  void initState() {
    super.initState();
    _currentClient = widget.client;
  }

  void _showPaymentDialog() {
    final formKey = GlobalKey<FormState>();
    double amount = _currentClient.currentBalance;
    String paymentMethod = 'Espèces';
    String reference = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Régler la facture', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Solde actuel: ${currencyFormat.format(_currentClient.currentBalance)}',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.errorRed),
                ),
                SizedBox(height: 16),
                TextFormField(
                  initialValue: amount.toStringAsFixed(3),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(labelText: 'Montant à payer (DT)'.tr),
                  validator: (v) {
                    if (v == null || double.tryParse(v) == null) return 'Invalide';
                    final parsed = double.parse(v);
                    if (parsed > _currentClient.currentBalance) {
                      return 'Max: ${currencyFormat.format(_currentClient.currentBalance)}';
                    }
                    if (parsed <= 0) return 'Doit être > 0';
                    return null;
                  },
                  onSaved: (v) => amount = double.parse(v!),
                ),
                SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: paymentMethod,
                  decoration: InputDecoration(labelText: 'Mode de paiement'.tr),
                  items: ['Espèces', 'Chèque', 'Virement', 'TPE'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (v) => paymentMethod = v!,
                ),
                SizedBox(height: 12),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Référence (N° Chèque...)'.tr),
                  onSaved: (v) => reference = v ?? '',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('Annuler'.tr)),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  formKey.currentState!.save();
                  final user = ref.read(currentUserProvider);
                  if (user == null) return;

                  final payment = ClientPayment(
                    id: '',
                    clientId: _currentClient.id,
                    tenantId: user.stationId!,
                    amount: amount,
                    paymentMethod: paymentMethod,
                    reference: reference.isEmpty ? null : reference,
                    createdBy: user.name,
                    paymentDate: DateTime.now(),
                  );

                  await ref.read(clientRepositoryProvider).addPayment(payment);
                  if (context.mounted) Navigator.of(context).pop();
                }
              },
              child: Text('Marquer comme payé'.tr),
            ),
          ],
        );
      },
    );
  }

  void _showEditClientDialog() {
    final formKey = GlobalKey<FormState>();
    String companyName = _currentClient.companyName;
    String contactName = _currentClient.contactName;
    String taxId = _currentClient.taxId;
    String phone = _currentClient.phone;
    String thresholdStr = _currentClient.alertThreshold.toStringAsFixed(0);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Modifier le Client', style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    initialValue: companyName,
                    decoration: InputDecoration(labelText: 'Nom de la Société (ou Client) *'.tr, prefixIcon: Icon(Icons.business)),
                    validator: (v) => v == null || v.isEmpty ? 'Requis' : null,
                    onSaved: (v) => companyName = v!,
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    initialValue: contactName,
                    decoration: InputDecoration(labelText: 'Nom du Responsable'.tr, prefixIcon: Icon(Icons.person)),
                    onSaved: (v) => contactName = v ?? '',
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    initialValue: taxId,
                    decoration: InputDecoration(labelText: 'Matricule Fiscale'.tr, prefixIcon: Icon(Icons.receipt)),
                    onSaved: (v) => taxId = v ?? '',
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    initialValue: phone,
                    decoration: InputDecoration(labelText: 'Téléphone'.tr, prefixIcon: Icon(Icons.phone)),
                    keyboardType: TextInputType.phone,
                    onSaved: (v) => phone = v ?? '',
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    initialValue: thresholdStr,
                    decoration: InputDecoration(labelText: 'Seuil d\'.tralerte (DT)', prefixIcon: Icon(Icons.warning)),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) => v == null || double.tryParse(v) == null ? 'Invalide' : null,
                    onSaved: (v) => thresholdStr = v!,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Annuler'.tr),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  formKey.currentState!.save();
                  final updatedClient = _currentClient.copyWith(
                    companyName: companyName,
                    contactName: contactName,
                    taxId: taxId,
                    phone: phone,
                    alertThreshold: double.parse(thresholdStr),
                    updatedAt: DateTime.now(),
                  );

                  await ref.read(clientRepositoryProvider).updateClient(updatedClient);
                  if (context.mounted) {
                    setState(() {
                      _currentClient = updatedClient;
                    });
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Client mis à jour.'.tr)));
                  }
                }
              },
              child: Text('Sauvegarder'.tr),
            ),
          ],
        );
      },
    );
  }

  void _deleteClient() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Supprimer ce client ?'.tr),
        content: Text('Cette action est irréversible. Impossible de supprimer s\'il y a un historique de tickets ou paiements.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Annuler'.tr)),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Supprimer', style: TextStyle(color: AppTheme.errorRed)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final repo = ref.read(clientRepositoryProvider);
    final canDelete = await repo.canDeleteClient(_currentClient.id);

    if (!canDelete) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Impossible de supprimer: Historique existant.'.tr),
          backgroundColor: AppTheme.errorRed,
        ));
      }
      return;
    }

    await repo.deleteClient(_currentClient.id);
    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Client supprimé avec succès.'.tr)));
    }
  }

  Future<void> _exportUnpaidBalance() async {
    showDialog(context: context, barrierDismissible: false, builder: (_) => Center(child: CircularProgressIndicator()));
    try {
      final user = ref.read(currentUserProvider);
      if (user == null || user.stationId == null) throw Exception('Utilisateur non connecté');

      final allTickets = await ref.read(ticketRepositoryProvider).getClientTickets(user.stationId!, _currentClient.id);
      
      // We take the validated tickets charged to the account, newest first (since they are sorted by date desc)
      final accountTickets = allTickets.where((t) => t.paymentMethod == 'compte_client' && t.status == TicketStatus.paye).toList();
      
      final List<Ticket> unpaidTickets = [];
      double remainingBalance = _currentClient.currentBalance;

      // FIFO matching: The current balance is composed of the most recent unpaid tickets.
      for (final ticket in accountTickets) {
        if (remainingBalance <= 0.01) break; // using 0.01 to avoid floating point precision issues
        unpaidTickets.add(ticket);
        remainingBalance -= ticket.montant;
      }

      final station = ref.read(selectedStationProvider);
      if (station == null) throw Exception('Station non trouvée');

      final pdfBytes = await B2BPdfGenerator.generateUnpaidBalanceReport(
        station: station,
        client: _currentClient,
        unpaidTickets: unpaidTickets,
      );

      if (context.mounted) Navigator.pop(context);
      await Printing.sharePdf(bytes: pdfBytes, filename: 'releve_solde_${_currentClient.companyName.replaceAll(' ', '_')}.pdf');
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
      }
    }
  }

  Future<void> _exportPaymentHistory() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primaryBlue,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked == null) return;

    showDialog(context: context, barrierDismissible: false, builder: (_) => Center(child: CircularProgressIndicator()));
    try {
      final user = ref.read(currentUserProvider);
      if (user == null || user.stationId == null) throw Exception('Utilisateur non connecté');

      final start = picked.start;
      final end = DateTime(picked.end.year, picked.end.month, picked.end.day, 23, 59, 59);

      final allPayments = await ref.read(clientRepositoryProvider).getClientPayments(_currentClient.id);
      final filteredPayments = allPayments.where((p) => p.paymentDate.isAfter(start) && p.paymentDate.isBefore(end)).toList();

      final allTickets = await ref.read(ticketRepositoryProvider).getClientTickets(user.stationId!, _currentClient.id);
      final consumedTickets = allTickets.where((t) => t.createdAt.isAfter(start) && t.createdAt.isBefore(end)).toList();

      final station = ref.read(selectedStationProvider);
      if (station == null) throw Exception('Station non trouvée');

      final pdfBytes = await B2BPdfGenerator.generatePaymentHistoryReport(
        station: station,
        client: _currentClient,
        startDate: start,
        endDate: end,
        payments: filteredPayments,
        consumedTickets: consumedTickets,
      );

      if (context.mounted) Navigator.pop(context);
      await Printing.sharePdf(bytes: pdfBytes, filename: 'historique_${_currentClient.companyName.replaceAll(' ', '_')}.pdf');
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: Text(_currentClient.companyName, style: TextStyle(color: Colors.white)),
          backgroundColor: AppTheme.primaryBlue,
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: _showEditClientDialog,
            ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: _deleteClient,
            ),
          ],
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: 'Tickets'),
              Tab(text: 'Paiements'),
              Tab(text: 'Véhicules'),
            ],
          ),
        ),
        body: Column(
          children: [
            Container(
              color: Colors.white,
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Solde Restant', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                      Text(
                        currencyFormat.format(_currentClient.currentBalance),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: _currentClient.currentBalance > 0 ? AppTheme.errorRed : AppTheme.successGreen,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      if (_currentClient.currentBalance > 0)
                        ElevatedButton.icon(
                          onPressed: _showPaymentDialog,
                          icon: Icon(Icons.payment),
                          label: Text('Régler'.tr),
                          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.successGreen),
                        ),
                      SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: _exportUnpaidBalance,
                        icon: Icon(Icons.picture_as_pdf),
                        label: Text('Détail Solde'.tr),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppTheme.primaryBlue,
                          side: BorderSide(color: AppTheme.primaryBlue),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildTicketsTab(ref),
                  _buildPaymentsTab(ref),
                  _buildVehiclesTab(ref),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketsTab(WidgetRef ref) {
    final ticketsAsync = ref.watch(clientTicketsProvider(_currentClient.id));
    return ticketsAsync.when(
      data: (tickets) {
        if (tickets.isEmpty) return Center(child: Text('Aucun ticket'.tr));
        return ListView.builder(
          itemCount: tickets.length,
          itemBuilder: (context, index) {
            final t = tickets[index];
            return Card(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                title: Text('${t.vehiclePlate} - ${t.serviceName}'),
                subtitle: Text(DateFormat('dd/MM/yyyy HH:mm').format(t.createdAt)),
                trailing: Text(currencyFormat.format(t.montant), style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            );
          },
        );
      },
      loading: () => Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Erreur: $e'.tr)),
    );
  }

  Widget _buildPaymentsTab(WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final isPatron = user != null && user.roles.contains(UserRole.patron);
    final paymentsAsync = ref.watch(clientPaymentsStreamProvider(_currentClient.id));
    return Column(
      children: [
        if (isPatron)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: _exportPaymentHistory,
                  icon: Icon(Icons.picture_as_pdf),
                  label: Text('Exporter Historique'.tr),
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentTeal),
                ),
              ],
            ),
          ),
        Expanded(
          child: paymentsAsync.when(
            data: (payments) {
              if (payments.isEmpty) return Center(child: Text('Aucun paiement'.tr));
        return ListView.builder(
          itemCount: payments.length,
          itemBuilder: (context, index) {
            final p = payments[index];
            return Card(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: Icon(Icons.check_circle, color: AppTheme.successGreen),
                title: Text('Paiement: ${p.paymentMethod}'.tr),
                subtitle: Text('${DateFormat('dd/MM/yyyy HH:mm').format(p.paymentDate)}\nPar: ${p.createdBy}${p.reference != null ? ' - Réf: ${p.reference}' : ''}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(currencyFormat.format(p.amount), style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.successGreen)),
                    if (isPatron) ...[
                      SizedBox(width: 8),
                      IconButton(
                        icon: Icon(Icons.delete, color: AppTheme.errorRed),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: Text('Supprimer ce paiement ?'),
                              content: Text('Le solde du client sera recrédité de ${currencyFormat.format(p.amount)}.'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Annuler')),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorRed),
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: Text('Supprimer', style: TextStyle(color: Colors.white)),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            try {
                              await ref.read(clientRepositoryProvider).deletePayment(p);
                              if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Paiement supprimé.')));
                            } catch (e) {
                              if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
                            }
                          }
                        },
                      ),
                    ],
                  ],
                ),
                isThreeLine: true,
              ),
            );
          },
        );
      },
      loading: () => Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Erreur: $e'.tr)),
    ))]);
  }

  Widget _buildVehiclesTab(WidgetRef ref) {
    final vehicles = _currentClient.vehicles;
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '${vehicles.length} véhicule(s) enregistré(s)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              ElevatedButton.icon(
                onPressed: _showAddVehicleDialog,
                icon: Icon(Icons.add),
                label: Text('Ajouter'.tr),
              ),
            ],
          ),
        ),
        if (vehicles.isEmpty)
          Expanded(child: Center(child: Text('Aucun véhicule enregistré.'.tr)))
        else
          Expanded(
            child: ListView.builder(
              itemCount: vehicles.length,
              itemBuilder: (context, index) {
                final vehicle = vehicles[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: ListTile(
                    leading: Icon(Icons.directions_car, color: AppTheme.primaryBlue),
                    title: Text(vehicle.plate, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    subtitle: vehicle.brand.isNotEmpty || vehicle.model.isNotEmpty 
                        ? Text('${vehicle.brand} ${vehicle.model}'.trim(), style: TextStyle(color: AppTheme.textHint))
                        : null,
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: AppTheme.errorRed),
                      onPressed: () => _deleteVehicle(index),
                    ),
                    onTap: () => _showEditVehicleDialog(vehicle, index),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  void _showAddVehicleDialog() {
    final formKey = GlobalKey<FormState>();
    String newPlate = '';
    String newBrand = '';
    String newModel = '';
    String newCategoryId = '';
    
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Ajouter un Véhicule'.tr),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  VehicleInfoInput(
                    onChanged: (plate, brand, model) {
                      newPlate = plate.trim().toUpperCase();
                      newBrand = brand.trim();
                      newModel = model.trim();
                    },
                  ),
                  SizedBox(height: 16),
                  Consumer(
                    builder: (context, ref, child) {
                      final categoriesAsync = ref.watch(vehicleCategoriesStreamProvider(user.tenantId));
                      return categoriesAsync.when(
                        data: (categories) {
                          if (categories.isEmpty) return SizedBox();
                          return DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: 'Catégorie de véhicule'.tr,
                              prefixIcon: Icon(Icons.category, color: AppTheme.primaryBlue),
                            ),
                            initialValue: newCategoryId.isEmpty ? null : newCategoryId,
                            items: categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                            onChanged: (val) {
                              if (val != null) newCategoryId = val;
                            },
                          );
                        },
                        loading: () => CircularProgressIndicator(),
                        error: (e, s) => Text('Erreur: $e'.tr),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Annuler'.tr),
            ),
            ElevatedButton(
              onPressed: () async {
                if (newPlate.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Veuillez saisir une plaque valide.'.tr)));
                  return;
                }
                if (_currentClient.vehicles.any((v) => v.plate == newPlate)) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Véhicule déjà enregistré pour ce client.'.tr)));
                  return;
                }

                final updatedVehicles = List<ClientVehicle>.from(_currentClient.vehicles);
                updatedVehicles.add(ClientVehicle(plate: newPlate, brand: newBrand, model: newModel, categoryId: newCategoryId));
                final updatedClient = _currentClient.copyWith(
                  vehicles: updatedVehicles,
                  updatedAt: DateTime.now(),
                );
                await ref.read(clientRepositoryProvider).updateClient(updatedClient);
                if (context.mounted) {
                  setState(() {
                    _currentClient = updatedClient;
                  });
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Véhicule ajouté.'.tr)));
                }
              },
              child: Text('Ajouter'.tr),
            ),
          ],
        );
      },
    );
  }

  void _showEditVehicleDialog(ClientVehicle vehicle, int index) {
    final formKey = GlobalKey<FormState>();
    String newPlate = vehicle.plate;
    String newBrand = vehicle.brand;
    String newModel = vehicle.model;
    String newCategoryId = vehicle.categoryId;

    final user = ref.read(currentUserProvider);
    if (user == null) return;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Modifier un Véhicule'.tr),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  VehicleInfoInput(
                    initialPlate: newPlate,
                    initialBrand: newBrand,
                    initialModel: newModel,
                    onChanged: (plate, brand, model) {
                      newPlate = plate.trim().toUpperCase();
                      newBrand = brand.trim();
                      newModel = model.trim();
                    },
                  ),
                  SizedBox(height: 16),
                  Consumer(
                    builder: (context, ref, child) {
                      final categoriesAsync = ref.watch(vehicleCategoriesStreamProvider(user.tenantId));
                      return categoriesAsync.when(
                        data: (categories) {
                          if (categories.isEmpty) return SizedBox();
                          // Verify newCategoryId exists in categories list
                          if (newCategoryId.isNotEmpty && !categories.any((c) => c.id == newCategoryId)) {
                            newCategoryId = ''; // Reset if invalid
                          }
                          return DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: 'Catégorie de véhicule'.tr,
                              prefixIcon: Icon(Icons.category, color: AppTheme.primaryBlue),
                            ),
                            initialValue: newCategoryId.isEmpty ? null : newCategoryId,
                            items: categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                            onChanged: (val) {
                              if (val != null) newCategoryId = val;
                            },
                          );
                        },
                        loading: () => CircularProgressIndicator(),
                        error: (e, s) => Text('Erreur: $e'.tr),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Annuler'.tr),
            ),
            ElevatedButton(
              onPressed: () async {
                if (newPlate.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Veuillez saisir une plaque valide.'.tr)));
                  return;
                }
                
                final updatedVehicles = List<ClientVehicle>.from(_currentClient.vehicles);
                
                // If plate changed, ensure the new plate doesn't already exist elsewhere
                if (newPlate != vehicle.plate && updatedVehicles.any((v) => v.plate == newPlate)) {
                  if (mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Véhicule déjà enregistré.'.tr)));
                  }
                  return;
                }

                updatedVehicles[index] = ClientVehicle(plate: newPlate, brand: newBrand, model: newModel, categoryId: newCategoryId);
                final updatedClient = _currentClient.copyWith(
                  vehicles: updatedVehicles,
                  updatedAt: DateTime.now(),
                );
                await ref.read(clientRepositoryProvider).updateClient(updatedClient);
                if (context.mounted) {
                  setState(() {
                    _currentClient = updatedClient;
                  });
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Véhicule modifié.'.tr)));
                }
              },
              child: Text('Sauvegarder'.tr),
            ),
          ],
        );
      },
    );
  }

  void _deleteVehicle(int index) async {
    final vehicle = _currentClient.vehicles[index];
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Supprimer ce véhicule ?'.tr),
        content: Text('Voulez-vous vraiment supprimer le véhicule ${vehicle.plate} ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Annuler'.tr)),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Supprimer', style: TextStyle(color: AppTheme.errorRed)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final updatedVehicles = List<ClientVehicle>.from(_currentClient.vehicles);
    updatedVehicles.removeAt(index);
    
    final updatedClient = _currentClient.copyWith(
      vehicles: updatedVehicles,
      updatedAt: DateTime.now(),
    );
    
    await ref.read(clientRepositoryProvider).updateClient(updatedClient);
    
    if (mounted) {
      setState(() {
        _currentClient = updatedClient;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Véhicule supprimé.'.tr)));
    }
  }
}

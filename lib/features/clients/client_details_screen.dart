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
  String _ticketFilter = 'all'; // 'all', 'unpaid', 'paid'

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

  void _showManageAppAccessDialog() {
    final formKey = GlobalKey<FormState>();
    String password = '';
    bool hasAccess = _currentClient.hasAppAccess;
    String status = _currentClient.accessStatus.isEmpty ? 'active' : _currentClient.accessStatus;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                const Icon(Icons.vpn_key_outlined, color: AppTheme.accentCyan),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Accès App Client B2B'.tr,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Identifiant de connexion (Téléphone) :'.tr, style: const TextStyle(fontSize: 11, color: AppTheme.textHint)),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(Icons.phone, size: 16, color: AppTheme.primaryBlue),
                              const SizedBox(width: 6),
                              Text(
                                _currentClient.phone.isNotEmpty ? _currentClient.phone : 'Non spécifié'.tr,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Switch Enable/Disable Access
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text('Autoriser l\'Accès App'.tr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      subtitle: Text(
                        hasAccess
                            ? 'Le client peut se connecter sur l\'application.'.tr
                            : 'Accès désactivé par le lavoir.'.tr,
                        style: const TextStyle(fontSize: 12),
                      ),
                      value: hasAccess,
                      activeColor: AppTheme.accentCyan,
                      onChanged: (val) {
                        setDialogState(() {
                          hasAccess = val;
                          if (!val) status = 'blocked';
                          else status = 'active';
                        });
                      },
                    ),
                    const Divider(height: 20),

                    // Status Dropdown (Active vs Blocked)
                    if (hasAccess) ...[
                      DropdownButtonFormField<String>(
                        value: status,
                        decoration: InputDecoration(
                          labelText: 'Statut de l\'accès'.tr,
                          prefixIcon: const Icon(Icons.shield_outlined, color: AppTheme.accentCyan),
                        ),
                        items: [
                          DropdownMenuItem(
                            value: 'active',
                            child: Row(
                              children: [
                                const Icon(Icons.check_circle, color: AppTheme.successGreen, size: 18),
                                const SizedBox(width: 8),
                                Text('Autorisé & Actif'.tr),
                              ],
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'blocked',
                            child: Row(
                              children: [
                                const Icon(Icons.block, color: AppTheme.errorRed, size: 18),
                                const SizedBox(width: 8),
                                Text('Bloqué / Suspendu'.tr),
                              ],
                            ),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) setDialogState(() => status = val);
                        },
                      ),
                      const SizedBox(height: 14),
                    ],

                    // Password / PIN field
                    TextFormField(
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Mot de passe / Code PIN'.tr,
                        hintText: 'Laisser vide pour ne pas modifier'.tr,
                        prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.accentCyan),
                      ),
                      validator: (v) {
                        if (hasAccess && _currentClient.accessPasswordHash.isEmpty && (v == null || v.trim().isEmpty)) {
                          return 'Veuillez saisir un mot de passe initial'.tr;
                        }
                        return null;
                      },
                      onSaved: (v) => password = v?.trim() ?? '',
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Annuler'.tr),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    formKey.currentState!.save();
                    final user = ref.read(currentUserProvider);
                    if (user == null || user.stationId == null) return;

                    final isClientActive = hasAccess && status == 'active';

                    await ref.read(clientRepositoryProvider).updateClientAccess(
                      _currentClient.id,
                      hasAppAccess: hasAccess,
                      accessStatus: status,
                      password: password,
                    );

                    await ref.read(authRepositoryProvider).syncB2BUserAccount(
                      clientId: _currentClient.id,
                      stationId: user.stationId!,
                      companyName: _currentClient.companyName,
                      phone: _currentClient.phone,
                      password: password,
                      isActive: isClientActive,
                    );

                    final updated = _currentClient.copyWith(
                      hasAppAccess: hasAccess,
                      accessStatus: status,
                      accessPasswordHash: password.isNotEmpty ? password : _currentClient.accessPasswordHash,
                    );

                    if (context.mounted) {
                      setState(() {
                        _currentClient = updated;
                      });
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Accès App Client B2B mis à jour avec succès.'.tr),
                          backgroundColor: AppTheme.successGreen,
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentCyan, foregroundColor: Colors.white),
                child: Text('Enregistrer'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      },
    );
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
        appBar: AppBar(
          title: Text(_currentClient.companyName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          backgroundColor: AppTheme.primaryBlue,
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            IconButton(
              icon: Icon(
                _currentClient.hasAppAccess && _currentClient.accessStatus == 'active'
                    ? Icons.vpn_key
                    : Icons.vpn_key_off_outlined,
                color: _currentClient.hasAppAccess && _currentClient.accessStatus == 'active'
                    ? AppTheme.accentCyan
                    : Colors.white70,
              ),
              tooltip: 'Gérer l\'accès App Client B2B'.tr,
              onPressed: _showManageAppAccessDialog,
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _showEditClientDialog,
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteClient,
            ),
          ],
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: AppTheme.accentCyan,
            tabs: [
              Tab(text: 'Tickets'),
              Tab(text: 'Paiements'),
              Tab(text: 'Véhicules'),
            ],
          ),
        ),
        body: Column(
          children: [
            // B2B App Access Status Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        _currentClient.hasAppAccess && _currentClient.accessStatus == 'active'
                            ? Icons.check_circle
                            : Icons.block,
                        size: 16,
                        color: _currentClient.hasAppAccess && _currentClient.accessStatus == 'active'
                            ? AppTheme.successGreen
                            : AppTheme.warningOrange,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _currentClient.hasAppAccess && _currentClient.accessStatus == 'active'
                            ? 'Accès App Client: Autorisé'.tr
                            : 'Accès App Client: Bloqué / Non configuré'.tr,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: _showManageAppAccessDialog,
                    child: Text(
                      'Gérer l\'Accès'.tr,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.accentCyan, decoration: TextDecoration.underline),
                    ),
                  ),
                ],
              ),
            ),

            Container(
              color: Theme.of(context).colorScheme.surface,
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Solde Restant'.tr, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 13)),
                      Text(
                        currencyFormat.format(_currentClient.currentBalance),
                        style: TextStyle(
                          fontSize: 22,
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
                          icon: const Icon(Icons.payment),
                          label: Text('Régler'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.successGreen, foregroundColor: Colors.white),
                        ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: _exportUnpaidBalance,
                        icon: const Icon(Icons.picture_as_pdf),
                        label: Text('Détail Solde'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.surface,
                          foregroundColor: AppTheme.accentCyan,
                          side: const BorderSide(color: AppTheme.accentCyan),
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
        if (tickets.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.receipt_long_outlined, size: 48, color: AppTheme.textHint),
                const SizedBox(height: 12),
                Text('Aucun ticket enregistré pour ce client.'.tr, style: const TextStyle(color: AppTheme.textHint)),
              ],
            ),
          );
        }

        // Calculate FIFO Unpaid tickets making up the current balance
        final Set<String> unpaidTicketIds = {};
        final validTickets = tickets.where((t) => t.status != TicketStatus.annule && t.status != TicketStatus.efface).toList();
        
        double remBalance = _currentClient.currentBalance;
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
            // Filter Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
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

            // Tickets List
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Text('Aucun ticket ne correspond au filtre.'.tr, style: const TextStyle(color: AppTheme.textHint)),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
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
                                        color: AppTheme.primaryBlue.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        'Ticket ${t.ticketNumber}',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppTheme.primaryBlue),
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
                                      currencyFormat.format(t.montant),
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

  int _getTicketCountForVehicle(String vehiclePlate, List<Ticket> tickets) {
    final cleanPlate = vehiclePlate.replaceAll(' ', '').toUpperCase();
    if (cleanPlate.isEmpty) return 0;
    return tickets.where((t) {
      if (t.status == TicketStatus.annule || t.status == TicketStatus.efface) return false;
      final tPlate = (t.vehiclePlate ?? '').replaceAll(' ', '').toUpperCase();
      return tPlate == cleanPlate;
    }).length;
  }

  Widget _buildVehiclesTab(WidgetRef ref) {
    final vehicles = _currentClient.vehicles;
    final ticketsAsync = ref.watch(clientTicketsProvider(_currentClient.id));
    final tickets = ticketsAsync.value ?? [];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '${vehicles.length} véhicule(s) dans la flotte B2B'.tr,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentCyan, foregroundColor: Colors.white),
                onPressed: _showAddVehicleDialog,
                icon: const Icon(Icons.add),
                label: Text('Ajouter'.tr),
              ),
            ],
          ),
        ),
        if (vehicles.isEmpty)
          Expanded(child: Center(child: Text('Aucun véhicule enregistré pour ce client.'.tr)))
        else
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: vehicles.length,
              itemBuilder: (context, index) {
                final vehicle = vehicles[index];
                final ticketCount = _getTicketCountForVehicle(vehicle.plate, tickets);
                final isLocked = ticketCount > 0;

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  elevation: 1.5,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: isLocked
                              ? AppTheme.warningOrange.withValues(alpha: 0.15)
                              : AppTheme.accentCyan.withValues(alpha: 0.15),
                          child: Icon(
                            Icons.directions_car_filled,
                            color: isLocked ? AppTheme.warningOrange : AppTheme.accentCyan,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    vehicle.plate,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
                                          size: 11,
                                          color: isLocked ? AppTheme.warningOrange : AppTheme.successGreen,
                                        ),
                                        const SizedBox(width: 3),
                                        Text(
                                          isLocked ? '$ticketCount ticket(s)'.tr : 'Modifiable'.tr,
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: isLocked ? AppTheme.warningOrange : AppTheme.successGreen,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                vehicle.brand.isNotEmpty || vehicle.model.isNotEmpty
                                    ? '${vehicle.brand} ${vehicle.model}'.trim()
                                    : 'Marque/Modèle non renseigné'.tr,
                                style: const TextStyle(fontSize: 12, color: AppTheme.textHint),
                              ),
                              const SizedBox(height: 2),
                              Consumer(
                                builder: (context, ref, child) {
                                  final user = ref.watch(currentUserProvider);
                                  if (user == null) return const SizedBox();
                                  final catAsync = ref.watch(vehicleCategoriesStreamProvider(user.tenantId));
                                  final catList = catAsync.value ?? [];
                                  final cat = catList.where((c) => c.id == vehicle.categoryId).firstOrNull;
                                  final catName = cat?.name ?? '';

                                  if (catName.isNotEmpty) {
                                    return Text(
                                      'Catégorie : $catName'.tr,
                                      style: const TextStyle(fontSize: 11, color: AppTheme.primaryBlue, fontWeight: FontWeight.bold),
                                    );
                                  } else {
                                    return Text(
                                      '⚠️ Catégorie à définir'.tr,
                                      style: const TextStyle(fontSize: 11, color: AppTheme.warningOrange, fontWeight: FontWeight.w500),
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.edit_outlined,
                                color: isLocked ? Colors.grey.shade400 : AppTheme.primaryBlue,
                              ),
                              tooltip: isLocked
                                  ? 'Modification verrouillée (attaché à des tickets)'
                                  : 'Modifier',
                              onPressed: () => _showEditVehicleDialog(vehicle, index, ticketCount),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.delete_outline,
                                color: isLocked ? Colors.grey.shade400 : AppTheme.errorRed,
                              ),
                              tooltip: isLocked
                                  ? 'Suppression verrouillée (attaché à des tickets)'
                                  : 'Supprimer',
                              onPressed: () => _deleteVehicle(index, ticketCount),
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
                  const SizedBox(height: 16),
                  Consumer(
                    builder: (context, ref, child) {
                      final categoriesAsync = ref.watch(vehicleCategoriesStreamProvider(user.tenantId));
                      return categoriesAsync.when(
                        data: (categories) {
                          if (categories.isEmpty) return const SizedBox();
                          return DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: 'Catégorie de véhicule (optionnelle)'.tr,
                              prefixIcon: const Icon(Icons.category, color: AppTheme.primaryBlue),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            initialValue: newCategoryId.isEmpty ? null : newCategoryId,
                            items: categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                            onChanged: (val) {
                              if (val != null) newCategoryId = val;
                            },
                          );
                        },
                        loading: () => const CircularProgressIndicator(),
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

  void _showEditVehicleDialog(ClientVehicle vehicle, int index, int ticketCount) {
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
                  const SizedBox(height: 16),
                  Consumer(
                    builder: (context, ref, child) {
                      final categoriesAsync = ref.watch(vehicleCategoriesStreamProvider(user.tenantId));
                      return categoriesAsync.when(
                        data: (categories) {
                          if (categories.isEmpty) return const SizedBox();
                          if (newCategoryId.isNotEmpty && !categories.any((c) => c.id == newCategoryId)) {
                            newCategoryId = '';
                          }
                          return DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: 'Catégorie de véhicule (Assigner/Modifier)'.tr,
                              prefixIcon: const Icon(Icons.category, color: AppTheme.primaryBlue),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            initialValue: newCategoryId.isEmpty ? null : newCategoryId,
                            items: categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                            onChanged: (val) {
                              if (val != null) newCategoryId = val;
                            },
                          );
                        },
                        loading: () => const CircularProgressIndicator(),
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

  void _deleteVehicle(int index, int ticketCount) async {
    final vehicle = _currentClient.vehicles[index];

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

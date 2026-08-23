import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:washify/core/constants/user_roles.dart';
import 'package:washify/core/localization/app_localizations.dart';
import 'package:washify/core/theme/app_theme.dart';
import 'package:washify/features/products/models/product.dart';
import 'package:washify/features/services/models/service_definition.dart';
import 'package:washify/features/tickets/models/ticket.dart';
import 'package:washify/providers/auth_provider.dart';
import 'package:washify/providers/product_provider.dart';
import 'package:washify/providers/service_definition_provider.dart';
import 'package:washify/providers/ticket_provider.dart';

void showTicketsDetailsDialog(
  BuildContext context,
  String title,
  List<Ticket> tickets, {
  VoidCallback? onRefresh,
}) {
  final isMobile = MediaQuery.of(context).size.width < 600;
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        insetPadding: EdgeInsets.symmetric(
          horizontal: isMobile ? 6 : 12,
          vertical: isMobile ? 10 : 16,
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SizedBox(
          width: isMobile ? double.infinity : MediaQuery.of(context).size.width * 0.96,
          height: MediaQuery.of(context).size.height * (isMobile ? 0.94 : 0.88),
          child: TicketsTableModal(
            title: title,
            tickets: tickets,
          ),
        ),
      );
    },
  );
}

class TicketsTableModal extends ConsumerStatefulWidget {
  final String title;
  final List<Ticket> tickets;

  const TicketsTableModal({
    super.key,
    required this.title,
    required this.tickets,
  });

  @override
  ConsumerState<TicketsTableModal> createState() => _TicketsTableModalState();
}

class _TicketsTableModalState extends ConsumerState<TicketsTableModal> {
  String _filterType = 'all'; // 'all', 'vehicule', 'moquette'
  String _filterPayment = 'all'; // 'all', 'especes', 'compte_client', 'tpe'
  String _filterWorker = 'all'; // 'all', or worker name
  final ScrollController _horizontalScroll = ScrollController();
  final ScrollController _verticalScroll = ScrollController();

  @override
  void dispose() {
    _horizontalScroll.dispose();
    _verticalScroll.dispose();
    super.dispose();
  }

  Future<void> _validateTicketPayment(BuildContext context, Ticket ticket) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: AppTheme.successGreen, size: 28),
            const SizedBox(width: 10),
            Expanded(child: Text('Valider le Paiement ?'.tr)),
          ],
        ),
        content: Text('Voulez-vous marquer le ticket ${ticket.ticketNumber} (${ticket.totalAmount.toStringAsFixed(1)} DT) comme PAYÉ ?'.tr),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Annuler'.tr),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.successGreen, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            icon: const Icon(Icons.check),
            label: Text('Valider'.tr),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ref.read(ticketRepositoryProvider).updateTicketStatus(ticket.id, 'paye');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Paiement du ticket ${ticket.ticketNumber} validé avec succès !'.tr),
              backgroundColor: AppTheme.successGreen,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur: $e'.tr), backgroundColor: AppTheme.errorRed),
          );
        }
      }
    }
  }

  Future<void> _confirmDeleteTicket(BuildContext context, Ticket ticket) async {
    final user = ref.read(currentUserProvider);
    final isPatron = (user?.role == UserRole.patron);

    // Strict Rule: Cashiers cannot delete already validated tickets
    if (ticket.status == TicketStatus.paye && !isPatron) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Un ticket déjà validé ne peut être supprimé que par le patron !'.tr),
          backgroundColor: Colors.amber.shade900,
        ),
      );
      return;
    }

    final reasonController = TextEditingController();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Supprimer le ticket ?'.tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Voulez-vous vraiment effacer le ticket ${ticket.ticketNumber} ? Son solde sera déduit de la recette et le stock sera restauré.'.tr),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                labelText: 'Motif de suppression'.tr,
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text('Annuler'.tr),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorRed),
            onPressed: () {
              if (reasonController.text.trim().isEmpty) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  SnackBar(content: Text('Le motif est requis'.tr)),
                );
                return;
              }
              Navigator.pop(dialogContext, true);
            },
            child: Text('Confirmer'.tr, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ref.read(ticketRepositoryProvider).deleteTicket(
          ticket.id,
          reason: reasonController.text.trim(),
        );
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Ticket effacé avec succès'.tr), backgroundColor: AppTheme.successGreen),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur: $e'.tr), backgroundColor: AppTheme.errorRed),
          );
        }
      }
    }
  }

  void _editTicket(BuildContext context, Ticket ticket) {
    final user = ref.read(currentUserProvider);
    final isPatron = (user?.role == UserRole.patron);

    // Strict Rule: Cashiers cannot edit already validated tickets
    if (ticket.status == TicketStatus.paye && !isPatron) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Un ticket déjà validé ne peut être modifié que par le patron !'.tr),
          backgroundColor: Colors.amber.shade900,
        ),
      );
      return;
    }

    Navigator.pop(context); // Close details modal
    final route = isPatron ? '/patron/tickets/new' : '/cashier/tickets/new';
    context.push(route, extra: ticket);
  }

  Widget _buildMetricTile(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, style: const TextStyle(fontSize: 10, color: AppTheme.textHint)),
              Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final isPatron = (user?.role == UserRole.patron);
    final stationId = user?.stationId ?? '';
    final allProducts = ref.watch(productsStreamProvider(stationId)).value ?? [];
    final allServicesDef = ref.watch(serviceDefinitionsStreamProvider(stationId)).value ?? [];
    final productMap = {for (final p in allProducts) p.id: p};
    final serviceMap = {for (final s in allServicesDef) s.id: s};
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompactMobile = screenWidth < 768;

    // Extract unique workers
    final Set<String> workerNamesSet = {};
    for (final t in widget.tickets) {
      final name = (t.assignedWorkerName != null && t.assignedWorkerName!.trim().isNotEmpty)
          ? t.assignedWorkerName!.trim()
          : 'Non assigné';
      workerNamesSet.add(name);
    }
    final List<String> workerList = workerNamesSet.toList()..sort();

    final filteredTickets = widget.tickets.where((t) {
      if (_filterType == 'vehicule' && t.operationType != 'vehicule') return false;
      if (_filterType == 'moquette' && t.operationType != 'moquette') return false;

      if (_filterPayment != 'all') {
        final pm = t.paymentMethod?.toLowerCase() ?? '';
        final isCompte = pm.contains('compte') || pm.contains('b2b');
        final isTpe = pm.contains('tpe') || pm.contains('carte');
        final isCash = !isCompte && !isTpe;

        if (_filterPayment == 'especes' && !isCash) return false;
        if (_filterPayment == 'compte_client' && !isCompte) return false;
        if (_filterPayment == 'tpe' && !isTpe) return false;
      }

      if (_filterWorker != 'all') {
        final name = (t.assignedWorkerName != null && t.assignedWorkerName!.trim().isNotEmpty)
            ? t.assignedWorkerName!.trim()
            : 'Non assigné';
        if (name != _filterWorker) return false;
      }

      return true;
    }).toList();

    // Calculate total amount of current filtered tickets
    final double filterTotal = filteredTickets.fold(0.0, (sum, t) {
      if (t.status == TicketStatus.efface || t.status == TicketStatus.annule) return sum;
      return sum + t.totalAmount;
    });

    // Strategic metrics
    int totalUpsellTickets = 0;
    double optionsSum = 0.0;
    double boutiqueSum = 0.0;

    for (final t in filteredTickets) {
      if (t.status == TicketStatus.efface || t.status == TicketStatus.annule) continue;

      final optionServices = t.servicesSelected.where((s) {
        final def = serviceMap[s.serviceId];
        if (def != null) return def.serviceType == ServiceType.supplement || def.serviceType == ServiceType.special;
        final nameLower = s.serviceName.toLowerCase();
        return nameLower.contains('option') || nameLower.contains('supplément') || nameLower.contains('extra') || nameLower.contains('décrass') || nameLower.contains('produit');
      });
      final optionProducts = t.productsUsed.where((p) {
        final prod = productMap[p.productId];
        if (prod != null) return prod.family == ProductFamily.extra || prod.family == ProductFamily.standard;
        final nameLower = p.productName.toLowerCase();
        return !nameLower.contains('sapin') && !nameLower.contains('fresh') && !nameLower.contains('tapis');
      });

      final optVal = optionServices.fold(0.0, (sum, s) => sum + s.price) + optionProducts.fold(0.0, (sum, p) => sum + p.total);
      optionsSum += optVal;

      final boutiqueProducts = t.productsUsed.where((p) {
        final prod = productMap[p.productId];
        if (prod != null) return prod.family == ProductFamily.revente;
        final nameLower = p.productName.toLowerCase();
        return nameLower.contains('sapin') || nameLower.contains('fresh') || nameLower.contains('tapis') || p.productName.contains('Boutique');
      });
      final boutVal = boutiqueProducts.fold(0.0, (sum, p) => sum + p.total);
      boutiqueSum += boutVal;

      if (optVal > 0 || boutVal > 0) {
        totalUpsellTickets++;
      }
    }

    final int validTicketsCount = filteredTickets.where((t) => t.status != TicketStatus.efface && t.status != TicketStatus.annule).length;
    final double upsellRate = validTicketsCount > 0 ? (totalUpsellTickets / validTicketsCount * 100) : 0.0;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.analytics_outlined, color: AppTheme.primaryBlue, size: 26),
                  const SizedBox(width: 10),
                  Text(
                    widget.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 26),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Filters & Actions Bar
          Wrap(
            spacing: 12,
            runSpacing: 10,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              // Type Filters
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FilterChip(
                    label: Text('Tous (${widget.tickets.length})'.tr),
                    selected: _filterType == 'all',
                    onSelected: (_) => setState(() => _filterType = 'all'),
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: Text('Véhicules (${widget.tickets.where((t) => t.operationType == 'vehicule').length})'.tr),
                    selected: _filterType == 'vehicule',
                    onSelected: (_) => setState(() => _filterType = 'vehicule'),
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: Text('Moquettes (${widget.tickets.where((t) => t.operationType == 'moquette').length})'.tr),
                    selected: _filterType == 'moquette',
                    onSelected: (_) => setState(() => _filterType = 'moquette'),
                  ),
                ],
              ),

              // Worker Filter Selector
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                decoration: BoxDecoration(
                  color: _filterWorker == 'all'
                      ? Theme.of(context).colorScheme.surface
                      : AppTheme.accentCyan.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _filterWorker == 'all'
                        ? AppTheme.textHint.withValues(alpha: 0.3)
                        : AppTheme.accentCyan,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.badge_outlined, size: 18, color: _filterWorker == 'all' ? AppTheme.textHint : AppTheme.accentCyan),
                    const SizedBox(width: 6),
                    DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _filterWorker,
                        isDense: true,
                        dropdownColor: AppTheme.surfaceCard,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: _filterWorker == 'all'
                              ? Theme.of(context).colorScheme.onSurface
                              : AppTheme.accentCyan,
                        ),
                        items: [
                          DropdownMenuItem(
                            value: 'all',
                            child: Text('Tous les Ouvriers (${widget.tickets.length})'.tr),
                          ),
                          ...workerList.map((w) {
                            final count = widget.tickets.where((t) {
                              final name = (t.assignedWorkerName != null && t.assignedWorkerName!.trim().isNotEmpty)
                                  ? t.assignedWorkerName!.trim()
                                  : 'Non assigné';
                              return name == w;
                            }).length;
                            return DropdownMenuItem(
                              value: w,
                              child: Text('$w ($count)'),
                            );
                          }),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _filterWorker = val);
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // Payment Method Filters
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.filter_list, size: 18, color: AppTheme.textHint),
                  const SizedBox(width: 6),
                  FilterChip(
                    label: Text('Tous Modes'.tr),
                    selected: _filterPayment == 'all',
                    onSelected: (_) => setState(() => _filterPayment = 'all'),
                  ),
                  const SizedBox(width: 6),
                  FilterChip(
                    avatar: const Icon(Icons.payments_outlined, size: 16, color: AppTheme.successGreen),
                    label: Text('Espèces (${widget.tickets.where((t) {
                      final pm = t.paymentMethod?.toLowerCase() ?? '';
                      return !pm.contains('compte') && !pm.contains('b2b') && !pm.contains('tpe') && !pm.contains('carte');
                    }).length})'.tr),
                    selected: _filterPayment == 'especes',
                    onSelected: (_) => setState(() => _filterPayment = 'especes'),
                  ),
                  const SizedBox(width: 6),
                  FilterChip(
                    avatar: const Icon(Icons.credit_card, size: 16, color: Colors.purple),
                    label: Text('Compte Client (${widget.tickets.where((t) {
                      final pm = t.paymentMethod?.toLowerCase() ?? '';
                      return pm.contains('compte') || pm.contains('b2b');
                    }).length})'.tr),
                    selected: _filterPayment == 'compte_client',
                    onSelected: (_) => setState(() => _filterPayment = 'compte_client'),
                  ),
                  const SizedBox(width: 6),
                  FilterChip(
                    avatar: const Icon(Icons.contactless, size: 16, color: AppTheme.primaryBlue),
                    label: Text('TPE (${widget.tickets.where((t) {
                      final pm = t.paymentMethod?.toLowerCase() ?? '';
                      return pm.contains('tpe') || pm.contains('carte');
                    }).length})'.tr),
                    selected: _filterPayment == 'tpe',
                    onSelected: (_) => setState(() => _filterPayment = 'tpe'),
                  ),
                ],
              ),

              // Total badge & Copy Button
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.35)),
                    ),
                    child: Text(
                      'Total Filtre: ${filterTotal.toStringAsFixed(1)} DT'.tr,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryBlue, fontSize: 13),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: () => _copyTableToClipboard(filteredTickets, productMap, serviceMap),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.copy_outlined, size: 18),
                    label: Text('Copier le Tableau'.tr, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 20),

          // Strategic Worker Performance Card (when worker selected)
          if (_filterWorker != 'all') ...[
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.accentCyan.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.accentCyan.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.stars, color: Colors.amber, size: 20),
                      const SizedBox(width: 6),
                      Text(
                        'Rendement Stratégique & Commercial : $_filterWorker'.tr,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.accentCyan),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      _buildMetricTile('Tickets Traités'.tr, '$validTicketsCount', Icons.local_car_wash, Colors.blue),
                      _buildMetricTile('Chiffre d\'Affaires'.tr, '${filterTotal.toStringAsFixed(1)} DT', Icons.monetization_on, AppTheme.successGreen),
                      _buildMetricTile('Ventes Options/Suppléments'.tr, '${optionsSum.toStringAsFixed(1)} DT', Icons.auto_awesome, Colors.purple),
                      _buildMetricTile('Ventes Boutique'.tr, '${boutiqueSum.toStringAsFixed(1)} DT', Icons.shopping_bag, Colors.orange),
                      _buildMetricTile('Taux de Conversion Up-Selling'.tr, '${upsellRate.toStringAsFixed(0)}%', Icons.trending_up, Colors.teal),
                    ],
                  ),
                ],
              ),
            ),
          ],

          // View Switcher (Mobile Card List vs Desktop DataTable)
          Expanded(
            child: filteredTickets.isEmpty
                ? Center(
                    child: Text('Aucun ticket trouvé pour ce filtre.'.tr, style: const TextStyle(color: AppTheme.textHint)),
                  )
                : (isCompactMobile
                    ? ListView.builder(
                        itemCount: filteredTickets.length,
                        itemBuilder: (context, index) {
                          final ticket = filteredTickets[index];
                          return _buildMobileTicketCard(context, ticket, isPatron, productMap, serviceMap);
                        },
                      )
                    : Scrollbar(
                        controller: _horizontalScroll,
                        thumbVisibility: true,
                        trackVisibility: true,
                        child: SingleChildScrollView(
                          controller: _horizontalScroll,
                          scrollDirection: Axis.horizontal,
                          child: Scrollbar(
                            controller: _verticalScroll,
                            thumbVisibility: true,
                            child: SingleChildScrollView(
                              controller: _verticalScroll,
                              scrollDirection: Axis.vertical,
                              child: DataTable(
                                columnSpacing: 18,
                                horizontalMargin: 16,
                                dataRowMinHeight: 64,
                                dataRowMaxHeight: double.infinity,
                                headingRowColor: WidgetStateProperty.all(AppTheme.primaryBlue.withValues(alpha: 0.12)),
                                columns: [
                                  DataColumn(label: Text('N° Ticket'.tr, style: const TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text('Type'.tr, style: const TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text('Véhicule / Client'.tr, style: const TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text('Service Lavage'.tr, style: const TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text('Options & Suppléments'.tr, style: const TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text('Boutique'.tr, style: const TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text('Remise & Motif'.tr, style: const TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text('Caissier'.tr, style: const TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text('Ouvrier'.tr, style: const TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text('Paiement'.tr, style: const TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text('Total'.tr, style: const TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text('Actions'.tr, style: const TextStyle(fontWeight: FontWeight.bold))),
                                ],
                                rows: filteredTickets.map((ticket) {
                                  final isDeleted = ticket.status == TicketStatus.efface || ticket.status == TicketStatus.annule;
                                  final isMoquette = ticket.operationType == 'moquette';
                                  final isPaid = ticket.status == TicketStatus.paye;
                                  final canEditOrDelete = !isPaid || isPatron;

                                  final vehiculeDisplay = isMoquette
                                      ? '${ticket.carpetMeters ?? 0} m²'
                                      : '${ticket.vehiclePlate ?? '-'} ${ticket.vehicleBrand ?? ''} ${ticket.vehicleModel ?? ''}'.trim();

                                  final washServices = ticket.servicesSelected.where((s) {
                                    final def = serviceMap[s.serviceId];
                                    if (def != null) {
                                      return def.serviceType == ServiceType.lavage;
                                    }
                                    final nameLower = s.serviceName.toLowerCase();
                                    return !nameLower.contains('option') && !nameLower.contains('supplément') && !nameLower.contains('extra') && !nameLower.contains('décrass') && !nameLower.contains('produit');
                                  }).toList();

                                  final serviceDisplay = isMoquette
                                      ? 'Moquette (${((ticket.carpetMeters ?? 0) * (ticket.carpetUnitPrice ?? 0)).toStringAsFixed(1)} DT)'
                                      : (washServices.isNotEmpty
                                          ? washServices.map((s) => '${s.serviceName} (${s.price.toStringAsFixed(1)} DT)').join('\n')
                                          : (ticket.servicesSelected.isNotEmpty ? '${ticket.servicesSelected.first.serviceName} (${ticket.servicesSelected.first.price.toStringAsFixed(1)} DT)' : '-'));

                                  final optionServices = ticket.servicesSelected.where((s) {
                                    final def = serviceMap[s.serviceId];
                                    if (def != null) {
                                      return def.serviceType == ServiceType.supplement || def.serviceType == ServiceType.special;
                                    }
                                    final nameLower = s.serviceName.toLowerCase();
                                    return nameLower.contains('option') || nameLower.contains('supplément') || nameLower.contains('extra') || nameLower.contains('décrass') || nameLower.contains('produit');
                                  }).toList();

                                  final optionProducts = ticket.productsUsed.where((p) {
                                    final prod = productMap[p.productId];
                                    if (prod != null) {
                                      return prod.family == ProductFamily.extra || prod.family == ProductFamily.standard;
                                    }
                                    final nameLower = p.productName.toLowerCase();
                                    return !nameLower.contains('sapin') && !nameLower.contains('fresh') && !nameLower.contains('tapis');
                                  }).toList();

                                  final List<String> optionLines = [
                                    ...optionServices.map((s) => '${s.serviceName} (${s.price.toStringAsFixed(1)} DT)'),
                                    ...optionProducts.map((p) => '${p.productName} x${p.quantity} (${p.total.toStringAsFixed(1)} DT)'),
                                  ];
                                  final optionsDisplay = optionLines.isEmpty ? '-' : optionLines.join('\n');

                                  final boutiqueProducts = ticket.productsUsed.where((p) {
                                    final prod = productMap[p.productId];
                                    if (prod != null) {
                                      return prod.family == ProductFamily.revente;
                                    }
                                    final nameLower = p.productName.toLowerCase();
                                    return nameLower.contains('sapin') || nameLower.contains('fresh') || nameLower.contains('tapis') || p.productName.contains('Boutique');
                                  }).toList();

                                  final List<String> boutiqueLines = boutiqueProducts.map((p) {
                                    final prod = productMap[p.productId];
                                    final barcodeStr = (prod != null && prod.barcode.isNotEmpty) ? ' [Code: ${prod.barcode}]' : '';
                                    return '${p.productName}$barcodeStr x${p.quantity} (${p.total.toStringAsFixed(1)} DT)';
                                  }).toList();
                                  final boutiqueDisplay = boutiqueLines.isEmpty ? '-' : boutiqueLines.join('\n');

                                  final discountDisplay = (ticket.discountAmount != null && ticket.discountAmount! > 0)
                                      ? '-${ticket.discountAmount!.toStringAsFixed(1)} DT (${ticket.discountReason ?? ''})'
                                      : '-';

                                  return DataRow(
                                    color: isDeleted ? WidgetStateProperty.all(AppTheme.errorRed.withValues(alpha: 0.08)) : null,
                                    cells: [
                                      // N° Ticket
                                      DataCell(
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              ticket.ticketNumber,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: isDeleted ? AppTheme.errorRed : null,
                                                decoration: isDeleted ? TextDecoration.lineThrough : null,
                                              ),
                                            ),
                                            if (isDeleted)
                                              Text(
                                                'Effacé: ${ticket.deleteReason ?? ''}'.tr,
                                                style: const TextStyle(fontSize: 10, color: AppTheme.errorRed, fontStyle: FontStyle.italic),
                                              ),
                                          ],
                                        ),
                                      ),
                                      // Type
                                      DataCell(
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: (isMoquette ? Colors.orange : AppTheme.accentCyan).withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            isMoquette ? 'Moquette'.tr : 'Véhicule'.tr,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: isMoquette ? Colors.orange : AppTheme.accentCyan,
                                            ),
                                          ),
                                        ),
                                      ),
                                      // Véhicule / Client
                                      DataCell(
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(vehiculeDisplay.isEmpty ? '-' : vehiculeDisplay),
                                            if (ticket.clientName != null && ticket.clientName!.trim().isNotEmpty)
                                              Padding(
                                                padding: const EdgeInsets.only(top: 2.0),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    const Icon(Icons.person_outline, size: 14, color: AppTheme.primaryBlue),
                                                    const SizedBox(width: 3),
                                                    Text(
                                                      ticket.clientName!,
                                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      // Service Lavage
                                      DataCell(
                                        Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                                          child: Text(
                                            serviceDisplay.isEmpty ? '-' : serviceDisplay,
                                            style: const TextStyle(height: 1.35),
                                          ),
                                        ),
                                      ),
                                      // Options & Suppléments
                                      DataCell(
                                        Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                                          child: Text(
                                            optionsDisplay,
                                            style: const TextStyle(height: 1.35),
                                          ),
                                        ),
                                      ),
                                      // Boutique
                                      DataCell(
                                        Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                                          child: Text(
                                            boutiqueDisplay,
                                            style: const TextStyle(height: 1.35),
                                          ),
                                        ),
                                      ),
                                      // Remise & Motif
                                      DataCell(Text(discountDisplay)),
                                      // Caissier
                                      DataCell(Text(ticket.paidBy ?? ticket.createdBy)),
                                      // Ouvrier
                                      DataCell(Text(ticket.assignedWorkerName ?? 'Non assigné'.tr)),
                                      // Mode Paiement & Client
                                      DataCell(
                                        Builder(
                                          builder: (context) {
                                            final pm = ticket.paymentMethod?.toLowerCase() ?? '';
                                            final isCompte = pm.contains('compte') || pm.contains('b2b');
                                            final isTpe = pm.contains('tpe') || pm.contains('carte');
                                            final String label = isCompte ? 'Compte Client'.tr : (isTpe ? 'TPE'.tr : 'Espèces'.tr);
                                            final IconData icon = isCompte ? Icons.credit_card : (isTpe ? Icons.contactless : Icons.payments_outlined);
                                            final Color color = isCompte ? Colors.purple : (isTpe ? AppTheme.primaryBlue : AppTheme.successGreen);

                                            return Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: color.withValues(alpha: 0.15),
                                                    borderRadius: BorderRadius.circular(6),
                                                    border: Border.all(color: color.withValues(alpha: 0.3)),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Icon(icon, size: 14, color: color),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        label,
                                                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                if (ticket.clientName != null && ticket.clientName!.trim().isNotEmpty)
                                                  Padding(
                                                    padding: const EdgeInsets.only(top: 3.0),
                                                    child: Text(
                                                      ticket.clientName!,
                                                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
                                                    ),
                                                  ),
                                              ],
                                            );
                                          },
                                        ),
                                      ),
                                      // Total
                                      DataCell(
                                        Text(
                                          '${ticket.totalAmount.toStringAsFixed(1)} DT',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: isDeleted ? AppTheme.errorRed : AppTheme.successGreen,
                                            decoration: isDeleted ? TextDecoration.lineThrough : null,
                                          ),
                                        ),
                                      ),
                                      // Actions
                                      DataCell(
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            if (!isDeleted) ...[
                                              if (!isPaid)
                                                ElevatedButton.icon(
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: AppTheme.successGreen,
                                                    foregroundColor: Colors.white,
                                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                  ),
                                                  icon: const Icon(Icons.check_circle_rounded, size: 22),
                                                  label: Text('Valider'.tr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                                  onPressed: () => _validateTicketPayment(context, ticket),
                                                ),
                                              if (!isPaid) const SizedBox(width: 6),
                                              if (canEditOrDelete) ...[
                                                IconButton(
                                                  icon: const Icon(Icons.edit_square, color: AppTheme.primaryBlue, size: 24),
                                                  tooltip: 'Modifier'.tr,
                                                  onPressed: () => _editTicket(context, ticket),
                                                ),
                                                IconButton(
                                                  icon: const Icon(Icons.delete_forever_rounded, color: AppTheme.errorRed, size: 24),
                                                  tooltip: 'Supprimer'.tr,
                                                  onPressed: () => _confirmDeleteTicket(context, ticket),
                                                ),
                                              ] else ...[
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: Colors.amber.withValues(alpha: 0.15),
                                                    borderRadius: BorderRadius.circular(6),
                                                    border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      const Icon(Icons.lock_rounded, size: 14, color: Colors.amber),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        'Réservé au patron'.tr,
                                                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.amber),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                      )),
          ),
        ],
      ),
    );
  }

  // Mobile Ticket Card with Bottom Strategic Action Bar & Large Ergonomic Icons
  Widget _buildMobileTicketCard(
    BuildContext context,
    Ticket ticket,
    bool isPatron,
    Map<String, Product> productMap,
    Map<String, dynamic> serviceMap,
  ) {
    final isDeleted = ticket.status == TicketStatus.efface || ticket.status == TicketStatus.annule;
    final isMoquette = ticket.operationType == 'moquette';
    final isPaid = ticket.status == TicketStatus.paye;
    final canEditOrDelete = !isPaid || isPatron;

    final vehiculeDisplay = isMoquette
        ? '${ticket.carpetMeters ?? 0} m²'
        : '${ticket.vehiclePlate ?? '-'} ${ticket.vehicleBrand ?? ''} ${ticket.vehicleModel ?? ''}'.trim();

    final washServices = ticket.servicesSelected.where((s) {
      final def = serviceMap[s.serviceId];
      if (def != null) return def.serviceType == ServiceType.lavage;
      final nameLower = s.serviceName.toLowerCase();
      return !nameLower.contains('option') && !nameLower.contains('supplément') && !nameLower.contains('extra') && !nameLower.contains('décrass') && !nameLower.contains('produit');
    }).toList();

    final serviceDisplay = isMoquette
        ? 'Moquette (${((ticket.carpetMeters ?? 0) * (ticket.carpetUnitPrice ?? 0)).toStringAsFixed(1)} DT)'
        : (washServices.isNotEmpty
            ? washServices.map((s) => s.serviceName).join(', ')
            : (ticket.servicesSelected.isNotEmpty ? ticket.servicesSelected.first.serviceName : '-'));

    final pm = ticket.paymentMethod?.toLowerCase() ?? '';
    final isCompte = pm.contains('compte') || pm.contains('b2b');
    final isTpe = pm.contains('tpe') || pm.contains('carte');
    final String pmLabel = isCompte ? 'Compte Client'.tr : (isTpe ? 'TPE'.tr : 'Espèces'.tr);
    final Color pmColor = isCompte ? Colors.purple : (isTpe ? AppTheme.primaryBlue : AppTheme.successGreen);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDeleted
              ? AppTheme.errorRed.withValues(alpha: 0.3)
              : (isPaid ? AppTheme.successGreen.withValues(alpha: 0.3) : AppTheme.primaryBlue.withValues(alpha: 0.25)),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Ticket Number & Total Amount
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: (isMoquette ? Colors.orange : AppTheme.accentCyan).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isMoquette ? 'Moquette'.tr : 'Véhicule'.tr,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isMoquette ? Colors.orange : AppTheme.accentCyan,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      ticket.ticketNumber,
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        color: isDeleted ? AppTheme.errorRed : null,
                        decoration: isDeleted ? TextDecoration.lineThrough : null,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${ticket.totalAmount.toStringAsFixed(1)} DT',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: isDeleted ? AppTheme.errorRed : AppTheme.successGreen,
                  ),
                ),
              ],
            ),
            const Divider(height: 20),

            // Vehicle / Client & Service Details
            Row(
              children: [
                const Icon(Icons.directions_car_outlined, size: 20, color: AppTheme.textHint),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    vehiculeDisplay.isEmpty ? '-' : vehiculeDisplay,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: pmColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: pmColor.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    pmLabel,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: pmColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                const Icon(Icons.local_car_wash_outlined, size: 20, color: AppTheme.textHint),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Service: $serviceDisplay'.tr,
                    style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.9)),
                  ),
                ),
                Text(
                  'Ouvrier: ${ticket.assignedWorkerName ?? 'Non assigné'.tr}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textHint),
                ),
              ],
            ),

            if (ticket.clientName != null && ticket.clientName!.trim().isNotEmpty) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.person_outline, size: 18, color: AppTheme.primaryBlue),
                  const SizedBox(width: 6),
                  Text(
                    'Client: ${ticket.clientName!}'.tr,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
                  ),
                ],
              ),
            ],

            if (isDeleted) ...[
              const SizedBox(height: 8),
              Text(
                'Effacé: ${ticket.deleteReason ?? ''}'.tr,
                style: const TextStyle(fontSize: 12, color: AppTheme.errorRed, fontStyle: FontStyle.italic),
              ),
            ],

            // BOTTOM STRATEGIC ACTION BAR (Large touch targets & big icons!)
            if (!isDeleted) ...[
              const Divider(height: 20),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.end,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (!isPaid)
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.successGreen,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(130, 48),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 3,
                      ),
                      icon: const Icon(Icons.check_circle_rounded, size: 26),
                      label: Text('Valider Paiement'.tr, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      onPressed: () => _validateTicketPayment(context, ticket),
                    ),

                  if (canEditOrDelete) ...[
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primaryBlue,
                        side: BorderSide(color: AppTheme.primaryBlue.withValues(alpha: 0.6), width: 1.5),
                        minimumSize: const Size(110, 48),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.edit_square, size: 24),
                      label: Text('Modifier'.tr, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                      onPressed: () => _editTicket(context, ticket),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.errorRed.withValues(alpha: 0.12),
                        foregroundColor: AppTheme.errorRed,
                        elevation: 0,
                        side: BorderSide(color: AppTheme.errorRed.withValues(alpha: 0.4), width: 1.5),
                        minimumSize: const Size(110, 48),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.delete_forever_rounded, size: 24),
                      label: Text('Supprimer'.tr, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                      onPressed: () => _confirmDeleteTicket(context, ticket),
                    ),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.lock_rounded, size: 20, color: Colors.amber),
                          const SizedBox(width: 8),
                          Text(
                            'Ticket Validé • Modif/Suppr réservée au patron'.tr,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.amber),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _copyTableToClipboard(List<Ticket> filteredTickets, Map<String, Product> productMap, Map<String, dynamic> serviceMap) {
    final StringBuffer buffer = StringBuffer();
    buffer.writeln("=== ${widget.title} ===");
    buffer.writeln("Date d'exportation : ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}");
    buffer.writeln("Total tickets : ${filteredTickets.length}");
    buffer.writeln("===================================================\n");

    for (var i = 0; i < filteredTickets.length; i++) {
      final t = filteredTickets[i];
      final isMoquette = t.operationType == 'moquette';
      buffer.writeln("N° ${i + 1} | Ticket : ${t.ticketNumber} | Statut : ${t.status.name.toUpperCase()}");
      buffer.writeln("Type : ${isMoquette ? 'Moquette' : 'Véhicule'}");
      if (isMoquette) {
        buffer.writeln("Surface : ${t.carpetMeters ?? 0} m²");
        buffer.writeln("Service : Lavage Moquette (${((t.carpetMeters ?? 0) * (t.carpetUnitPrice ?? 0)).toStringAsFixed(1)} DT)");
        if (t.discountAmount != null && t.discountAmount! > 0) {
          buffer.writeln("Remise : -${t.discountAmount!.toStringAsFixed(1)} DT (Motif: ${t.discountReason ?? '-'})");
        }
      } else {
        buffer.writeln("Véhicule : ${t.vehiclePlate ?? '-'} ${t.vehicleBrand ?? ''} ${t.vehicleModel ?? ''}".trim());
        
        final washServices = t.servicesSelected.where((s) {
          final def = serviceMap[s.serviceId];
          if (def != null) return def.serviceType == ServiceType.lavage;
          final nameLower = s.serviceName.toLowerCase();
          return !nameLower.contains('option') && !nameLower.contains('supplément') && !nameLower.contains('extra') && !nameLower.contains('décrass') && !nameLower.contains('produit');
        }).toList();
        buffer.writeln("Service Lavage : ${washServices.isNotEmpty ? washServices.map((s) => '${s.serviceName} (${s.price.toStringAsFixed(1)} DT)').join(', ') : '-'}");

        final optionServices = t.servicesSelected.where((s) {
          final def = serviceMap[s.serviceId];
          if (def != null) return def.serviceType == ServiceType.supplement || def.serviceType == ServiceType.special;
          final nameLower = s.serviceName.toLowerCase();
          return nameLower.contains('option') || nameLower.contains('supplément') || nameLower.contains('extra') || nameLower.contains('décrass') || nameLower.contains('produit');
        }).toList();
        final optionProducts = t.productsUsed.where((p) {
          final prod = productMap[p.productId];
          if (prod != null) return prod.family == ProductFamily.extra || prod.family == ProductFamily.standard;
          final nameLower = p.productName.toLowerCase();
          return !nameLower.contains('sapin') && !nameLower.contains('fresh') && !nameLower.contains('tapis');
        }).toList();
        final optionLines = [
          ...optionServices.map((s) => '${s.serviceName} (${s.price.toStringAsFixed(1)} DT)'),
          ...optionProducts.map((p) => '${p.productName} x${p.quantity} (${p.total.toStringAsFixed(1)} DT)'),
        ];
        buffer.writeln("Options & Suppléments : ${optionLines.isNotEmpty ? optionLines.join(', ') : '-'}");

        final boutiqueProducts = t.productsUsed.where((p) {
          final prod = productMap[p.productId];
          if (prod != null) return prod.family == ProductFamily.revente;
          final nameLower = p.productName.toLowerCase();
          return nameLower.contains('sapin') || nameLower.contains('fresh') || nameLower.contains('tapis') || p.productName.contains('Boutique');
        }).toList();

        final boutiqueLines = boutiqueProducts.map((p) {
          final prod = productMap[p.productId];
          final barcodeStr = (prod != null && prod.barcode.isNotEmpty) ? ' [Code: ${prod.barcode}]' : '';
          return '${p.productName}$barcodeStr x${p.quantity} (${p.total.toStringAsFixed(1)} DT)';
        }).toList();
        buffer.writeln("Boutique : ${boutiqueLines.isNotEmpty ? boutiqueLines.join(', ') : '-'}");
      }
      buffer.writeln("Caissier : ${t.paidBy ?? t.createdBy}");
      buffer.writeln("Ouvrier : ${t.assignedWorkerName ?? 'Non assigné'}");
      buffer.writeln("Mode de Paiement : ${t.paymentMethod ?? 'Espèces'} ${t.clientName != null ? '(${t.clientName})' : ''}");
      buffer.writeln("TOTAL : ${t.totalAmount.toStringAsFixed(1)} DT");
      buffer.writeln("---------------------------------------------------\n");
    }

    Clipboard.setData(ClipboardData(text: buffer.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tableau du détail des tickets copié dans le presse-papier !'.tr),
        backgroundColor: AppTheme.successGreen,
      ),
    );
  }
}

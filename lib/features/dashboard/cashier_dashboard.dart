import 'package:flutter/material.dart';
import 'package:washify/core/widgets/language_toggle_button.dart';
import 'package:washify/core/localization/app_localizations.dart';

import 'package:washify/features/auth/widgets/change_pin_dialog.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:washify/core/theme/app_theme.dart';

import 'package:washify/providers/auth_provider.dart';
import 'package:washify/providers/ticket_provider.dart';
import 'package:washify/providers/employee_provider.dart';
import 'package:washify/core/constants/user_roles.dart';
import 'package:washify/features/tickets/models/ticket.dart';

class CashierDashboard extends ConsumerStatefulWidget {
  const CashierDashboard({super.key});

  @override
  ConsumerState<CashierDashboard> createState() => _CashierDashboardState();
}

class _CashierDashboardState extends ConsumerState<CashierDashboard> {
  void _logout() {
    ref.read(currentUserProvider.notifier).logout();
  }

  Future<void> _updateStatus(String ticketId, String status) async {
    final repo = ref.read(ticketRepositoryProvider);
    await repo.updateTicketStatus(ticketId, status);
    final user = ref.read(currentUserProvider);
    if (user != null && user.stationId != null) {
      ref.invalidate(todayTicketsStreamProvider(user.stationId!));
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Statut du ticket mis à jour : $status'.tr)),
      );
    }
  }

  Future<void> _assignWorker(String ticketId) async {
    final user = ref.read(currentUserProvider);
    if (user == null || user.stationId == null) return;

    final employees = await ref.read(employeeRepositoryProvider).getEmployeesByStation(user.stationId!);
    final workers = employees.where((e) => e.roles.contains(UserRole.ouvrier)).toList();

    if (!mounted) return;

    if (workers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Aucun laveur actif disponible'.tr)),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Assigner un laveur'.tr),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: workers.length,
              itemBuilder: (context, index) {
                final worker = workers[index];
                return ListTile(
                  title: Text(worker.name),
                  subtitle: Text(worker.phone),
                  onTap: () async {
                    await ref.read(ticketRepositoryProvider).assignWorker(
                          ticketId,
                          worker.userId,
                          worker.name,
                        );
                    ref.invalidate(todayTicketsStreamProvider(user.stationId!));
                    if (context.mounted) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Laveur ${worker.name} assigné'.tr)),
                      );
                    }
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    if (user == null || user.stationId == null) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final ticketsStream = ref.watch(todayTicketsStreamProvider(user.stationId!));

    return Scaffold(
      appBar: AppBar(
        title: Text('Caisse - Washify'.tr),
        actions: [
                    const LanguageToggleButton(),
          IconButton(
            icon: Icon(Icons.password),
            tooltip: 'Changer le code PIN'.tr,
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => ChangePinDialog(),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Quick Action Buttons
            InkWell(
              onTap: () => context.push('/cashier/tickets/new'),
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: Offset(0, 8),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    Icon(Icons.add_circle_outline, color: Colors.white, size: 64),
                    SizedBox(height: 16),
                    Text(
                      'Nouveau Ticket'.tr,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 32),

            // Today's tickets list header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tickets du Jour',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                TextButton(
                  onPressed: () => context.go('/cashier/tickets'),
                  child: Text('Voir tout'.tr),
                ),
              ],
            ),
            SizedBox(height: 12),

            // Today's tickets stream list
            Expanded(
              child: ticketsStream.when(
                data: (tickets) {
                  if (tickets.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.receipt_long, size: 48, color: AppTheme.textHint.withValues(alpha: 0.5)),
                          SizedBox(height: 12),
                          Text('Aucun ticket aujourd\'hui', style: TextStyle(color: AppTheme.textHint)),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: tickets.length,
                    itemBuilder: (context, index) {
                      final ticket = tickets[index];
                      return _buildTicketCard(context, ticket);
                    },
                  );
                },
                loading: () => Center(child: CircularProgressIndicator()),
                error: (e, s) => Text('Erreur tickets: $e'.tr),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketCard(BuildContext context, Ticket ticket) {
    Color statusColor = AppTheme.textHint;
    String statusText = 'En attente';

    switch (ticket.status) {
      case TicketStatus.enAttente:
        statusColor = AppTheme.warningOrange;
        statusText = 'En attente';
        break;
      case TicketStatus.paye:
        statusColor = AppTheme.successGreen;
        statusText = 'Payé';
        break;
      case TicketStatus.rembourse:
        statusColor = AppTheme.errorRed;
        statusText = 'Remboursé';
        break;
    }

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  ticket.vehiclePlate ?? '',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                ),
                Text(
                  '${ticket.totalAmount.toStringAsFixed(2)} DT',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.accentCyan,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${ticket.serviceName} (${ticket.vehicleType})',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  ticket.workerName != null ? 'Laveur: ${ticket.workerName}' : 'Laveur: Non assigné',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  'Paiement: ${ticket.paymentMethod?.toUpperCase() ?? 'INCONNU'}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const Divider(height: 20),
            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (ticket.workerId == null)
                  TextButton.icon(
                    onPressed: () => _assignWorker(ticket.id),
                    icon: Icon(Icons.person_add, size: 18),
                    label: Text('Assigner'.tr),
                  ),
                if (ticket.status == TicketStatus.enAttente) ...[
                  TextButton.icon(
                    onPressed: () => _updateStatus(ticket.id, 'paye'),
                    icon: Icon(Icons.check_circle, size: 18, color: AppTheme.successGreen),
                    label: Text('Encaisser', style: TextStyle(color: AppTheme.successGreen)),
                  ),
                  TextButton.icon(
                    onPressed: () => _updateStatus(ticket.id, 'rembourse'),
                    icon: Icon(Icons.cancel, size: 18, color: AppTheme.errorRed),
                    label: Text('Annuler', style: TextStyle(color: AppTheme.errorRed)),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

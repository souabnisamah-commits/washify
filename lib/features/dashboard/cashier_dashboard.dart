import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:washify/core/theme/app_theme.dart';

import 'package:washify/providers/auth_provider.dart';
import 'package:washify/providers/ticket_provider.dart';
import 'package:washify/providers/employee_provider.dart';
import 'package:washify/features/tickets/models/ticket.dart';

class CashierDashboard extends ConsumerStatefulWidget {
  const CashierDashboard({super.key});

  @override
  ConsumerState<CashierDashboard> createState() => _CashierDashboardState();
}

class _CashierDashboardState extends ConsumerState<CashierDashboard> {
  void _logout() {
    ref.read(currentUserProvider.notifier).logout();
    context.go('/login');
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
        SnackBar(content: Text('Statut du ticket mis à jour : $status')),
      );
    }
  }

  Future<void> _assignWorker(String ticketId) async {
    final user = ref.read(currentUserProvider);
    if (user == null || user.stationId == null) return;

    final employees = await ref.read(employeeRepositoryProvider).getEmployeesByStation(user.stationId!);
    final workers = employees.where((e) => e.role.value == 'worker').toList();

    if (!mounted) return;

    if (workers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aucun laveur actif disponible')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Assigner un laveur'),
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
                        SnackBar(content: Text('Laveur ${worker.name} assigné')),
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
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final ticketsStream = ref.watch(todayTicketsStreamProvider(user.stationId!));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Caisse - Washify'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Quick Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => context.go('/cashier/tickets/new'),
                    icon: const Icon(Icons.add),
                    label: const Text('Nouveau Ticket'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: AppTheme.primaryBlue,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => context.go('/cashier/stock'),
                    icon: const Icon(Icons.inventory),
                    label: const Text('Stock / Détergents'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

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
                  child: const Text('Voir tout'),
                ),
              ],
            ),
            const SizedBox(height: 12),

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
                          const SizedBox(height: 12),
                          const Text('Aucun ticket aujourd\'hui', style: TextStyle(color: AppTheme.textHint)),
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
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) => Text('Erreur tickets: $e'),
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
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
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
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${ticket.serviceName} (${ticket.vehicleType})',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  ticket.workerName != null ? 'Laveur: ${ticket.workerName}' : 'Laveur: Non assigné',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  'Paiement: ${ticket.paymentMethod.toUpperCase()}',
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
                    icon: const Icon(Icons.person_add, size: 18),
                    label: const Text('Assigner'),
                  ),
                if (ticket.status == TicketStatus.enAttente) ...[
                  TextButton.icon(
                    onPressed: () => _updateStatus(ticket.id, 'paye'),
                    icon: const Icon(Icons.check_circle, size: 18, color: AppTheme.successGreen),
                    label: const Text('Encaisser', style: TextStyle(color: AppTheme.successGreen)),
                  ),
                  TextButton.icon(
                    onPressed: () => _updateStatus(ticket.id, 'rembourse'),
                    icon: const Icon(Icons.cancel, size: 18, color: AppTheme.errorRed),
                    label: const Text('Annuler', style: TextStyle(color: AppTheme.errorRed)),
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

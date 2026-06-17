import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:washify/core/theme/app_theme.dart';
import 'package:washify/providers/auth_provider.dart';
import 'package:washify/providers/ticket_provider.dart';
import 'package:washify/providers/wallet_provider.dart';
import 'package:washify/features/tickets/models/ticket.dart';

class WorkerDashboard extends ConsumerStatefulWidget {
  const WorkerDashboard({super.key});

  @override
  ConsumerState<WorkerDashboard> createState() => _WorkerDashboardState();
}

class _WorkerDashboardState extends ConsumerState<WorkerDashboard> {
  void _logout() {
    ref.read(currentUserProvider.notifier).logout();
    context.go('/login');
  }

  Future<void> _updateStatus(String ticketId, String status) async {
    final repo = ref.read(ticketRepositoryProvider);
    await repo.updateTicketStatus(ticketId, status);
    ref.invalidate(ticketsByWorkerProvider);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Statut mis à jour : $status')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    if (user == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final walletStream = ref.watch(walletStreamProvider(user.id));
    final assignedTicketsAsync = ref.watch(ticketsByWorkerProvider((
      workerId: user.id,
      status: null, // load all assigned
    )));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Espace Laveur'),
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
            // Wallet Card Summary
            walletStream.when(
              data: (wallet) {
                final balance = wallet?.balance ?? 0;
                final earned = wallet?.totalEarned ?? 0;

                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Portefeuille Commission',
                            style: TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${balance.toStringAsFixed(2)} DT',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Cumul gains: ${earned.toStringAsFixed(2)} DT',
                            style: const TextStyle(color: Colors.white60, fontSize: 12),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_circle_right, color: Colors.white, size: 36),
                        onPressed: () => context.go('/worker/wallet'),
                      ),
                    ],
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Text('Erreur Wallet: $e'),
            ),
            const SizedBox(height: 24),

            // Assigned Tickets Header
            Text(
              'Mes Tâches Assignées',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),

            // Assigned Tickets List
            Expanded(
              child: assignedTicketsAsync.when(
                data: (tickets) {
                  if (tickets.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.assignment, size: 48, color: AppTheme.textHint.withValues(alpha: 0.5)),
                          const SizedBox(height: 12),
                          const Text('Aucune tâche assignée pour le moment', style: TextStyle(color: AppTheme.textHint)),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: tickets.length,
                    itemBuilder: (context, index) {
                      final ticket = tickets[index];
                      return _buildWorkerTicketCard(context, ticket);
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) => Text('Erreur tâches: $e'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkerTicketCard(BuildContext context, Ticket ticket) {
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
            Text(
              'Service: ${ticket.serviceName}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              'Véhicule: ${ticket.vehicleType}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (ticket.notes != null && ticket.notes!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                'Notes: ${ticket.notes}',
                style: const TextStyle(fontStyle: FontStyle.italic, color: AppTheme.textHint),
              ),
            ],
            const Divider(height: 20),
            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (ticket.status == TicketStatus.enAttente)
                  ElevatedButton.icon(
                    onPressed: () => _updateStatus(ticket.id, 'completed'),
                    icon: const Icon(Icons.check),
                    label: const Text('Terminer'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.successGreen),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

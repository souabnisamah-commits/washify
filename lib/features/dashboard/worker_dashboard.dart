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
                return InkWell(
                  onTap: () => context.go('/worker/wallet'),
                  borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppTheme.successGreen.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                      border: Border.all(color: AppTheme.successGreen, width: 2),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.successGreen.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.account_balance_wallet, color: AppTheme.successGreen, size: 48),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Mon Argent',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppTheme.successGreen),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${balance.toStringAsFixed(1)} DT',
                                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                      color: AppTheme.successGreen,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: AppTheme.successGreen, size: 36),
                      ],
                    ),
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
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
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
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryBlue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.4), width: 2),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.local_car_wash, size: 48, color: AppTheme.primaryBlue),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ticket.vehiclePlate ?? 'Voiture',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  ticket.serviceName.toString(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          if (ticket.status == TicketStatus.enAttente)
            InkWell(
              onTap: () => _updateStatus(ticket.id, 'completed'),
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                decoration: BoxDecoration(
                  color: AppTheme.successGreen,
                  borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                  boxShadow: [
                    BoxShadow(color: AppTheme.successGreen.withValues(alpha: 0.4), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 48),
              ),
            ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:washify/core/widgets/color_animated_title.dart';
import 'package:washify/providers/station_provider.dart';
import 'package:washify/providers/employee_provider.dart';
import 'package:washify/features/hr/providers/hr_provider.dart';
import 'package:washify/features/hr/models/attendance.dart';
import 'package:washify/features/hr/models/shift.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:washify/core/theme/app_theme.dart';
import 'package:washify/providers/auth_provider.dart';
import 'package:washify/providers/ticket_provider.dart';
import 'package:washify/providers/wallet_provider.dart';
import 'package:washify/features/tickets/models/ticket.dart';
import 'package:washify/core/localization/app_localizations.dart';
import 'package:washify/features/auth/widgets/change_pin_dialog.dart';
import 'package:washify/core/widgets/language_toggle_button.dart';

import 'package:intl/intl.dart';
import 'package:washify/providers/theme_provider.dart';


class CashierDashboard extends ConsumerStatefulWidget {
  const CashierDashboard({super.key});

  @override
  ConsumerState<CashierDashboard> createState() => _CashierDashboardState();
}

class _CashierDashboardState extends ConsumerState<CashierDashboard> {

  String _getStationName(WidgetRef ref, String stationId) {
    if (stationId.isEmpty) return '';
    final stationAsync = ref.watch(stationByIdProvider(stationId));
    return stationAsync.value?.name ?? '';
  }

  void _showPlanificationBottomSheet(BuildContext context, WidgetRef ref, String stationId, String userId) {
    final employeeAsync = ref.watch(employeeByUserIdProvider(userId));
    final employee = employeeAsync.value;
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (context) {
        if (employee == null) {
          return const Padding(
            padding: EdgeInsets.all(32.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        
        final attendancesAsync = ref.watch(employeeAttendancesProvider((stationId: stationId, employeeId: employee.id)));
        final shiftsAsync = ref.watch(shiftsStreamProvider(stationId));
        
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ma Planification',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: attendancesAsync.when(
                  data: (attendances) {
                    final upcoming = attendances.where((a) => a.date.isAfter(DateTime.now().subtract(const Duration(days: 1)))).toList();
                    upcoming.sort((a, b) => a.date.compareTo(b.date));
                    
                    if (upcoming.isEmpty) {
                      return const Center(child: Text('Aucune planification à venir.'));
                    }
                    
                    return ListView.builder(
                      itemCount: upcoming.length,
                      itemBuilder: (context, index) {
                        final a = upcoming[index];
                        final dateStr = DateFormat('dd/MM/yyyy').format(a.date);
                        
                        return shiftsAsync.when(
                          data: (shifts) {
                            final shift = shifts.firstWhere((s) => s.id == a.shiftId, orElse: () => Shift(id: '', stationId: '', name: 'Inconnu', startTime: '', endTime: '', createdAt: DateTime.now()));
                            return ListTile(
                              leading: const Icon(Icons.calendar_month, color: Colors.blueAccent),
                              title: Text(dateStr, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('${shift.name} (${shift.startTime} - ${shift.endTime})'),
                              trailing: Text(a.status == AttendanceStatus.planned ? 'Planifié' : 'Présent', style: TextStyle(color: a.status == AttendanceStatus.planned ? Colors.orange : Colors.green)),
                            );
                          },
                          loading: () => const ListTile(title: Text('Chargement...')),
                          error: (e, s) => const ListTile(title: Text('Erreur...')),
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, s) => const Center(child: Text('Erreur...')),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _logout() {
    ref.read(currentUserProvider.notifier).logout();
    context.go('/login');
  }

  void _showTicketsBottomSheet(BuildContext context, List<Ticket> tickets) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tickets Équipe du Jour',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Expanded(
                child: tickets.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.receipt_long, size: 64, color: AppTheme.textHint.withValues(alpha: 0.3)),
                            SizedBox(height: 16),
                            Text('Aucun ticket aujourd\'hui', style: TextStyle(color: AppTheme.textHint)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: tickets.length,
                        itemBuilder: (context, index) {
                          final ticket = tickets[index];
                          final dateStr = DateFormat('HH:mm').format(ticket.createdAt);
                          
                          Color statusColor = AppTheme.textHint;
                          switch (ticket.status) {
                            case TicketStatus.paye:
                              statusColor = AppTheme.successGreen;
                              break;
                            case TicketStatus.enAttente:
                              statusColor = AppTheme.warningOrange;
                              break;
                            case TicketStatus.rembourse:
                              statusColor = AppTheme.errorRed;
                              break;
                          }

                          return Card(
                            margin: EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: statusColor.withValues(alpha: 0.1),
                                child: Icon(Icons.receipt_long, color: statusColor),
                              ),
                              title: Text(ticket.vehiclePlate ?? 'Véhicule', style: TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('${ticket.serviceName} • $dateStr\nLaveur: ${ticket.assignedWorkerName ?? ticket.workerName ?? "Non assigné"}'),
                              trailing: ticket.status == TicketStatus.enAttente 
                                  ? Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.delete, color: AppTheme.errorRed),
                                          onPressed: () async {
                                            final confirm = await showDialog<bool>(
                                              context: context,
                                              builder: (ctx) => AlertDialog(
                                                title: Text('Annuler le ticket ?'.tr),
                                                content: Text('Voulez-vous vraiment supprimer ce ticket en attente ?'.tr),
                                                actions: [
                                                  TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Non'.tr)),
                                                  ElevatedButton(
                                                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorRed),
                                                    onPressed: () => Navigator.pop(ctx, true),
                                                    child: Text('Supprimer'.tr, style: TextStyle(color: Colors.white)),
                                                  ),
                                                ],
                                              ),
                                            );
                                            if (confirm == true) {
                                              try {
                                                await ref.read(ticketRepositoryProvider).deleteTicket(ticket.id);
                                                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ticket annulé'.tr)));
                                                if (context.mounted) Navigator.pop(context); // Fermer le bottom sheet pour rafraîchir
                                              } catch (e) {
                                                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e'.tr)));
                                              }
                                            }
                                          },
                                        ),
                                        SizedBox(width: 8),
                                        ElevatedButton(
                                          onPressed: () async {
                                            try {
                                              final updated = ticket.copyWith(
                                                status: TicketStatus.paye,
                                                paidBy: ref.read(currentUserProvider)?.name,
                                                updatedAt: DateTime.now(),
                                              );
                                              await ref.read(ticketRepositoryProvider).updateTicket(updated);
                                              if (context.mounted) Navigator.pop(context);
                                              if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ticket validé'.tr)));
                                            } catch (e) {
                                              if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e'.tr)));
                                            }
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppTheme.successGreen,
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                          ),
                                          child: Text('Valider'.tr),
                                        ),
                                      ],
                                    )
                                  : Text('${ticket.totalAmount.toStringAsFixed(2)} DT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              isThreeLine: true,
                            ),
                          );
                        },
                      ),
              ),
            ],
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
    // Provide wallet for the cashier too, as requested
    final employeeAsync = ref.watch(employeeByUserIdProvider(user.id));
    final walletStream = ref.watch(walletStreamProvider(employeeAsync.value?.id ?? user.id));


    return Scaffold(
      appBar: AppBar(
        title: ColorAnimatedTitle(
          text: '${'Bienvenue'.tr} ${user.name},\n${'dans votre Espace'.tr} ${_getStationName(ref, user.stationId ?? '')}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, height: 1.2),
        ),
        actions: [
          IconButton(
            icon: Icon(ref.watch(themeProvider) == ThemeMode.light ? Icons.dark_mode_outlined : Icons.light_mode_outlined),
            onPressed: () => ref.read(themeProvider.notifier).toggleTheme(),
          ),
          const LanguageToggleButton(),
          IconButton(
            icon: const Icon(Icons.lock_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => ChangePinDialog(),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            onPressed: _logout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Nouveau Ticket (Bouton principal)
            InkWell(
              onTap: () => context.push('/cashier/tickets/new'),
              borderRadius: BorderRadius.circular(24),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    const Icon(Icons.add_circle_outline, color: Colors.white, size: 64),
                    const SizedBox(height: 16),
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
            const SizedBox(height: 24),

            // 2. Solde Actuel
            walletStream.when(
              data: (wallet) {
                final balance = wallet?.balance ?? 0;
                return _buildActionCard(
                  context,
                  title: 'Solde Actuel',
                  value: '${balance.toStringAsFixed(1)} DT',
                  icon: Icons.account_balance_wallet,
                  color: AppTheme.successGreen,
                  // Cashier doesn't have a wallet screen in routing yet, but let's assume they can view transactions
                  onTap: () {},
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Text('Erreur Wallet: $e'),
            ),
            const SizedBox(height: 24),

            // 3. Planification
            _buildActionCard(
              context,
              title: 'Planification',
              value: 'Voir Planning',
              icon: Icons.calendar_month,
              color: AppTheme.primaryBlue,
              onTap: () {
                _showPlanificationBottomSheet(context, ref, user.stationId!, user.id);
              },
            ),
            const SizedBox(height: 24),

            // 3b. Mes Recettes (Added per user request)
            ticketsStream.when(
              data: (allTickets) {
                final employeeId = employeeAsync.value?.id ?? user.id;
                final tickets = allTickets.where((t) => t.assignedWorkerId == employeeId).toList();
                double total = 0;
                for (var t in tickets) {
                  if (t.status == TicketStatus.paye) {
                    total += t.totalAmount;
                  }
                }
                return _buildActionCard(
                  context,
                  title: 'Mes Recettes',
                  value: '${total.toStringAsFixed(1)} DT',
                  icon: Icons.payments,
                  color: Colors.orange,
                  onTap: () => _showTicketsBottomSheet(context, tickets),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Text('Erreur tâches: $e'),
            ),
            const SizedBox(height: 24),

            // 4. Recettes Équipe
            ticketsStream.when(
              data: (tickets) {
                double total = 0;
                for (var t in tickets) {
                  total += t.totalAmount;
                }
                return _buildActionCard(
                  context,
                  title: 'Recettes Équipe',
                  value: '${total.toStringAsFixed(1)} DT',
                  icon: Icons.payments,
                  color: Colors.orange,
                  onTap: () => _showTicketsBottomSheet(context, tickets),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Text('Erreur tickets: $e'),
            ),
            
            const SizedBox(height: 48),
            Center(
              child: Text(
                'Created By SouTeQSa',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 48),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: color, size: 36),
          ],
        ),
      ),
    );
  }
}

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
import 'package:washify/features/dashboard/widgets/tickets_details_dialog.dart';
import 'package:washify/providers/theme_provider.dart';
import 'package:washify/providers/caisse_provider.dart';


class MultiRoleDashboard extends ConsumerWidget {
  final String title;
  final List<Map<String, dynamic>> roles;

  const MultiRoleDashboard({
    super.key,
    required this.title,
    required this.roles,
  });

  void _logout(BuildContext context, WidgetRef ref) {
    ref.read(currentUserProvider.notifier).logout();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context, ref),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${'Bienvenue'.tr}, ${user?.name ?? ''}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Choisissez votre espace de travail.',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Vos Rôles',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            ...roles.map((r) => Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: InkWell(
                    onTap: () => context.push(r['route']),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceCard,
                        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                        border: Border.all(color: AppTheme.dividerColor),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: r['color'].withOpacity(0.15),
                              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                            ),
                            child: Icon(r['icon'], color: r['color'], size: 24),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  r['title'],
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  r['subtitle'],
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: AppTheme.textHint),
                        ],
                      ),
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

class WorkerCashierDashboard extends ConsumerStatefulWidget {
  const WorkerCashierDashboard({super.key});

  @override
  ConsumerState<WorkerCashierDashboard> createState() => _WorkerCashierDashboardState();
}

class _WorkerCashierDashboardState extends ConsumerState<WorkerCashierDashboard> {

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

  void _showTicketsBottomSheet(BuildContext context, List<Ticket> tickets, String title) {
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
                title,
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
                            Text('Aucun ticket trouvé', style: TextStyle(color: AppTheme.textHint)),
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
                            case TicketStatus.annule:
                            case TicketStatus.efface:
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
                                          icon: Icon(Icons.edit, color: AppTheme.primaryBlue),
                                          onPressed: () {
                                            context.push('/cashier/tickets/new', extra: ticket);
                                          },
                                        ),
                                        SizedBox(width: 8),
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
    final employeeAsync = ref.watch(employeeByUserIdProvider(user.id));
    final walletStream = ref.watch(walletStreamProvider(employeeAsync.value?.id ?? user.id));
    final activeSessionAsync = ref.watch(activeSessionProvider);


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
            activeSessionAsync.when(
              data: (session) {
                if (session == null) {
                  return Card(
                    color: AppTheme.errorRed.withValues(alpha: 0.1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    margin: const EdgeInsets.only(bottom: 20),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          const Icon(Icons.lock_outline, color: AppTheme.errorRed, size: 28),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Attention : La caisse est fermée par le patron.'.tr,
                              style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.errorRed, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final double calculatedCash = session.initialBalance + session.totalCashIn - session.totalCashOut;
                return Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
                  ),
                  margin: const EdgeInsets.only(bottom: 20),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        colors: [Colors.grey.shade900, Colors.grey.shade800],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.lock_open, color: AppTheme.successGreen, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Caisse Active'.tr,
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14),
                                ),
                              ],
                            ),
                            Text(
                              '${'Solde :'.tr} ${calculatedCash.toStringAsFixed(2)} DT',
                              style: const TextStyle(fontWeight: FontWeight.w900, color: AppTheme.successGreen, fontSize: 16),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildMiniStat('Fond initial'.tr, session.initialBalance),
                            _buildMiniStat('Total Entrées'.tr, session.totalCashIn, color: AppTheme.successGreen),
                            _buildMiniStat('Total Sorties'.tr, session.totalCashOut, color: AppTheme.errorRed),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
              loading: () => const SizedBox(),
              error: (e, s) => const SizedBox(),
            ),

            // 1. Nouveau Ticket
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
                  title: 'Mon Solde Actuel',
                  value: '${balance.toStringAsFixed(1)} DT',
                  icon: Icons.account_balance_wallet,
                  color: AppTheme.successGreen,
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

            // 4. Mes Recettes
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
                  icon: Icons.person,
                  color: Colors.deepPurpleAccent,
                  onTap: () => showTicketsDetailsDialog(context, 'Mes Recettes (${total.toStringAsFixed(1)} DT)', tickets),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Text('Erreur tâches: $e'),
            ),
            const SizedBox(height: 24),

            // 5. Recettes Équipe
            ticketsStream.when(
              data: (tickets) {
                double total = 0;
                for (var t in tickets) {
                  if (t.status == TicketStatus.paye) {
                    total += t.totalAmount;
                  }
                }
                return _buildActionCard(
                  context,
                  title: 'Recettes Équipe',
                  value: '${total.toStringAsFixed(1)} DT',
                  icon: Icons.groups,
                  color: Colors.orange,
                  onTap: () => showTicketsDetailsDialog(context, 'Recettes Équipe (${total.toStringAsFixed(1)} DT)', tickets),
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

  Widget _buildMiniStat(String label, double value, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 11)),
        const SizedBox(height: 4),
        Text(
          '${value.toStringAsFixed(1)} DT',
          style: TextStyle(
            color: color ?? Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

class PatronCashierDashboard extends StatelessWidget {
  const PatronCashierDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return const MultiRoleDashboard(
      title: 'Espace Patron & Caissier',
      roles: [
        {
          'title': 'Espace Patron',
          'subtitle': 'Statistiques et gestion de la station',
          'icon': Icons.admin_panel_settings,
          'color': AppTheme.primaryBlue,
          'route': '/patron'
        },
        {
          'title': 'Espace Caissier',
          'subtitle': 'Créer des tickets et encaisser',
          'icon': Icons.point_of_sale,
          'color': AppTheme.successGreen,
          'route': '/cashier'
        },
      ],
    );
  }
}

class PatronWorkerDashboard extends StatelessWidget {
  const PatronWorkerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return const MultiRoleDashboard(
      title: 'Espace Patron & Ouvrier',
      roles: [
        {
          'title': 'Espace Patron',
          'subtitle': 'Statistiques et gestion de la station',
          'icon': Icons.admin_panel_settings,
          'color': AppTheme.primaryBlue,
          'route': '/patron'
        },
        {
          'title': 'Espace Ouvrier',
          'subtitle': 'Consulter vos tâches et votre portefeuille',
          'icon': Icons.local_car_wash,
          'color': AppTheme.accentCyan,
          'route': '/worker'
        },
      ],
    );
  }
}

class PatronWorkerCashierDashboard extends StatelessWidget {
  const PatronWorkerCashierDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return const MultiRoleDashboard(
      title: 'Portail Multi-Rôles',
      roles: [
        {
          'title': 'Espace Patron',
          'subtitle': 'Statistiques et gestion de la station',
          'icon': Icons.admin_panel_settings,
          'color': AppTheme.primaryBlue,
          'route': '/patron'
        },
        {
          'title': 'Espace Caissier',
          'subtitle': 'Créer des tickets et encaisser',
          'icon': Icons.point_of_sale,
          'color': AppTheme.successGreen,
          'route': '/cashier'
        },
        {
          'title': 'Espace Ouvrier',
          'subtitle': 'Consulter vos tâches et votre portefeuille',
          'icon': Icons.local_car_wash,
          'color': AppTheme.accentCyan,
          'route': '/worker'
        },
      ],
    );
  }
}

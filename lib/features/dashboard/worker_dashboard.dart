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


class WorkerDashboard extends ConsumerStatefulWidget {
  const WorkerDashboard({super.key});

  @override
  ConsumerState<WorkerDashboard> createState() => _WorkerDashboardState();
}

class _WorkerDashboardState extends ConsumerState<WorkerDashboard> {

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
                'Mes Tâches du Jour',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Expanded(
                child: tickets.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.assignment_turned_in, size: 64, color: AppTheme.textHint.withValues(alpha: 0.3)),
                            SizedBox(height: 16),
                            Text('Aucune tâche pour le moment', style: TextStyle(color: AppTheme.textHint)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: tickets.length,
                        itemBuilder: (context, index) {
                          final ticket = tickets[index];
                          final dateStr = DateFormat('HH:mm').format(ticket.createdAt);
                          return Card(
                            margin: EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: AppTheme.primaryBlue.withValues(alpha: 0.1),
                                child: Icon(Icons.local_car_wash, color: AppTheme.primaryBlue),
                              ),
                              title: Text(ticket.vehiclePlate ?? 'Véhicule', style: TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('${ticket.serviceName} • $dateStr'),
                              trailing: Icon(Icons.chevron_right, color: AppTheme.textHint),
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
    if (user == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final employeeAsync = ref.watch(employeeByUserIdProvider(user.id));
    final walletStream = ref.watch(walletStreamProvider(employeeAsync.value?.id ?? user.id));
    final ticketsStream = ref.watch(todayTicketsStreamProvider(user.stationId!));

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
            // 1. Solde Actuel
            walletStream.when(
              data: (wallet) {
                final balance = wallet?.balance ?? 0;
                return _buildActionCard(
                  context,
                  title: 'Solde Actuel',
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

            // 2. Planification
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

            // 3. Recettes
            ticketsStream.when(
              data: (allTickets) {
                final employee = employeeAsync.value;
                final employeeId = employee?.id ?? user.id;
                final commissionRate = employee?.commissionRate ?? 0.0;
                
                final tickets = allTickets.where((t) => t.assignedWorkerId == employeeId).toList();
                
                double totalAmount = 0;
                int ticketsCount = 0;
                for (var t in tickets) {
                  if (t.status == TicketStatus.paye) {
                    totalAmount += t.totalAmount;
                    ticketsCount++;
                  }
                }
                
                // Assuming commissionRate is a percentage (e.g., 10 for 10%)
                // If the app uses fixed commission, you can adjust this logic, but for now we calculate percentage
                final commission = totalAmount * (commissionRate / 100);

                return _buildActionCard(
                  context,
                  title: 'Mes Recettes',
                  value: '$ticketsCount Ticket(s) • ${commission.toStringAsFixed(1)} DT',
                  icon: Icons.payments,
                  color: Colors.orange,
                  onTap: () => _showTicketsBottomSheet(context, tickets),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Text('Erreur tâches: $e'),
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

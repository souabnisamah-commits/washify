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
import 'package:washify/core/localization/language_selector_button.dart';

import 'package:intl/intl.dart';
import 'package:washify/providers/theme_provider.dart';
import 'package:washify/providers/caisse_provider.dart';
import 'package:washify/features/dashboard/widgets/tickets_details_dialog.dart';


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
                'Ma Planification'.tr,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: attendancesAsync.when(
                  data: (attendances) {
                    final upcoming = attendances.where((a) => a.date.isAfter(DateTime.now().subtract(const Duration(days: 1)))).toList();
                    upcoming.sort((a, b) => a.date.compareTo(b.date));
                    
                    if (upcoming.isEmpty) {
                      return Center(child: Text('Aucune planification à venir.'.tr));
                    }
                    
                    return ListView.builder(
                      itemCount: upcoming.length,
                      itemBuilder: (context, index) {
                        final a = upcoming[index];
                        final dateStr = DateFormat('dd/MM/yyyy').format(a.date);
                        
                        return shiftsAsync.when(
                          data: (shifts) {
                            final shift = shifts.firstWhere((s) => s.id == a.shiftId, orElse: () => Shift(id: '', stationId: '', name: 'Inconnu'.tr, startTime: '', endTime: '', createdAt: DateTime.now()));
                            return ListTile(
                              leading: const Icon(Icons.calendar_month, color: Colors.blueAccent),
                              title: Text(dateStr, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('${shift.name} (${shift.startTime} - ${shift.endTime})'),
                              trailing: Text(a.status == AttendanceStatus.planned ? 'Planifié'.tr : 'Présent'.tr, style: TextStyle(color: a.status == AttendanceStatus.planned ? Colors.orange : Colors.green)),
                            );
                          },
                          loading: () => ListTile(title: Text('Chargement...'.tr)),
                          error: (e, s) => ListTile(title: Text('Erreur...'.tr)),
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, s) => Center(child: Text('Erreur...'.tr)),
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
                'Tickets Équipe du Jour'.tr,
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
                            Text('Aucun ticket aujourd\'hui'.tr, style: TextStyle(color: AppTheme.textHint)),
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

                          final workerName = ticket.assignedWorkerName ?? ticket.workerName ?? "Non assigné".tr;
                          return Card(
                            margin: EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: statusColor.withValues(alpha: 0.1),
                                child: Icon(Icons.receipt_long, color: statusColor),
                              ),
                              title: Text(ticket.vehiclePlate ?? 'Lavage Véhicule'.tr, style: TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('${ticket.serviceName} • $dateStr\n${'Ouvrier'.tr}: $workerName'),
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
                                                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${'Erreur'.tr}: $e')));
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
                                              if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${'Erreur'.tr}: $e')));
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
          const LanguageSelectorButton(),
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

            // 2. Solde Actuel (Pro Glassmorphism Design)
            walletStream.when(
              data: (wallet) {
                final balance = wallet?.balance ?? 0;
                return _buildProSoldeActuelCard(context, balance);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Text('Erreur Wallet: $e'),
            ),
            const SizedBox(height: 24),

            // 3. Planification
            _buildActionCard(
              context,
              title: 'Planification'.tr,
              value: 'Voir planning'.tr,
              icon: Icons.calendar_month,
              color: AppTheme.primaryBlue,
              onTap: () {
                _showPlanificationBottomSheet(context, ref, user.stationId!, user.id);
              },
            ),
            const SizedBox(height: 24),

            // 3b. Mes Recettes
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
                  title: 'Mes recettes'.tr,
                  value: '${total.toStringAsFixed(1)} DT',
                  icon: Icons.payments,
                  color: Colors.orange,
                  onTap: () => showTicketsDetailsDialog(
                    context,
                    '${'Mes recettes'.tr} (${total.toStringAsFixed(1)} DT)',
                    tickets,
                  ),
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
                  if (t.status == TicketStatus.paye) {
                    total += t.totalAmount;
                  }
                }
                return _buildActionCard(
                  context,
                  title: 'Recette équipe'.tr,
                  value: '${total.toStringAsFixed(1)} DT',
                  icon: Icons.groups,
                  color: Colors.orange,
                  onTap: () => showTicketsDetailsDialog(
                    context,
                    '${'Recette équipe'.tr} (${total.toStringAsFixed(1)} DT)',
                    tickets,
                  ),
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

  Widget _buildProSoldeActuelCard(BuildContext context, double balance) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0F2027),
            Color(0xFF203A43),
            Color(0xFF2C5364),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accentCyan.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: AppTheme.accentCyan.withValues(alpha: 0.35), width: 1.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.accentCyan.withValues(alpha: 0.12),
                ),
              ),
            ),
            Positioned(
              left: -30,
              bottom: -30,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.successGreen.withValues(alpha: 0.1),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppTheme.accentCyan.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                              border: Border.all(color: AppTheme.accentCyan.withValues(alpha: 0.4)),
                            ),
                            child: const Icon(Icons.account_balance_wallet_rounded, color: AppTheme.accentCyan, size: 24),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Mon Solde Actuel'.tr,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: AppTheme.successGreen,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Caisse Active • Temps Réel'.tr,
                                    style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.7)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.successGreen.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppTheme.successGreen.withValues(alpha: 0.4)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.verified, size: 14, color: AppTheme.successGreen),
                            const SizedBox(width: 4),
                            Text(
                              'PRO'.tr,
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.successGreen),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        balance.toStringAsFixed(2),
                        style: const TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 1.0,
                          shadows: [
                            Shadow(color: AppTheme.accentCyan, blurRadius: 10),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'DT',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.accentCyan,
                        ),
                      ),
                    ],
                  ),
                ],
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
